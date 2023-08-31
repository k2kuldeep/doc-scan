package com.example.docscan.web.exceptions;


public class DocumentScanException extends RuntimeException{

    private String errorCode;
    private String errorMessage;

    public DocumentScanException() {
    }

    public DocumentScanException(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public DocumentScanException(String errorCode, String errorMessage) {
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    @Override
    public String toString() {
        return "DocumentScanException{" +
                "errorCode='" + errorCode + '\'' +
                ", errorMessage='" + errorMessage + '\'' +
                '}';
    }
}
