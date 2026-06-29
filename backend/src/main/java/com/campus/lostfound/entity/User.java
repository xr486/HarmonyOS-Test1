package com.campus.lostfound.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "sys_user")
public class User {

    @Id
    @Column(name = "id", length = 32)
    private String id;

    @Column(name = "open_id", length = 64)
    private String openId;

    @Column(name = "name", length = 20, nullable = false)
    private String name;

    @Column(name = "avatar", length = 255)
    private String avatar;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "student_id", length = 20)
    private String studentId;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "password", length = 100)
    private String password;

    @Column(name = "gender")
    private Integer gender;

    @Column(name = "status")
    private Integer status;

    @Column(name = "deleted")
    private Integer deleted;

    @Column(name = "create_time", nullable = false)
    private Long createTime;

    @Column(name = "update_time", nullable = false)
    private Long updateTime;

    @Column(name = "last_login_time")
    private Long lastLoginTime;

    @PrePersist
    public void prePersist() {
        long now = System.currentTimeMillis();
        if (this.createTime == null) {
            this.createTime = now;
        }
        if (this.updateTime == null) {
            this.updateTime = now;
        }
        if (this.status == null) {
            this.status = 0;
        }
        if (this.deleted == null) {
            this.deleted = 0;
        }
        if (this.gender == null) {
            this.gender = 0;
        }
    }

    @PreUpdate
    public void preUpdate() {
        this.updateTime = System.currentTimeMillis();
    }
}
