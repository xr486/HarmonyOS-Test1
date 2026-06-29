package com.campus.lostfound.controller;

import com.campus.lostfound.common.PageResult;
import com.campus.lostfound.common.Result;
import com.campus.lostfound.common.UserContext;
import com.campus.lostfound.dto.item.*;
import com.campus.lostfound.service.ItemService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/items")
@RequiredArgsConstructor
public class ItemController {

    private final ItemService itemService;

    @GetMapping
    public Result<PageResult<ItemVO>> getItemList(
            @RequestParam(required = false) Integer type,
            @RequestParam(required = false) Integer category,
            @RequestParam(required = false, defaultValue = "0") Integer status,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false, defaultValue = "1") int pageNum,
            @RequestParam(required = false, defaultValue = "20") int pageSize,
            @RequestParam(required = false, defaultValue = "publishTime") String sortBy,
            @RequestParam(required = false, defaultValue = "desc") String sortOrder) {
        PageResult<ItemVO> result = itemService.getItemList(type, category, status, keyword,
                pageNum, pageSize, sortBy, sortOrder);
        return Result.success(result);
    }

    @GetMapping("/latest")
    public Result<List<LatestItemVO>> getLatestItems(
            @RequestParam(required = false, defaultValue = "5") int count) {
        List<LatestItemVO> result = itemService.getLatestItems(count);
        return Result.success(result);
    }

    @GetMapping("/my")
    public Result<PageResult<ItemVO>> getMyItems(
            @RequestParam(required = false, defaultValue = "-1") Integer status,
            @RequestParam(required = false, defaultValue = "1") int pageNum,
            @RequestParam(required = false, defaultValue = "20") int pageSize) {
        String userId = UserContext.getUserId();
        PageResult<ItemVO> result = itemService.getMyItems(userId, status, pageNum, pageSize);
        return Result.success(result);
    }

    @GetMapping("/{id}")
    public Result<ItemVO> getItemDetail(@PathVariable String id) {
        String userId = UserContext.getUserId();
        ItemVO result = itemService.getItemDetail(id, userId);
        return Result.success(result);
    }

    @PostMapping
    public Result<CreateItemResponse> createItem(@Valid @RequestBody CreateItemRequest request) {
        String userId = UserContext.getUserId();
        String userName = UserContext.getUserName();
        CreateItemResponse response = itemService.createItem(request, userId, userName);
        return Result.success("发布成功", response);
    }

    @PutMapping("/{id}")
    public Result<Void> updateItem(@PathVariable String id, @Valid @RequestBody UpdateItemRequest request) {
        String userId = UserContext.getUserId();
        itemService.updateItem(id, request, userId);
        return Result.success("更新成功", null);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteItem(@PathVariable String id) {
        String userId = UserContext.getUserId();
        itemService.deleteItem(id, userId);
        return Result.success("删除成功", null);
    }

    @PutMapping("/{id}/resolve")
    public Result<ResolveItemResponse> resolveItem(@PathVariable String id) {
        String userId = UserContext.getUserId();
        ResolveItemResponse response = itemService.resolveItem(id, userId);
        return Result.success("操作成功", response);
    }
}
