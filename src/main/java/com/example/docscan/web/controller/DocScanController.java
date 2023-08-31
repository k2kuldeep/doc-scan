package com.example.docscan.web.controller;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import javax.servlet.http.HttpServletRequest;

@Controller
@RequestMapping(value = "doc-scan")
public class DocScanController {

    @GetMapping(value = "/main")
    public String documentScanPage(HttpServletRequest request) {
        return "docScanMainPage";
    }
}
