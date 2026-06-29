package com.campus.lostfound.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "claim_record")
public class ClaimRecord {

    @Id
    @Column(name = "id", length = 32)
    private String id;

    @Column(name = "item_id", length = 32, nullable = false)
    private String itemId;

    @Column(name = "claimant_id", length = 32, nullable = false)
    private String claimantId;

    @Column(name = "claimant_name", length = 20, nullable = false)
    private String claimantName;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "status")
    private Integer status;

    @Column(name = "audit_remark", length = 200)
    private String auditRemark;

    @Column(name = "create_time", nullable = false)
    private Long createTime;

    @Column(name = "audit_time")
    private Long auditTime;

    @PrePersist
    public void prePersist() {
        if (this.createTime == null) {
            this.createTime = System.currentTimeMillis();
        }
        if (this.status == null) {
            this.status = 0;
        }
    }
}
