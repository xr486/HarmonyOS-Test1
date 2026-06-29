# 校园失物招领 - API 接口设计文档

> 版本：v1.0.0  
> 更新日期：2026-06-29  
> 本文档用于前端（鸿蒙 ArkTS）与后端（Spring Boot）联调参考

---

## 目录

1. [概述](#1-概述)
2. [数据模型](#2-数据模型)
3. [API 接口列表](#3-api-接口列表)
4. [接口详细说明](#4-接口详细说明)
5. [状态码定义](#5-状态码定义)
6. [前端待开发任务](#6-前端待开发任务)
7. [后端待开发任务](#7-后端待开发任务)
8. [联调注意事项](#8-联调注意事项)

---

## 1. 概述

### 1.1 项目背景

针对校园内失物招领信息分散、查找效率低的问题，搭建统一的校园失物招领平台。

### 1.2 技术栈

| 端 | 技术栈 |
|----|--------|
| 前端 | HarmonyOS NEXT + ArkTS + AppGallery Connect 云服务 |
| 后端 | Spring Boot + Spring Data JPA + MySQL + Redis |
| 云存储 | AGC 云存储 / 阿里云 OSS |

### 1.3 接口规范

- **Base URL**：`https://api.campus-lostandfound.com/api/v1`
- **请求方式**：RESTful API
- **数据格式**：JSON
- **字符编码**：UTF-8
- **鉴权方式**：JWT Token（放在请求头 `Authorization: Bearer <token>`）

### 1.4 通用响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1719648000000
}
```

### 1.5 分页响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "list": [],
    "total": 100,
    "pageNum": 1,
    "pageSize": 20,
    "totalPages": 5
  },
  "timestamp": 1719648000000
}
```

---

## 2. 数据模型

### 2.1 物品信息（LostFoundItem）

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 物品ID（主键，雪花算法/UUID） |
| type | integer | 是 | 类型：0=寻物启事，1=失物招领 |
| category | integer | 是 | 物品分类：1=证件卡片，2=数码产品，3=衣物服饰，4=书籍文具，5=其他物品 |
| title | string | 是 | 标题，最大50字 |
| description | string | 是 | 详细描述，最大500字 |
| location | string | 是 | 丢失/拾取地点，最大100字 |
| contact | string | 是 | 联系方式，最大50字 |
| images | string[] | 否 | 图片URL数组，最多9张 |
| publisherId | string | 是 | 发布者用户ID |
| publisherName | string | 是 | 发布者昵称 |
| publisherAvatar | string | 否 | 发布者头像URL |
| status | integer | 是 | 状态：0=进行中，1=已认领，2=已寻回 |
| publishTime | long | 是 | 发布时间戳（毫秒） |
| updateTime | long | 是 | 更新时间戳（毫秒） |
| viewCount | integer | 否 | 浏览次数，默认0 |
| claimTime | long | 否 | 认领/寻回时间 |

### 2.2 用户信息（User）

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 用户ID（主键） |
| openId | string | 是 | 第三方登录唯一标识（可选，学号也行） |
| name | string | 是 | 昵称，最大20字 |
| avatar | string | 否 | 头像URL |
| phone | string | 否 | 手机号 |
| studentId | string | 否 | 学号 |
| email | string | 否 | 邮箱 |
| gender | integer | 否 | 性别：0=未知，1=男，2=女 |
| createTime | long | 是 | 注册时间 |
| lastLoginTime | long | 否 | 最后登录时间 |
| status | integer | 是 | 状态：0=正常，1=禁用 |

### 2.3 认领记录（ClaimRecord）

> 可选扩展：用于记录认领申请和审核流程

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | string | 是 | 记录ID |
| itemId | string | 是 | 物品ID |
| claimantId | string | 是 | 认领人ID |
| claimantName | string | 是 | 认领人昵称 |
| description | string | 否 | 认领描述（描述物品特征） |
| status | integer | 是 | 状态：0=待审核，1=已通过，2=已拒绝 |
| createTime | long | 是 | 申请时间 |
| auditTime | long | 否 | 审核时间 |
| auditRemark | string | 否 | 审核备注 |

### 2.4 枚举定义

#### 物品类型（ItemType）
```
0 = LOST  （寻物启事）
1 = FOUND （失物招领）
```

#### 物品分类（ItemCategory）
```
1 = CARD     （证件卡片）
2 = DIGITAL  （数码产品）
3 = CLOTHING （衣物服饰）
4 = BOOK     （书籍文具）
5 = OTHER    （其他物品）
```

#### 物品状态（ItemStatus）
```
0 = ACTIVE   （进行中）
1 = CLAIMED  （已认领）
2 = RETURNED （已寻回）
```

---

## 3. API 接口列表

### 3.1 用户模块

| 接口 | 方法 | 路径 | 鉴权 | 说明 |
|------|------|------|------|------|
| 用户登录 | POST | `/auth/login` | 否 | 学号/手机号登录 |
| 获取用户信息 | GET | `/user/info` | 是 | 获取当前登录用户信息 |
| 更新用户信息 | PUT | `/user/info` | 是 | 修改昵称、头像等 |
| 修改密码 | PUT | `/user/password` | 是 | 修改登录密码 |

### 3.2 物品模块

| 接口 | 方法 | 路径 | 鉴权 | 说明 |
|------|------|------|------|------|
| 获取物品列表 | GET | `/items` | 否 | 分页查询，支持筛选和搜索 |
| 获取物品详情 | GET | `/items/{id}` | 否 | 根据ID获取详情 |
| 发布物品 | POST | `/items` | 是 | 发布失物/招领信息 |
| 更新物品 | PUT | `/items/{id}` | 是 | 编辑发布的信息（仅发布者） |
| 删除物品 | DELETE | `/items/{id}` | 是 | 下架/删除信息（仅发布者） |
| 标记完成 | PUT | `/items/{id}/resolve` | 是 | 标记已认领/已寻回 |
| 获取最新动态 | GET | `/items/latest` | 否 | 获取最新N条进行中的信息 |
| 我发布的列表 | GET | `/items/my` | 是 | 获取当前用户发布的所有信息 |

### 3.3 文件模块

| 接口 | 方法 | 路径 | 鉴权 | 说明 |
|------|------|------|------|------|
| 上传图片 | POST | `/upload/image` | 是 | 上传物品图片，返回URL |
| 删除图片 | DELETE | `/upload/image` | 是 | 删除已上传的图片 |

---

## 4. 接口详细说明

### 4.1 用户登录

**接口地址**：`POST /api/v1/auth/login`

**请求参数**：
```json
{
  "loginType": "password",
  "account": "2021001001",
  "password": "123456",
  "phone": "13800138000",
  "code": "123456"
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| loginType | string | 是 | 登录类型：password=密码登录，sms=短信登录 |
| account | string | 否 | 学号/账号（password登录时必填） |
| password | string | 否 | 密码（password登录时必填） |
| phone | string | 否 | 手机号（sms登录时必填） |
| code | string | 否 | 验证码（sms登录时必填） |

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expireTime": 1719734400000,
    "userInfo": {
      "id": "user_001",
      "name": "张三",
      "avatar": "https://xxx.com/avatar.jpg",
      "phone": "138****8000",
      "studentId": "2021001001"
    }
  },
  "timestamp": 1719648000000
}
```

---

### 4.2 获取用户信息

**接口地址**：`GET /api/v1/user/info`

**请求头**：`Authorization: Bearer <token>`

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "user_001",
    "name": "张三",
    "avatar": "https://xxx.com/avatar.jpg",
    "phone": "138****8000",
    "studentId": "2021001001",
    "email": "zhangsan@campus.edu.cn",
    "gender": 1,
    "createTime": 1719000000000,
    "lastLoginTime": 1719648000000
  },
  "timestamp": 1719648000000
}
```

---

### 4.3 获取物品列表

**接口地址**：`GET /api/v1/items`

**请求参数（Query）**：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| type | integer | 否 | - | 类型筛选：0=寻物，1=招领 |
| category | integer | 否 | - | 分类筛选：1-5 |
| status | integer | 否 | 0 | 状态筛选：0=进行中，1=已完成，-1=全部 |
| keyword | string | 否 | - | 搜索关键词（匹配标题、描述、地点） |
| pageNum | integer | 否 | 1 | 页码 |
| pageSize | integer | 否 | 20 | 每页数量 |
| sortBy | string | 否 | publishTime | 排序字段 |
| sortOrder | string | 否 | desc | 排序方向：asc/desc |

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "list": [
      {
        "id": "item_001",
        "type": 0,
        "category": 1,
        "title": "丢失校园卡",
        "description": "在图书馆三楼自习室丢失一张校园卡...",
        "location": "图书馆三楼",
        "contact": "13800138001",
        "images": ["https://xxx.com/img1.jpg"],
        "publisherId": "user_001",
        "publisherName": "张三",
        "publisherAvatar": "https://xxx.com/avatar.jpg",
        "status": 0,
        "publishTime": 1719648000000,
        "viewCount": 128
      }
    ],
    "total": 86,
    "pageNum": 1,
    "pageSize": 20,
    "totalPages": 5
  },
  "timestamp": 1719648000000
}
```

---

### 4.4 获取物品详情

**接口地址**：`GET /api/v1/items/{id}`

**路径参数**：
- `id`：物品ID

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "id": "item_001",
    "type": 0,
    "category": 1,
    "title": "丢失校园卡",
    "description": "在图书馆三楼自习室丢失一张校园卡，卡主姓名：张三，学号：2021001001...",
    "location": "图书馆三楼",
    "contact": "13800138001",
    "images": [
      "https://xxx.com/img1.jpg",
      "https://xxx.com/img2.jpg"
    ],
    "publisherId": "user_001",
    "publisherName": "张三",
    "publisherAvatar": "https://xxx.com/avatar.jpg",
    "status": 0,
    "publishTime": 1719648000000,
    "updateTime": 1719648000000,
    "viewCount": 128,
    "isMine": true
  },
  "timestamp": 1719648000000
}
```

**说明**：
- `isMine`：表示当前登录用户是否为发布者（用于判断是否显示编辑/下架按钮）
- 浏览一次 viewCount + 1

---

### 4.5 发布物品

**接口地址**：`POST /api/v1/items`

**请求头**：`Authorization: Bearer <token>`

**请求参数**：
```json
{
  "type": 0,
  "category": 1,
  "title": "丢失校园卡",
  "description": "在图书馆三楼自习室丢失一张校园卡...",
  "location": "图书馆三楼",
  "contact": "13800138001",
  "images": [
    "https://xxx.com/img1.jpg",
    "https://xxx.com/img2.jpg"
  ]
}
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | integer | 是 | 0=寻物启事，1=失物招领 |
| category | integer | 是 | 物品分类 1-5 |
| title | string | 是 | 标题，2-50字 |
| description | string | 是 | 描述，10-500字 |
| location | string | 是 | 地点，2-100字 |
| contact | string | 是 | 联系方式，2-50字 |
| images | string[] | 否 | 图片URL数组，最多9张 |

**响应数据**：
```json
{
  "code": 200,
  "message": "发布成功",
  "data": {
    "id": "item_100",
    "publishTime": 1719648000000
  },
  "timestamp": 1719648000000
}
```

---

### 4.6 更新物品

**接口地址**：`PUT /api/v1/items/{id}`

**请求头**：`Authorization: Bearer <token>`

**说明**：仅发布者可编辑；进行中状态才能编辑

**请求参数**：同发布接口（所有字段可选，只传要修改的字段）

**响应数据**：
```json
{
  "code": 200,
  "message": "更新成功",
  "data": null,
  "timestamp": 1719648000000
}
```

---

### 4.7 删除/下架物品

**接口地址**：`DELETE /api/v1/items/{id}`

**请求头**：`Authorization: Bearer <token>`

**说明**：仅发布者可删除，软删除（逻辑删除，标记状态）

**响应数据**：
```json
{
  "code": 200,
  "message": "删除成功",
  "data": null,
  "timestamp": 1719648000000
}
```

---

### 4.8 标记完成

**接口地址**：`PUT /api/v1/items/{id}/resolve`

**请求头**：`Authorization: Bearer <token>`

**说明**：
- 仅发布者可操作
- 寻物启事（type=0）标记为「已寻回」（status=2）
- 失物招领（type=1）标记为「已认领」（status=1）

**响应数据**：
```json
{
  "code": 200,
  "message": "操作成功",
  "data": {
    "status": 2,
    "claimTime": 1719648000000
  },
  "timestamp": 1719648000000
}
```

---

### 4.9 获取最新动态

**接口地址**：`GET /api/v1/items/latest`

**请求参数（Query）**：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| count | integer | 否 | 5 | 返回数量，最大20 |

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": "item_001",
      "type": 0,
      "title": "丢失校园卡",
      "publishTime": 1719648000000
    }
  ],
  "timestamp": 1719648000000
}
```

---

### 4.10 我发布的列表

**接口地址**：`GET /api/v1/items/my`

**请求头**：`Authorization: Bearer <token>`

**请求参数（Query）**：

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| status | integer | 否 | -1 | 状态筛选：0=进行中，1=已认领，2=已寻回，-1=全部 |
| pageNum | integer | 否 | 1 | 页码 |
| pageSize | integer | 否 | 20 | 每页数量 |

**响应数据**：同物品列表接口（分页格式）

---

### 4.11 上传图片

**接口地址**：`POST /api/v1/upload/image`

**请求头**：`Authorization: Bearer <token>`

**Content-Type**：`multipart/form-data`

**请求参数**：

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 图片文件 |
| type | string | 否 | 用途类型：item=物品图片，avatar=头像 |

**限制**：
- 支持格式：jpg、jpeg、png、webp
- 单张大小：不超过 5MB
- 单日数量：每个用户最多 50 张

**响应数据**：
```json
{
  "code": 200,
  "message": "上传成功",
  "data": {
    "url": "https://cdn.campus-lostandfound.com/items/2026/06/abc123.jpg",
    "size": 204800,
    "width": 800,
    "height": 600
  },
  "timestamp": 1719648000000
}
```

---

## 5. 状态码定义

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 400 | 请求参数错误 |
| 401 | 未登录/Token无效 |
| 403 | 无权限操作 |
| 404 | 资源不存在 |
| 409 | 资源冲突（如重复发布） |
| 413 | 文件过大 |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |

---

## 6. 前端待开发任务

### 6.1 网络层封装（优先级：高）

**任务描述**：封装 HTTP 请求工具类，统一处理请求、响应、错误

**具体内容**：
- [ ] 封装 `HttpUtil` 工具类
  - [ ] 统一 baseURL 配置
  - [ ] 统一请求头（Token、Content-Type）
  - [ ] 统一请求拦截（添加 token、参数校验）
  - [ ] 统一响应拦截（解析 data、错误处理）
  - [ ] 统一错误处理（网络错误、业务错误、Token 过期）
- [ ] 封装各模块 API 函数（api/user.ts、api/item.ts、api/upload.ts）
- [ ] Token 持久化（Preferences 存储）
- [ ] 登录状态管理（全局 Store）

**涉及技术**：`@ohos.net.http`、`@ohos.data.preferences`

---

### 6.2 云存储/图片上传（优先级：高）

**任务描述**：实现真实的图片选择和上传功能

**具体内容**：
- [ ] 调用系统相册/相机选择图片
  - [ ] 最多选择 9 张
  - [ ] 支持预览
  - [ ] 支持删除已选图片
- [ ] 图片压缩（上传前压缩到合适大小）
- [ ] 上传到云存储（AGC 云存储 / OSS）
  - [ ] 上传进度显示
  - [ ] 失败重试机制
  - [ ] 上传成功后保存 URL
- [ ] 详情页图片浏览
  - [ ] 点击放大查看
  - [ ] 左右滑动切换
  - [ ] 双指缩放

**涉及技术**：`@ohos.file.picker`、`@ohos.multimedia.image`、AGC Storage SDK

---

### 6.3 用户模块对接（优先级：高）

**任务描述**：对接后端用户登录、用户信息接口

**具体内容**：
- [ ] 登录页面
  - [ ] 学号/手机号登录表单
  - [ ] 密码/验证码切换
  - [ ] 表单验证
  - [ ] 登录成功后保存 token 和用户信息
  - [ ] 跳转到来源页面
- [ ] 个人中心页改造
  - [ ] 从接口获取用户信息展示
  - [ ] 点击头像进入个人资料页
  - [ ] 退出登录（清除 token、跳转登录页）
- [ ] 编辑个人资料页
  - [ ] 修改昵称
  - [ ] 更换头像（上传到云存储）
  - [ ] 修改手机号/邮箱
- [ ] 路由守卫
  - [ ] 需要登录的接口检查 token
  - [ ] token 过期自动跳登录页
  - [ ] 登录成功后返回原页面

---

### 6.4 物品模块对接（优先级：高）

**任务描述**：对接后端物品 CRUD 接口，替换内存模拟数据

**具体内容**：
- [ ] 首页改造
  - [ ] 列表分页加载（上拉加载更多）
  - [ ] 下拉刷新
  - [ ] 搜索防抖（输入停止 500ms 后搜索）
  - [ ] 骨架屏/加载中状态
  - [ ] 空状态展示
  - [ ] 错误重试
- [ ] 服务卡片对接
  - [ ] 调用 `/items/latest` 接口获取最新动态
- [ ] 发布页改造
  - [ ] 提交到后端接口
  - [ ] 发布中 loading 状态
  - [ ] 发布成功后跳转首页
  - [ ] 表单验证（前端 + 后端错误提示）
- [ ] 详情页改造
  - [ ] 从接口获取详情
  - [ ] 浏览量 +1
  - [ ] 判断是否是自己发布的（isMine）
  - [ ] 认领/寻回按钮对接
  - [ ] 下架按钮对接
- [ ] 个人中心改造
  - [ ] 我的发布列表对接 `/items/my`
  - [ ] 统计数据从接口获取（或从列表计算）
  - [ ] 标记完成对接
  - [ ] 下架对接
- [ ] AppViewModel 改造
  - [ ] 移除内存数据，改为调用 API
  - [ ] 增加缓存策略（列表缓存、详情缓存）
  - [ ] 保持响应式更新

---

### 6.5 编辑功能（优先级：中）

**任务描述**：实现编辑已发布信息的功能

**具体内容**：
- [ ] 详情页增加「编辑」按钮（仅发布者且进行中状态显示）
- [ ] 编辑页面（复用发布页，预填充数据）
- [ ] 调用更新接口
- [ ] 编辑成功后刷新列表和详情

---

### 6.6 服务卡片（优先级：中）

**任务描述**：实现鸿蒙桌面服务卡片（Widget）

**具体内容**：
- [ ] 2x2 小卡片：显示最新 2 条
- [ ] 2x4 中卡片：显示最新 4 条 + 搜索入口
- [ ] 4x4 大卡片：分类 tab + 列表
- [ ] 点击卡片跳转到对应页面
- [ ] 定时刷新（30 分钟更新一次）

---

### 6.7 性能优化（优先级：中）

**任务描述**：优化列表滑动流畅度和加载速度

**具体内容**：
- [ ] 图片懒加载（列表中图片滚动到可视区域再加载）
- [ ] 图片缓存（内存 + 磁盘二级缓存）
- [ ] 列表分页预加载（滚动到倒数第 5 条时加载下一页）
- [ ] 首屏数据缓存（离线也能看上次的数据）

---

### 6.8 多设备适配完善（优先级：低）

**任务描述**：针对平板、折叠屏设备优化布局

**具体内容**：
- [ ] 大屏两栏布局（左侧分类，右侧列表）
- [ ] 详情页大屏优化（左右分栏，左图右文）
- [ ] 横竖屏切换适配
- [ ] 折叠屏展开/折叠适配

---

## 7. 后端待开发任务

### 7.1 项目搭建（优先级：高）

**任务描述**：搭建 Spring Boot 项目基础框架

**具体内容**：
- [ ] 初始化 Spring Boot 3.x 项目
  - [ ] 引入 Spring Web、Spring Data JPA、MySQL Driver
  - [ ] 引入 Redis、Lombok、Validation
  - [ ] 引入 JWT（jjwt 或 hutool-jwt）
  - [ ] 引入阿里云 OSS / AGC 云存储 SDK
- [ ] 配置文件
  - [ ] application.yml（多环境配置 dev/test/prod）
  - [ ] 数据库连接配置
  - [ ] Redis 连接配置
  - [ ] 文件存储配置
  - [ ] JWT 配置（密钥、过期时间）
- [ ] 统一响应封装
  - [ ] Result 通用响应类
  - [ ] 全局异常处理器（@RestControllerAdvice）
  - [ ] 业务异常类 BusinessException
- [ ] 统一日志配置
  - [ ] logback / log4j2 配置
  - [ ] 请求日志切面（记录入参、出参、耗时）
- [ ] 数据库建表
  - [ ] 用户表（sys_user）
  - [ ] 物品表（lost_found_item）
  - [ ] 认领记录表（claim_record）可选
  - [ ] 建表 DDL 脚本

---

### 7.2 用户模块（优先级：高）

**任务描述**：实现用户注册、登录、信息管理

**具体内容**：
- [ ] 用户登录接口 POST `/auth/login`
  - [ ] 支持学号+密码登录
  - [ ] 支持手机号+验证码登录（可选）
  - [ ] 密码加密存储（BCrypt）
  - [ ] 生成 JWT Token
  - [ ] Token 存入 Redis（支持过期和登出）
  - [ ] 记录最后登录时间
- [ ] 获取用户信息 GET `/user/info`
  - [ ] 从 token 解析用户ID
  - [ ] 返回用户基本信息
- [ ] 更新用户信息 PUT `/user/info`
  - [ ] 修改昵称、头像、性别、邮箱等
  - [ ] 参数校验
- [ ] 修改密码 PUT `/user/password`
  - [ ] 校验旧密码
  - [ ] 设置新密码（加密）
- [ ] 登录拦截器
  - [ ] 校验请求头中的 Token
  - [ ] Token 无效/过期返回 401
  - [ ] 放行白名单接口（登录、列表、详情等）

---

### 7.3 物品模块（优先级：高）

**任务描述**：实现物品信息的增删改查

**具体内容**：
- [ ] 物品列表 GET `/items`
  - [ ] 分页查询（Pageable）
  - [ ] 支持 type 筛选（寻物/招领）
  - [ ] 支持 category 分类筛选
  - [ ] 支持 status 状态筛选
  - [ ] 支持 keyword 关键词搜索（标题、描述、地点模糊匹配）
  - [ ] 按发布时间倒序
  - [ ] 排除已删除的数据
- [ ] 物品详情 GET `/items/{id}`
  - [ ] 根据 ID 查询
  - [ ] 浏览量 +1（异步/计数表）
  - [ ] 判断是否是当前用户发布（isMine 字段）
  - [ ] 不存在返回 404
- [ ] 发布物品 POST `/items`
  - [ ] 参数校验（必填、长度限制）
  - [ ] 从 token 获取发布者信息
  - [ ] 保存到数据库
  - [ ] 返回新生成的 ID 和发布时间
- [ ] 更新物品 PUT `/items/{id}`
  - [ ] 校验是否是发布者（不是返回 403）
  - [ ] 校验状态（进行中才能编辑）
  - [ ] 更新字段（只更新传了的字段）
  - [ ] 更新 updateTime
- [ ] 删除物品 DELETE `/items/{id}`
  - [ ] 校验是否是发布者
  - [ ] 逻辑删除（标记 deleted 字段，而不是真删）
- [ ] 标记完成 PUT `/items/{id}/resolve`
  - [ ] 校验是否是发布者
  - [ ] 根据 type 设置对应状态（LOST→RETURNED，FOUND→CLAIMED）
  - [ ] 记录 claimTime
- [ ] 最新动态 GET `/items/latest`
  - [ ] 查询进行中的信息
  - [ ] 按发布时间倒序
  - [ ] 限制返回数量（默认5，最大20）
  - [ ] 只返回 id、type、title、publishTime
- [ ] 我的发布 GET `/items/my`
  - [ ] 查询当前用户发布的所有信息
  - [ ] 支持 status 筛选
  - [ ] 分页返回

---

### 7.4 文件上传模块（优先级：高）

**任务描述**：实现图片上传到云存储

**具体内容**：
- [ ] 图片上传 POST `/upload/image`
  - [ ] 校验登录状态
  - [ ] 校验文件类型（只允许图片）
  - [ ] 校验文件大小（限制 5MB）
  - [ ] 生成唯一文件名（UUID + 日期目录）
  - [ ] 上传到 OSS/云存储
  - [ ] 返回可访问的 URL
  - [ ] 记录上传日志（用户、文件、大小、时间）
- [ ] 图片删除 DELETE `/upload/image`
  - [ ] 校验是否是本人上传
  - [ ] 从云存储删除文件
- [ ] 图片压缩（可选）
  - [ ] 上传前自动压缩（宽高限制、质量压缩）
  - [ ] 生成缩略图

---

### 7.5 数据库设计（优先级：高）

**表结构设计**：

**1. 用户表 sys_user**
```sql
CREATE TABLE sys_user (
  id           VARCHAR(32)  NOT NULL COMMENT '用户ID',
  open_id      VARCHAR(64)  DEFAULT NULL COMMENT '第三方登录ID',
  name         VARCHAR(20)  NOT NULL COMMENT '昵称',
  avatar       VARCHAR(255) DEFAULT NULL COMMENT '头像URL',
  phone        VARCHAR(20)  DEFAULT NULL COMMENT '手机号',
  student_id   VARCHAR(20)  DEFAULT NULL COMMENT '学号',
  email        VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
  password     VARCHAR(100) DEFAULT NULL COMMENT '密码(加密)',
  gender       TINYINT      DEFAULT 0 COMMENT '性别:0未知1男2女',
  status       TINYINT      DEFAULT 0 COMMENT '状态:0正常1禁用',
  deleted      TINYINT      DEFAULT 0 COMMENT '逻辑删除',
  create_time  BIGINT       NOT NULL COMMENT '创建时间',
  update_time  BIGINT       NOT NULL COMMENT '更新时间',
  last_login_time BIGINT    DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (id),
  UNIQUE KEY uk_phone (phone),
  UNIQUE KEY uk_student_id (student_id),
  KEY idx_create_time (create_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
```

**2. 物品表 lost_found_item**
```sql
CREATE TABLE lost_found_item (
  id               VARCHAR(32)   NOT NULL COMMENT '物品ID',
  type             TINYINT       NOT NULL COMMENT '类型:0寻物1招领',
  category         TINYINT       NOT NULL COMMENT '分类:1卡2数码3衣4书5其他',
  title            VARCHAR(50)   NOT NULL COMMENT '标题',
  description      VARCHAR(500)  NOT NULL COMMENT '描述',
  location         VARCHAR(100)  NOT NULL COMMENT '地点',
  contact          VARCHAR(50)   NOT NULL COMMENT '联系方式',
  images           VARCHAR(2000) DEFAULT NULL COMMENT '图片URL(JSON数组)',
  publisher_id     VARCHAR(32)   NOT NULL COMMENT '发布者ID',
  publisher_name   VARCHAR(20)   NOT NULL COMMENT '发布者昵称',
  publisher_avatar VARCHAR(255)  DEFAULT NULL COMMENT '发布者头像',
  status           TINYINT       DEFAULT 0 COMMENT '状态:0进行中1已认领2已寻回',
  view_count       INT           DEFAULT 0 COMMENT '浏览次数',
  claim_time       BIGINT        DEFAULT NULL COMMENT '认领/寻回时间',
  deleted          TINYINT       DEFAULT 0 COMMENT '逻辑删除',
  publish_time     BIGINT        NOT NULL COMMENT '发布时间',
  update_time      BIGINT        NOT NULL COMMENT '更新时间',
  PRIMARY KEY (id),
  KEY idx_type_status (type, status),
  KEY idx_category (category),
  KEY idx_publisher_id (publisher_id),
  KEY idx_publish_time (publish_time),
  KEY idx_title (title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='失物招领表';
```

**3. 认领申请表 claim_record（可选）**
```sql
CREATE TABLE claim_record (
  id            VARCHAR(32)  NOT NULL COMMENT '记录ID',
  item_id       VARCHAR(32)  NOT NULL COMMENT '物品ID',
  claimant_id   VARCHAR(32)  NOT NULL COMMENT '认领人ID',
  claimant_name VARCHAR(20)  NOT NULL COMMENT '认领人昵称',
  description   VARCHAR(500) DEFAULT NULL COMMENT '认领描述',
  status        TINYINT      DEFAULT 0 COMMENT '状态:0待审1通过2拒绝',
  audit_remark  VARCHAR(200) DEFAULT NULL COMMENT '审核备注',
  create_time   BIGINT       NOT NULL COMMENT '申请时间',
  audit_time    BIGINT       DEFAULT NULL COMMENT '审核时间',
  PRIMARY KEY (id),
  KEY idx_item_id (item_id),
  KEY idx_claimant_id (claimant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='认领申请表';
```

---

### 7.6 Redis 缓存（优先级：中）

**任务描述**：用 Redis 缓存热点数据，提升访问速度

**具体内容**：
- [ ] 列表数据缓存
  - [ ] 热门搜索结果缓存（5分钟过期）
  - [ ] 最新动态缓存（1分钟过期）
- [ ] 详情缓存
  - [ ] 物品详情缓存（10分钟过期，修改/删除时清除）
- [ ] 浏览量计数
  - [ ] Redis 计数，定时同步到 MySQL
- [ ] Token 存储
  - [ ] 登录 Token 存入 Redis
  - [ ] 登出时删除 Token
  - [ ] Token 续期机制

---

### 7.7 搜索优化（优先级：中）

**任务描述**：优化搜索效果

**具体内容**：
- [ ] MySQL 全文索引（标题、描述、地点）
- [ ] 搜索关键词高亮（可选）
- [ ] 搜索热词统计（可选）
- [ ] 搜索联想/自动补全（可选）

---

### 7.8 管理后台（优先级：低）

**任务描述**：后台管理系统，管理员审核和管理

**具体内容**：
- [ ] 管理员登录
- [ ] 物品管理（列表、删除、置顶）
- [ ] 用户管理（列表、禁用、启用）
- [ ] 数据统计（发布量、用户量、认领率）
- [ ] 违规内容处理

---

## 8. 联调注意事项

### 8.1 前端注意事项

1. **Token 管理**
   - Token 过期时间：默认 7 天
   - 收到 401 时，清除本地 token，跳登录页
   - 登录成功后保存 token 到 Preferences

2. **图片加载**
   - 列表页图片使用缩略图 URL（如果有）
   - 详情页加载原图
   - 加载失败显示占位图

3. **列表分页**
   - 首次加载 pageNum=1
   - 上拉加载更多 pageNum++
   - 下拉刷新重置 pageNum=1
   - 没有更多数据时显示「没有更多了」

4. **错误处理**
   - 网络错误：显示「网络异常，请检查网络」
   - 业务错误：显示后端返回的 message
   - 所有错误都要有重试机制

5. **时间格式**
   - 后端返回时间戳（毫秒）
   - 前端统一用 `formatTime` 函数格式化

### 8.2 后端注意事项

1. **接口规范**
   - 严格按照 RESTful 风格
   - 统一响应格式（code/message/data/timestamp）
   - 错误信息要明确、友好

2. **参数校验**
   - 所有接口入参都要校验（@Valid）
   - 长度、格式、必填项都要校验
   - 校验失败返回 400 + 具体错误信息

3. **安全**
   - SQL 注入防护（JPA 自带）
   - XSS 防护（敏感字符转义）
   - 越权访问检查（只能操作自己的数据）
   - 接口限流（防止刷接口）

4. **性能**
   - 列表查询必须分页
   - 高频接口加缓存
   - 数据库字段加索引
   - N+1 查询问题要避免

5. **数据一致性**
   - 删除/修改时清除相关缓存
   - 重要操作写操作日志
   - 软删除不要物理删除

### 8.3 联调步骤

1. **第一步**：后端先写好接口文档，前端确认没问题
2. **第二步**：后端先开发登录 + 物品列表接口，前端对接
3. **第三步**：后端开发详情、发布接口，前端对接
4. **第四步**：后端开发上传图片接口，前端对接
5. **第五步**：后端开发编辑、删除、标记完成接口，前端对接
6. **第六步**：联调个人中心、我的发布
7. **第七步**：整体测试 + Bug 修复

---

## 附录

### A. 前端当前代码结构

```
entry/src/main/ets/
├── common/
│   ├── bean/           # 数据模型（需增加API返回类型定义）
│   ├── component/      # 通用组件
│   ├── mock/           # 模拟数据（联调后可删）
│   └── viewmodel/      # 状态管理（需改为调用API）
├── pages/
│   ├── Index.ets       # 主框架（Tabs）
│   ├── HomePage.ets    # 首页
│   ├── PublishPage.ets # 发布页
│   ├── DetailPage.ets  # 详情页
│   └── ProfilePage.ets # 个人中心
└── entryability/
    └── EntryAbility.ets
```

### B. 推荐新增目录

```
entry/src/main/ets/
├── common/
│   ├── api/            # 接口定义（新增）
│   │   ├── http.ts     # HTTP封装
│   │   ├── user.ts     # 用户接口
│   │   ├── item.ts     # 物品接口
│   │   └── upload.ts   # 上传接口
│   ├── model/          # API 数据模型（新增）
│   │   ├── ApiResult.ets
│   │   ├── PageResult.ets
│   │   └── LoginResult.ets
│   ├── utils/          # 工具函数（新增）
│   │   ├── TokenUtil.ets
│   │   ├── TimeUtil.ets
│   │   └── ImageUtil.ets
│   └── store/          # 全局状态（新增）
│       └── UserStore.ets
```
