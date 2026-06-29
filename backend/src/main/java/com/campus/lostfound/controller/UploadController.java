package com.campus.lostfound.controller;

import com.campus.lostfound.common.Result;
import com.campus.lostfound.dto.upload.UploadImageResponse;
import com.campus.lostfound.service.UploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/upload")
@RequiredArgsConstructor
public class UploadController {

    private final UploadService uploadService;

    @PostMapping("/image")
    public Result<UploadImageResponse> uploadImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "type", required = false) String type) {
        UploadImageResponse response = uploadService.uploadImage(file, type);
        return Result.success("上传成功", response);
    }
}
