package com.campus.lostfound;

import com.campus.lostfound.dto.item.CreateItemRequest;
import com.campus.lostfound.dto.user.LoginRequest;
import com.campus.lostfound.dto.user.LoginResponse;
import com.campus.lostfound.service.ItemService;
import com.campus.lostfound.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Collections;
import java.util.concurrent.atomic.AtomicReference;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@TestMethodOrder(MethodOrderer.MethodName.class)
class LostFoundApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private static final AtomicReference<String> tokenRef = new AtomicReference<>();

    @BeforeEach
    void setUp() throws Exception {
        if (tokenRef.get() == null) {
            LoginRequest loginRequest = new LoginRequest();
            loginRequest.setLoginType("password");
            loginRequest.setAccount("2021009999");
            loginRequest.setPassword("123456");

            MvcResult result = mockMvc.perform(post("/auth/login")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content(objectMapper.writeValueAsString(loginRequest)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.code").value(200))
                    .andReturn();

            String responseBody = result.getResponse().getContentAsString();
            LoginResponse loginResponse = objectMapper.readValue(
                    objectMapper.readTree(responseBody).get("data").toString(),
                    LoginResponse.class
            );
            tokenRef.set(loginResponse.getToken());
            assertNotNull(loginResponse.getToken());
        }
    }

    private String getToken() {
        return tokenRef.get();
    }

    @Test
    void contextLoads() {
    }

    @Test
    void testLogin() throws Exception {
        LoginRequest loginRequest = new LoginRequest();
        loginRequest.setLoginType("password");
        loginRequest.setAccount("2021001002");
        loginRequest.setPassword("123456");

        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.token").exists())
                .andExpect(jsonPath("$.data.userInfo.id").exists());
    }

    @Test
    void testGetUserInfo() throws Exception {
        mockMvc.perform(get("/user/info")
                        .header("Authorization", "Bearer " + getToken()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.name").exists());
    }

    @Test
    void testUpdateUserInfo() throws Exception {
        String requestBody = "{\"name\":\"测试用户\",\"gender\":1}";

        mockMvc.perform(put("/user/info")
                        .header("Authorization", "Bearer " + getToken())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void testCreateItem() throws Exception {
        CreateItemRequest request = new CreateItemRequest();
        request.setType(0);
        request.setCategory(1);
        request.setTitle("测试丢失校园卡");
        request.setDescription("在图书馆三楼自习室丢失一张校园卡，卡主姓名：测试，学号：2021001001");
        request.setLocation("图书馆三楼");
        request.setContact("13800138001");
        request.setImages(Collections.emptyList());

        mockMvc.perform(post("/items")
                        .header("Authorization", "Bearer " + getToken())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").exists());
    }

    @Test
    void testGetItemList() throws Exception {
        mockMvc.perform(get("/items")
                        .param("pageNum", "1")
                        .param("pageSize", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.list").isArray())
                .andExpect(jsonPath("$.data.total").exists());
    }

    @Test
    void testGetLatestItems() throws Exception {
        mockMvc.perform(get("/items/latest")
                        .param("count", "5"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data").isArray());
    }

    @Test
    void testItemCRUD() throws Exception {
        CreateItemRequest createRequest = new CreateItemRequest();
        createRequest.setType(1);
        createRequest.setCategory(2);
        createRequest.setTitle("测试捡到手机");
        createRequest.setDescription("在操场捡到一部手机，请失主联系我认领。");
        createRequest.setLocation("操场");
        createRequest.setContact("13900139002");
        createRequest.setImages(Collections.emptyList());

        MvcResult createResult = mockMvc.perform(post("/items")
                        .header("Authorization", "Bearer " + getToken())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andReturn();

        String itemId = objectMapper.readTree(createResult.getResponse().getContentAsString())
                .get("data").get("id").asText();
        assertNotNull(itemId);

        mockMvc.perform(get("/items/" + itemId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.id").value(itemId));

        String updateBody = "{\"title\":\"测试捡到手机（更新）\",\"location\":\"操场看台\"}";
        mockMvc.perform(put("/items/" + itemId)
                        .header("Authorization", "Bearer " + getToken())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updateBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));

        mockMvc.perform(get("/items/my")
                        .header("Authorization", "Bearer " + getToken())
                        .param("pageNum", "1")
                        .param("pageSize", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));

        mockMvc.perform(put("/items/" + itemId + "/resolve")
                        .header("Authorization", "Bearer " + getToken()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.status").exists());

        mockMvc.perform(delete("/items/" + itemId)
                        .header("Authorization", "Bearer " + getToken()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void testUnauthorizedAccess() throws Exception {
        mockMvc.perform(get("/user/info"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(401));
    }

    @Test
    void testInvalidToken() throws Exception {
        mockMvc.perform(get("/user/info")
                        .header("Authorization", "Bearer invalid_token"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(401));
    }
}
