package com.campus.lostfound.dto.user;

import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateUserRequest {

    @Size(max = 20, message = "昵称最多20个字符")
    private String name;

    private String avatar;

    @Size(max = 100, message = "邮箱最多100个字符")
    private String email;

    private Integer gender;
}
