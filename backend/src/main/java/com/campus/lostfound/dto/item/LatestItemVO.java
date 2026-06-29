package com.campus.lostfound.dto.item;

import lombok.Data;

@Data
public class LatestItemVO {

    private String id;
    private Integer type;
    private String title;
    private Long publishTime;
}
