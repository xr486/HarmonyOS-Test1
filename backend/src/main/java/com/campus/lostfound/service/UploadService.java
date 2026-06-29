package com.campus.lostfound.service;

import cn.hutool.core.date.DateUtil;
import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.campus.lostfound.common.BusinessException;
import com.campus.lostfound.dto.upload.UploadImageResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Slf4j
@Service
public class UploadService {

    @Value("${upload.path}")
    private String uploadPath;

    @Value("${upload.allowed-types}")
    private String allowedTypes;

    @Value("${upload.max-size}")
    private Long maxSize;

    public UploadImageResponse uploadImage(MultipartFile file, String type) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(400, "请选择要上传的图片");
        }

        String originalFilename = file.getOriginalFilename();
        if (StrUtil.isBlank(originalFilename)) {
            throw new BusinessException(400, "文件名不能为空");
        }

        String ext = FileUtil.extName(originalFilename).toLowerCase();
        List<String> allowedList = Arrays.asList(allowedTypes.toLowerCase().split(","));
        if (!allowedList.contains(ext)) {
            throw new BusinessException(400, "不支持的图片格式，仅支持 " + allowedTypes);
        }

        if (file.getSize() > maxSize) {
            throw new BusinessException(413, "图片大小不能超过 " + (maxSize / 1024 / 1024) + "MB");
        }

        String datePath = DateUtil.format(new Date(), "yyyy/MM/dd");
        String saveDir = uploadPath + File.separator + datePath;
        FileUtil.mkdir(saveDir);

        String fileName = IdUtil.simpleUUID() + "." + ext;
        String savePath = saveDir + File.separator + fileName;

        try {
            file.transferTo(new File(savePath));

            int width = 0;
            int height = 0;
            try {
                BufferedImage image = ImageIO.read(new File(savePath));
                if (image != null) {
                    width = image.getWidth();
                    height = image.getHeight();
                }
            } catch (IOException e) {
                log.warn("读取图片尺寸失败", e);
            }

            String fileType = StrUtil.isNotBlank(type) ? type : "item";
            String url = "/uploads/" + datePath + "/" + fileName;

            log.info("图片上传成功: url={}, size={}, width={}, height={}", url, file.getSize(), width, height);

            return new UploadImageResponse(url, file.getSize(), width, height);
        } catch (IOException e) {
            log.error("图片上传失败", e);
            throw new BusinessException(500, "图片上传失败，请重试");
        }
    }
}
