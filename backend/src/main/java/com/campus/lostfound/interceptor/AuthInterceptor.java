package com.campus.lostfound.interceptor;

import com.campus.lostfound.common.BusinessException;
import com.campus.lostfound.common.UserContext;
import com.campus.lostfound.util.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Slf4j
@Component
@RequiredArgsConstructor
public class AuthInterceptor implements HandlerInterceptor {

    private final JwtUtil jwtUtil;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String uri = request.getRequestURI();
        String method = request.getMethod();

        if (isWhitelist(uri, method)) {
            return true;
        }

        String token = request.getHeader("Authorization");

        if (token == null || token.isEmpty()) {
            throw new BusinessException(401, "未登录，请先登录");
        }

        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }

        Claims claims = jwtUtil.parseToken(token);
        if (claims == null) {
            throw new BusinessException(401, "Token无效或已过期");
        }

        String userId = claims.get("userId", String.class);
        String userName = claims.get("userName", String.class);

        if (userId == null || userName == null) {
            throw new BusinessException(401, "Token信息不完整");
        }

        UserContext.setUserId(userId);
        UserContext.setUserName(userName);

        return true;
    }

    private boolean isWhitelist(String uri, String method) {
        if ("GET".equalsIgnoreCase(method)) {
            if (uri.endsWith("/items") || uri.endsWith("/items/latest")) {
                return true;
            }
            String[] parts = uri.split("/");
            if (parts.length >= 2) {
                String lastPart = parts[parts.length - 1];
                String secondLast = parts[parts.length - 2];
                if ("items".equals(secondLast) && !"my".equals(lastPart)) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        UserContext.clear();
    }
}
