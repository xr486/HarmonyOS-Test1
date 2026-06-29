package com.campus.lostfound.dto.item;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;

@Data
public class CreateItemRequest {

    @NotNull(message = "类型不能为空")
    private Integer type;

    @NotNull(message = "分类不能为空")
    private Integer category;

    @NotBlank(message = "标题不能为空")
    @Size(min = 2, max = 50, message = "标题长度为2-50个字符")
    private String title;

    @NotBlank(message = "描述不能为空")
    @Size(min = 10, max = 500, message = "描述长度为10-500个字符")
    private String description;

    @NotBlank(message = "地点不能为空")
    @Size(min = 2, max = 100, message = "地点长度为2-100个字符")
    private String location;

    @NotBlank(message = "联系方式不能为空")
    @Size(min = 2, max = 50, message = "联系方式长度为2-50个字符")
    private String contact;

    private List<String> images;
}
