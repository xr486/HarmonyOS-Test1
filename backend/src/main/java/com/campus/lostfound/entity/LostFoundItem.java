package com.campus.lostfound.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "lost_found_item")
public class LostFoundItem {

    @Id
    @Column(name = "id", length = 32)
    private String id;

    @Column(name = "type", nullable = false)
    private Integer type;

    @Column(name = "category", nullable = false)
    private Integer category;

    @Column(name = "title", length = 50, nullable = false)
    private String title;

    @Column(name = "description", length = 500, nullable = false)
    private String description;

    @Column(name = "location", length = 100, nullable = false)
    private String location;

    @Column(name = "contact", length = 50, nullable = false)
    private String contact;

    @Column(name = "images", length = 2000)
    private String images;

    @Column(name = "publisher_id", length = 32, nullable = false)
    private String publisherId;

    @Column(name = "publisher_name", length = 20, nullable = false)
    private String publisherName;

    @Column(name = "publisher_avatar", length = 255)
    private String publisherAvatar;

    @Column(name = "status")
    private Integer status;

    @Column(name = "view_count")
    private Integer viewCount;

    @Column(name = "claim_time")
    private Long claimTime;

    @Column(name = "deleted")
    private Integer deleted;

    @Column(name = "publish_time", nullable = false)
    private Long publishTime;

    @Column(name = "update_time", nullable = false)
    private Long updateTime;

    @PrePersist
    public void prePersist() {
        long now = System.currentTimeMillis();
        if (this.publishTime == null) {
            this.publishTime = now;
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
        if (this.viewCount == null) {
            this.viewCount = 0;
        }
    }

    @PreUpdate
    public void preUpdate() {
        this.updateTime = System.currentTimeMillis();
    }
}
