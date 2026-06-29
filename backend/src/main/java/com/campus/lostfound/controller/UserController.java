package com.campus.lostfound.controller;

import com.campus.lostfound.common.Result;
import com.campus.lostfound.common.UserContext;
import com.campus.lostfound.dto.user.*;
import com.campus.lostfound.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/auth/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = userService.login(request);
        return Result.success(response);
    }

    @GetMapping("/user/info")
    public Result<UserInfoVO> getUserInfo() {
        String userId = UserContext.getUserId();
        UserInfoVO userInfo = userService.getUserInfo(userId);
        return Result.success(userInfo);
    }

    @PutMapping("/user/info")
    public Result<Void> updateUserInfo(@Valid @RequestBody UpdateUserRequest request) {
        String userId = UserContext.getUserId();
        userService.updateUserInfo(userId, request);
        return Result.success("更新成功", null);
    }

    @PutMapping("/user/password")
    public Result<Void> updatePassword(@Valid @RequestBody UpdatePasswordRequest request) {
        String userId = UserContext.getUserId();
        userService.updatePassword(userId, request);
        return Result.success("修改成功", null);
    }
}
