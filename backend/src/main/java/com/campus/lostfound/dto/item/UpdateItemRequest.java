package com.campus.lostfound.dto.item;

import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class UpdateItemRequest {

    private Integer type;

    private Integer category;

    @Size(min = 2, max = 50, message = "标题长度为2-50个字符")
    private String title;

    @Size(min = 10, max = 500, message = "描述长度为10-500个字符")
    private String description;

    @Size(min = 2, max = 100, message = "地点长度为2-100个字符")
    private String location;

    @Size(min = 2, max = 50, message = "联系方式长度为2-50个字符")
    private String contact;

    private List<String> images;
}
