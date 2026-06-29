package com.campus.lostfound.dto.item;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ResolveItemResponse {

    private Integer status;
    private Long claimTime;
}
