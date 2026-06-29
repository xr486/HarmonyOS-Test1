package com.campus.lostfound.dto.item;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateItemResponse {

    private String id;
    private Long publishTime;
}
