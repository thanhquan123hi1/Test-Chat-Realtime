package com.example.chat.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public ResponseEntity<String> handleError(HttpServletRequest request) {
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        Object exception = request.getAttribute(RequestDispatcher.ERROR_EXCEPTION);
        Object message = request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        Object requestUri = request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);
        
        StringBuilder errorDetails = new StringBuilder();
        errorDetails.append("========================================\n");
        errorDetails.append("ERROR STATUS CODE: ").append(status != null ? status : "Unknown").append("\n");
        errorDetails.append("REQUEST URI: ").append(requestUri != null ? requestUri : "Unknown").append("\n");
        
        if (exception != null) {
            errorDetails.append("ERROR EXCEPTION: ").append(exception.getClass().getName()).append("\n");
            if (exception instanceof Exception) {
                Exception ex = (Exception) exception;
                errorDetails.append("ERROR MESSAGE: ").append(ex.getMessage()).append("\n");
                errorDetails.append("STACK TRACE:\n");
                for (StackTraceElement element : ex.getStackTrace()) {
                    errorDetails.append("  ").append(element.toString()).append("\n");
                }
                // In ra console
                System.err.println(errorDetails.toString());
                ex.printStackTrace();
            }
        }
        if (message != null) {
            errorDetails.append("ERROR MESSAGE: ").append(message).append("\n");
        }
        errorDetails.append("========================================\n");
        
        // In ra console
        System.err.println(errorDetails.toString());
        
        // Trả về error details trong response để dễ debug
        return ResponseEntity.status(status != null ? 
            HttpStatus.valueOf(Integer.valueOf(status.toString())) : 
            HttpStatus.INTERNAL_SERVER_ERROR)
            .body("<html><body><h1>Error " + status + "</h1><pre>" + 
                  errorDetails.toString().replace("<", "&lt;").replace(">", "&gt;") + 
                  "</pre></body></html>");
    }
}

