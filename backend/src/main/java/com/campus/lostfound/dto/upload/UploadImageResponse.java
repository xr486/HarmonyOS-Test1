package com.campus.lostfound.dto.upload;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UploadImageResponse {

    private String url;
    private Long size;
    private Integer width;
    private Integer height;
}
