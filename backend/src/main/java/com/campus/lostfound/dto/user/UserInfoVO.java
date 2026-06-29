package com.campus.lostfound.dto.user;

import lombok.Data;

@Data
public class UserInfoVO {

    private String id;
    private String name;
    private String avatar;
    private String phone;
    private String studentId;
    private String email;
    private Integer gender;
    private Long createTime;
    private Long lastLoginTime;
}
