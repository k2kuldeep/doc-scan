package com.example.docscan.utils;

import org.opencv.core.*;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;
import org.opencv.utils.Converters;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

public class DocScanUtils {

    /**
     * Load image
     *
     * @param imagePath the image path
     * @return the mat
     */
    public static Mat loadImage(String imagePath) {
        return Imgcodecs.imread(imagePath);
    }

    /**
     * Save image
     *
     * @param imageMatrix the image matrix
     * @param targetPath  the target path
     */
    public static void saveImage(Mat imageMatrix, String targetPath) {
        Imgcodecs.imwrite(targetPath, imageMatrix);
    }

    /**
     * to find the biggest contour.
     *
     * @param contours the contours
     * @return the mat of point
     */
    public static List<Object> biggestContour(List<MatOfPoint> contours){
        double maxArea = -1;
        MatOfPoint largestContour = contours.get(0);
        for (MatOfPoint contour : contours) {
            double area = Imgproc.contourArea(contour);
            if (area > maxArea) {
                MatOfPoint2f m2f = new MatOfPoint2f(contour.toArray());
                MatOfPoint2f approxCurve = new MatOfPoint2f();
                double arcLength = Imgproc.arcLength(m2f, true);
                Imgproc.approxPolyDP(m2f, approxCurve, arcLength*0.02, true);
                //check if this contour has four sides
                if (approxCurve.total() == 4) {
                    MatOfPoint approx = new MatOfPoint();
                    maxArea = area;
                    approxCurve.convertTo(approx, CvType.CV_32S);
                    largestContour = approx;
                }
            }
        }
        return Arrays.asList(largestContour, maxArea);
    }

    /**
     * Gets warp perspective.
     *
     * @param src    the src
     * @param points the points
     * @return the warp perspective
     * @throws Exception the exception
     */
    public static Mat getWarpPerspective(Mat src, List<Point> points) throws Exception {
        if (points == null || points.size()<4){
            throw new Exception("Four points are required");
        }
        Mat srcPoints = Converters.vector_Point_to_Mat(points, CvType.CV_32F);

        List<Point> listDsts = Arrays.asList(new Point(0, 0), new Point(src.width(), 0),
                new Point(0, src.height()), new Point(src.width(), src.height()));

        Mat dstPoints = Converters.vector_Point_to_Mat(listDsts, CvType.CV_32F);

        Mat perspectiveTransform = Imgproc.getPerspectiveTransform(srcPoints, dstPoints);

        Mat dst = new Mat();
        Imgproc.warpPerspective(src, dst, perspectiveTransform, src.size(), Imgproc.INTER_AREA, 1, new Scalar(0));

        return dst;
    }

    /**
     * Reorder points for wrap perspective.
     *
     * @param myPoints the points
     * @throws Exception the exception
     */
    public static void reorder(List<Point> myPoints) throws Exception {
        if (myPoints == null || myPoints.size()<4){
            throw new Exception("Four points are required");
        }
        myPoints.sort((o1, o2) -> (int) ((o1.x+o1.y)-(o2.x+ o2.y)));
        Point p1 = myPoints.get(1);
        Point p2 = myPoints.get(2);
        if((p1.y-p1.x)>(p2.y-p2.x)){
            myPoints.set(1, p2);
            myPoints.set(2, p1);
        }
    }

    /**
     * Converts a BufferedImage into  Mat.
     *
     * @param bi BufferedImage of type TYPE_3BYTE_BGR or TYPE_BYTE_GRAY
     * @return Mat of type CV_8UC3 or CV_8UC1
     */
    public static Mat bufferedImageToMat(BufferedImage bi) {
        Mat mat = new Mat(bi.getHeight(), bi.getWidth(), CvType.CV_8UC3);
        byte[] data = ((DataBufferByte) bi.getRaster().getDataBuffer()).getData();
        mat.put(0, 0, data);
        return mat;
    }

    /**
     * Converts a Mat into a BufferedImage.
     *
     * @param matrix Mat of type CV_8UC3 or CV_8UC1
     * @return BufferedImage of type TYPE_3BYTE_BGR or TYPE_BYTE_GRAY
     * @throws IOException the io exception
     */
    public static BufferedImage MatToBufferedImage(Mat matrix) throws IOException {
        MatOfByte mob = new MatOfByte();
        Imgcodecs.imencode(".jpg", matrix, mob);
        return ImageIO.read(new ByteArrayInputStream(mob.toArray()));
    }


    /**
     * check if image file is valid or not.
     *
     * @param inputStream the input stream
     * @return the boolean
     * @throws IOException the io exception
     */
    public static boolean isValidImageFile(InputStream inputStream) throws IOException {
        return ImageIO.read(inputStream) != null;
    }

    /**
     * convert Map of Mat to Map of base64 image string
     * @param imagesMap Map of String, Mat
     * @return map of base64 image strings
     */
    public static Map<String, String> convertMapOfMatToMapOfBase64(Map<String, Mat> imagesMap) throws IOException {
        Map<String, String> base64ImageMap = new HashMap<>();
        for (Map.Entry<String, Mat> entity : imagesMap.entrySet()){
            base64ImageMap.put(entity.getKey(), convertMatToBase64(entity.getValue()));
        }
        return base64ImageMap;
    }

    private static String convertMatToBase64(Mat image) throws IOException {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        BufferedImage img = DocScanUtils.MatToBufferedImage(image);
        ImageIO.write(img, "jpg", byteArrayOutputStream);
        byte[] imageBytes = byteArrayOutputStream.toByteArray();
        return Base64.getEncoder().encodeToString(imageBytes);
    }
}
