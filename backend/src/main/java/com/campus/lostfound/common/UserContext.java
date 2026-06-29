package com.campus.lostfound.common;

public class UserContext {

    private static final ThreadLocal<String> currentUserId = new ThreadLocal<>();
    private static final ThreadLocal<String> currentUserName = new ThreadLocal<>();

    public static void setUserId(String userId) {
        currentUserId.set(userId);
    }

    public static String getUserId() {
        return currentUserId.get();
    }

    public static void setUserName(String userName) {
        currentUserName.set(userName);
    }

    public static String getUserName() {
        return currentUserName.get();
    }

    public static void clear() {
        currentUserId.remove();
        currentUserName.remove();
    }
}
