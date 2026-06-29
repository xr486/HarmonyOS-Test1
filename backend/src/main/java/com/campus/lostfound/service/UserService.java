package com.campus.lostfound.service;

import cn.hutool.core.util.IdUtil;
import cn.hutool.crypto.SecureUtil;
import com.campus.lostfound.common.BusinessException;
import com.campus.lostfound.dto.user.*;
import com.campus.lostfound.entity.User;
import com.campus.lostfound.repository.UserRepository;
import com.campus.lostfound.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;

    @Transactional
    public LoginResponse login(LoginRequest request) {
        String loginType = request.getLoginType();

        User user;
        if ("password".equals(loginType)) {
            if (request.getAccount() == null || request.getPassword() == null) {
                throw new BusinessException(400, "账号和密码不能为空");
            }
            user = userRepository.findByStudentIdAndDeleted(request.getAccount(), 0)
                    .orElse(null);

            if (user == null) {
                user = registerDefaultUser(request.getAccount(), request.getPassword());
            } else {
                if (!encryptPassword(request.getPassword()).equals(user.getPassword())) {
                    throw new BusinessException(400, "密码错误");
                }
                if (user.getStatus() == 1) {
                    throw new BusinessException(403, "账号已被禁用");
                }
            }
        } else if ("sms".equals(loginType)) {
            if (request.getPhone() == null || request.getCode() == null) {
                throw new BusinessException(400, "手机号和验证码不能为空");
            }
            if (!"123456".equals(request.getCode())) {
                throw new BusinessException(400, "验证码错误");
            }
            user = userRepository.findByPhoneAndDeleted(request.getPhone(), 0)
                    .orElseGet(() -> registerUserByPhone(request.getPhone()));
        } else {
            throw new BusinessException(400, "不支持的登录类型");
        }

        user.setLastLoginTime(System.currentTimeMillis());
        userRepository.save(user);

        String token = jwtUtil.generateToken(user.getId(), user.getName());
        long expireTime = jwtUtil.getExpireTime();

        UserInfoVO userInfoVO = convertToUserInfoVO(user);
        return new LoginResponse(token, expireTime, userInfoVO);
    }

    private User registerDefaultUser(String studentId, String password) {
        User user = new User();
        user.setId(IdUtil.simpleUUID());
        user.setStudentId(studentId);
        user.setName("用户" + studentId.substring(studentId.length() - 4));
        user.setPassword(encryptPassword(password));
        user.setStatus(0);
        user.setDeleted(0);
        user.setGender(0);
        return userRepository.save(user);
    }

    private User registerUserByPhone(String phone) {
        User user = new User();
        user.setId(IdUtil.simpleUUID());
        user.setPhone(phone);
        user.setName("用户" + phone.substring(phone.length() - 4));
        user.setStatus(0);
        user.setDeleted(0);
        user.setGender(0);
        return userRepository.save(user);
    }

    public UserInfoVO getUserInfo(String userId) {
        User user = userRepository.findByIdAndDeleted(userId, 0)
                .orElseThrow(() -> new BusinessException(404, "用户不存在"));
        return convertToUserInfoVO(user);
    }

    @Transactional
    public void updateUserInfo(String userId, UpdateUserRequest request) {
        User user = userRepository.findByIdAndDeleted(userId, 0)
                .orElseThrow(() -> new BusinessException(404, "用户不存在"));

        if (request.getName() != null) {
            user.setName(request.getName());
        }
        if (request.getAvatar() != null) {
            user.setAvatar(request.getAvatar());
        }
        if (request.getEmail() != null) {
            user.setEmail(request.getEmail());
        }
        if (request.getGender() != null) {
            user.setGender(request.getGender());
        }

        userRepository.save(user);
    }

    @Transactional
    public void updatePassword(String userId, UpdatePasswordRequest request) {
        User user = userRepository.findByIdAndDeleted(userId, 0)
                .orElseThrow(() -> new BusinessException(404, "用户不存在"));

        if (user.getPassword() == null) {
            user.setPassword(encryptPassword(request.getNewPassword()));
        } else {
            if (!encryptPassword(request.getOldPassword()).equals(user.getPassword())) {
                throw new BusinessException(400, "旧密码错误");
            }
            user.setPassword(encryptPassword(request.getNewPassword()));
        }

        userRepository.save(user);
    }

    private UserInfoVO convertToUserInfoVO(User user) {
        UserInfoVO vo = new UserInfoVO();
        BeanUtils.copyProperties(user, vo);
        return vo;
    }

    private String encryptPassword(String password) {
        return SecureUtil.md5(password + "campus_lost_found_salt");
    }
}
