package com.campus.lostfound.repository;

import com.campus.lostfound.entity.LostFoundItem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LostFoundItemRepository extends JpaRepository<LostFoundItem, String>, JpaSpecificationExecutor<LostFoundItem> {

    Optional<LostFoundItem> findByIdAndDeleted(String id, Integer deleted);

    Page<LostFoundItem> findByDeleted(Integer deleted, Pageable pageable);

    List<LostFoundItem> findTopNByStatusAndDeletedOrderByPublishTimeDesc(Integer status, Integer deleted, Pageable pageable);

    Page<LostFoundItem> findByPublisherIdAndDeleted(String publisherId, Integer deleted, Pageable pageable);

    Page<LostFoundItem> findByPublisherIdAndStatusAndDeleted(String publisherId, Integer status, Integer deleted, Pageable pageable);

    @Modifying
    @Query("UPDATE LostFoundItem i SET i.viewCount = i.viewCount + 1 WHERE i.id = :id")
    void incrementViewCount(@Param("id") String id);
}
