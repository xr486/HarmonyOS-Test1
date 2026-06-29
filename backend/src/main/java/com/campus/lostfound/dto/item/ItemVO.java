package com.campus.lostfound.dto.item;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.SneakyThrows;

import java.util.Collections;
import java.util.List;

@Data
public class ItemVO {

    private String id;
    private Integer type;
    private Integer category;
    private String title;
    private String description;
    private String location;
    private String contact;
    private List<String> images;
    private String publisherId;
    private String publisherName;
    private String publisherAvatar;
    private Integer status;
    private Long publishTime;
    private Long updateTime;
    private Integer viewCount;
    private Long claimTime;
    private Boolean isMine;
}
