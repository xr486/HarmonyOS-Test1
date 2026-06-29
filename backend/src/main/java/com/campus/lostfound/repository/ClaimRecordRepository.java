package com.campus.lostfound.repository;

import com.campus.lostfound.entity.ClaimRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClaimRecordRepository extends JpaRepository<ClaimRecord, String>, JpaSpecificationExecutor<ClaimRecord> {

    List<ClaimRecord> findByItemId(String itemId);

    List<ClaimRecord> findByClaimantId(String claimantId);
}
