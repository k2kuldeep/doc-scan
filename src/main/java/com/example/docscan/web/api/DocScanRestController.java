package com.example.docscan.web.api;


import com.example.docscan.core.DocScanner;
import com.example.docscan.utils.DocScanUtils;
import com.example.docscan.web.exceptions.DocumentScanException;
import org.opencv.core.Mat;
import org.opencv.core.MatOfByte;
import org.opencv.imgcodecs.Imgcodecs;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;
import java.util.logging.Logger;

@RestController
@RequestMapping("/doc-tool")
public class DocScanRestController {

    private final Logger logger = Logger.getLogger(DocScanRestController.class.getName());

    @PostMapping(value = "/scan")
    public Map<String, String> doScanImage(@RequestParam("image") MultipartFile file,
                                           @RequestParam("threshold1") int threshold1,
                                           @RequestParam("threshold2") int threshold2){
        if (threshold1<1 || threshold2<=1 ){
            logger.severe("Invalid threshold values, should be greater than zero.");
            throw new DocumentScanException("Invalid threshold values, should be greater than zero.");
        }
        if (threshold2 <= threshold1 ){
            logger.severe("Invalid threshold values, threshold2 should be greater than threshold1.");
            throw new DocumentScanException("Invalid threshold values, threshold2 should be greater than threshold1.");
        }

        String originalFilename = file.getOriginalFilename();
        try {
            if (originalFilename == null || originalFilename.isEmpty() || !DocScanUtils.isValidImageFile(file.getInputStream())){
                logger.severe("Invalid image file");
                throw new DocumentScanException("Invalid image file");
            }
        } catch (IOException e) {
            logger.severe("Internal server error: "+e.getMessage());
            throw new DocumentScanException("Internal server error: "+ e.getMessage());
        }
        Map<String, String> resultMap;
        try {
            DocScanner docScanner = new DocScanner();
            byte[] bytes = StreamUtils.copyToByteArray(file.getInputStream());
            Mat src = Imgcodecs.imdecode(new MatOfByte(bytes), Imgcodecs.IMREAD_UNCHANGED);
            Map<String,Mat> imagesMap = docScanner.scan(src, threshold1, threshold2);

            resultMap = DocScanUtils.convertMapOfMatToMapOfBase64(imagesMap);
        } catch (Exception e) {
            throw new DocumentScanException("Internal server error: "+ e.getMessage());
        }
        return resultMap;
    }

}
