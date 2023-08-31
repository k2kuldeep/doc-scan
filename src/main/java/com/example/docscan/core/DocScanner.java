package com.example.docscan.core;


import com.example.docscan.utils.DocScanUtils;
import com.example.docscan.web.exceptions.DocumentScanException;
import nu.pattern.OpenCV;
import org.opencv.core.*;
import org.opencv.imgproc.Imgproc;

import java.util.*;

public class DocScanner {

    static {
        OpenCV.loadShared();
    }

    private final double widthImg;
    private final double heightImg;
    private final Scalar color = new Scalar(0,255,0);
    private double areaRatio = 0.2;

    public DocScanner() {
        this.widthImg = 0;
        this.heightImg = 0;
    }

    public DocScanner(double widthImg, double heightImg) {
        this.heightImg = heightImg;
        this.widthImg = widthImg;
    }

    public Map<String,Mat> scan(Mat src, double threshold1, double threshold2) throws Exception {
        if (this.widthImg != 0 || this.heightImg != 0){
            Imgproc.resize(src, src, new Size(widthImg, heightImg));
        }
        //result map
        Map<String,Mat> mapOfImages = new HashMap<>();

        //Creating an empty matrices to store edges, Dilation and imgThreshold.
        Mat gray = new Mat(src.rows(), src.cols(), src.type());
        Mat edges = new Mat(src.rows(), src.cols(), src.type());
        Mat imgThreshold = new Mat(src.rows(), src.cols(), src.type());
        Mat imgDial = new Mat(src.rows(), src.cols(), src.type());

        //Converting the image to Gray
        Imgproc.cvtColor(src, gray, Imgproc.COLOR_BGR2GRAY);
        //adding gray scale image
        mapOfImages.put("greyScale",gray);

        //Blurring the image
        Imgproc.GaussianBlur(gray, edges, new Size(5,5),1);

        //Detecting the edges
        Imgproc.Canny(edges, imgThreshold, threshold1, threshold2);
        mapOfImages.put("imageThreshold",imgThreshold);

        Mat kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, new Size(5,5));
        //APPLY DILATION
        Imgproc.dilate(imgThreshold, imgDial, kernel, new Point(), 2);
        //APPLY EROSION
        Imgproc.erode(imgDial, imgThreshold, kernel, new Point(), 1);

        //Finding Contours
        List<MatOfPoint> contours = new ArrayList<>();
        Mat hierarchy = new Mat();
        Imgproc.findContours(imgThreshold, contours, hierarchy, Imgproc.RETR_EXTERNAL, Imgproc.CHAIN_APPROX_SIMPLE);

        //to show all contours detected
        Mat contoursImg = src.clone();
        int thickness = 3;
        Imgproc.drawContours(contoursImg, contours, -1, color, thickness);
        mapOfImages.put("contours", contoursImg);

        //find the biggest contour
        List<Object> bigContourList = DocScanUtils.biggestContour(contours);
        if (bigContourList.size()<2){
            throw new DocumentScanException("Error in finding the biggest contour.");
        }
        MatOfPoint biggestContour = bigContourList.get(0) instanceof MatOfPoint? (MatOfPoint) bigContourList.get(0) : null;
        double areaOfBiggestContour = bigContourList.get(1) instanceof Double ? (double) bigContourList.get(1) : 0.0;

        if (biggestContour == null){
            throw new DocumentScanException("Error in finding the biggest contour.");
        }
        //to show the biggest contour detected
        Mat biggestContourImg = src.clone();
        Imgproc.drawContours(biggestContourImg, Collections.singletonList(biggestContour), -1, color, thickness);
        mapOfImages.put("biggestContour", biggestContourImg);


        List<Point> pointList = new ArrayList<>(biggestContour.toList());
        DocScanUtils.reorder(pointList);

        //release all matrix
        edges.release();
        imgDial.release();
        kernel.release();
        hierarchy.release();
        biggestContour.release();

        //check if area of the biggest contour is grater than 20% of total image area
        double areaSrcImg = src.size().area();
        if(areaOfBiggestContour >= areaSrcImg*areaRatio){
            //adding final image after wrap perspective.
            mapOfImages.put("finalImage", DocScanUtils.getWarpPerspective(src, pointList));
        }else {
            mapOfImages.put("finalImage", src);
        }
        return mapOfImages;
    }
}
