package com.campus.lostfound.service;

import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.campus.lostfound.common.BusinessException;
import com.campus.lostfound.common.PageResult;
import com.campus.lostfound.dto.item.*;
import com.campus.lostfound.entity.LostFoundItem;
import com.campus.lostfound.repository.LostFoundItemRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class ItemService {

    private final LostFoundItemRepository itemRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public PageResult<ItemVO> getItemList(Integer type, Integer category, Integer status,
                                          String keyword, int pageNum, int pageSize,
                                          String sortBy, String sortOrder) {
        Sort sort = Sort.by("desc".equalsIgnoreCase(sortOrder) ? Sort.Direction.DESC : Sort.Direction.ASC,
                sortBy != null ? sortBy : "publishTime");
        Pageable pageable = PageRequest.of(pageNum - 1, pageSize, sort);

        Specification<LostFoundItem> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("deleted"), 0));

            if (type != null) {
                predicates.add(cb.equal(root.get("type"), type));
            }
            if (category != null) {
                predicates.add(cb.equal(root.get("category"), category));
            }
            if (status != null && status != -1) {
                predicates.add(cb.equal(root.get("status"), status));
            }
            if (StrUtil.isNotBlank(keyword)) {
                String pattern = "%" + keyword + "%";
                predicates.add(cb.or(
                        cb.like(root.get("title"), pattern),
                        cb.like(root.get("description"), pattern),
                        cb.like(root.get("location"), pattern)
                ));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        Page<LostFoundItem> page = itemRepository.findAll(spec, pageable);
        List<ItemVO> voList = page.getContent().stream()
                .map(item -> convertToItemVO(item, false))
                .toList();

        return PageResult.of(voList, page.getTotalElements(), pageNum, pageSize);
    }

    @Transactional
    public ItemVO getItemDetail(String id, String currentUserId) {
        LostFoundItem item = itemRepository.findByIdAndDeleted(id, 0)
                .orElseThrow(() -> new BusinessException(404, "物品不存在"));

        itemRepository.incrementViewCount(id);

        boolean isMine = currentUserId != null && currentUserId.equals(item.getPublisherId());
        return convertToItemVO(item, isMine);
    }

    @Transactional
    public CreateItemResponse createItem(CreateItemRequest request, String userId, String userName) {
        LostFoundItem item = new LostFoundItem();
        item.setId(IdUtil.simpleUUID());
        item.setType(request.getType());
        item.setCategory(request.getCategory());
        item.setTitle(request.getTitle());
        item.setDescription(request.getDescription());
        item.setLocation(request.getLocation());
        item.setContact(request.getContact());
        item.setPublisherId(userId);
        item.setPublisherName(userName);
        item.setImages(imagesToJson(request.getImages()));

        itemRepository.save(item);

        return new CreateItemResponse(item.getId(), item.getPublishTime());
    }

    @Transactional
    public void updateItem(String id, UpdateItemRequest request, String userId) {
        LostFoundItem item = itemRepository.findByIdAndDeleted(id, 0)
                .orElseThrow(() -> new BusinessException(404, "物品不存在"));

        if (!userId.equals(item.getPublisherId())) {
            throw new BusinessException(403, "无权限操作");
        }

        if (item.getStatus() != 0) {
            throw new BusinessException(400, "已完成的信息不能编辑");
        }

        if (request.getType() != null) {
            item.setType(request.getType());
        }
        if (request.getCategory() != null) {
            item.setCategory(request.getCategory());
        }
        if (request.getTitle() != null) {
            item.setTitle(request.getTitle());
        }
        if (request.getDescription() != null) {
            item.setDescription(request.getDescription());
        }
        if (request.getLocation() != null) {
            item.setLocation(request.getLocation());
        }
        if (request.getContact() != null) {
            item.setContact(request.getContact());
        }
        if (request.getImages() != null) {
            item.setImages(imagesToJson(request.getImages()));
        }

        itemRepository.save(item);
    }

    @Transactional
    public void deleteItem(String id, String userId) {
        LostFoundItem item = itemRepository.findByIdAndDeleted(id, 0)
                .orElseThrow(() -> new BusinessException(404, "物品不存在"));

        if (!userId.equals(item.getPublisherId())) {
            throw new BusinessException(403, "无权限操作");
        }

        item.setDeleted(1);
        itemRepository.save(item);
    }

    @Transactional
    public ResolveItemResponse resolveItem(String id, String userId) {
        LostFoundItem item = itemRepository.findByIdAndDeleted(id, 0)
                .orElseThrow(() -> new BusinessException(404, "物品不存在"));

        if (!userId.equals(item.getPublisherId())) {
            throw new BusinessException(403, "无权限操作");
        }

        if (item.getStatus() != 0) {
            throw new BusinessException(400, "该物品已完成");
        }

        int newStatus = (item.getType() == 0) ? 2 : 1;
        item.setStatus(newStatus);
        item.setClaimTime(System.currentTimeMillis());

        itemRepository.save(item);

        return new ResolveItemResponse(newStatus, item.getClaimTime());
    }

    public List<LatestItemVO> getLatestItems(int count) {
        int actualCount = Math.min(count, 20);
        Pageable pageable = PageRequest.of(0, actualCount, Sort.by(Sort.Direction.DESC, "publishTime"));

        Specification<LostFoundItem> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("deleted"), 0));
            predicates.add(cb.equal(root.get("status"), 0));
            return cb.and(predicates.toArray(new Predicate[0]));
        };

        List<LostFoundItem> items = itemRepository.findAll(spec, pageable).getContent();
        return items.stream().map(item -> {
            LatestItemVO vo = new LatestItemVO();
            vo.setId(item.getId());
            vo.setType(item.getType());
            vo.setTitle(item.getTitle());
            vo.setPublishTime(item.getPublishTime());
            return vo;
        }).toList();
    }

    public PageResult<ItemVO> getMyItems(String userId, Integer status, int pageNum, int pageSize) {
        Pageable pageable = PageRequest.of(pageNum - 1, pageSize, Sort.by(Sort.Direction.DESC, "publishTime"));

        Specification<LostFoundItem> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("deleted"), 0));
            predicates.add(cb.equal(root.get("publisherId"), userId));

            if (status != null && status != -1) {
                predicates.add(cb.equal(root.get("status"), status));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };

        Page<LostFoundItem> page = itemRepository.findAll(spec, pageable);
        List<ItemVO> voList = page.getContent().stream()
                .map(item -> convertToItemVO(item, true))
                .toList();

        return PageResult.of(voList, page.getTotalElements(), pageNum, pageSize);
    }

    private ItemVO convertToItemVO(LostFoundItem item, boolean isMine) {
        ItemVO vo = new ItemVO();
        BeanUtils.copyProperties(item, vo);
        vo.setImages(jsonToImages(item.getImages()));
        vo.setIsMine(isMine);
        return vo;
    }

    private String imagesToJson(List<String> images) {
        if (images == null || images.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(images);
        } catch (JsonProcessingException e) {
            return null;
        }
    }

    private List<String> jsonToImages(String json) {
        if (StrUtil.isBlank(json)) {
            return Collections.emptyList();
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<String>>() {});
        } catch (JsonProcessingException e) {
            return Collections.emptyList();
        }
    }
}
