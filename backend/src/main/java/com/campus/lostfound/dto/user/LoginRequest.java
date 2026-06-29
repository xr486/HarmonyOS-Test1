package com.campus.lostfound.dto.user;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequest {

    @NotBlank(message = "登录类型不能为空")
    private String loginType;

    private String account;

    private String password;

    private String phone;

    private String code;
}
