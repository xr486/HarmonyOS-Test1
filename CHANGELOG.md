# 校园失物招领 - 修改历史

## [v1.1.0] - 2026-06-29

### 修复

- **fix: 修复列表数据不自动刷新问题**
  - 采用 AppStorage 全局版本号 + @StorageLink + @Watch 机制
  - 所有数据变更自动同步到首页和个人中心
  - 详情页操作后返回首页列表实时更新

- **fix: 修复首页 List 滚动冲突问题**
  - 移除 List 外层多余的 Scroll 组件
  - 将服务卡片、空状态、列表项统一放入 List 中
  - 避免滚动冲突，提升滑动流畅度

- **fix: 优化 ProfilePage 统计性能**
  - 新增 activeCount、doneCount、totalCount 缓存变量
  - 数据变化时通过 updateStats() 统一计算
  - 避免每次 build 都重复 filter 计算

- **fix: 发布页自动登录增加提示**
  - 未登录用户发布信息时自动创建账号
  - 弹出 Toast 提示用户已自动登录

- **fix: 修复 DetailPage 类型声明错误**
  - 替换 Record<string, string> 为显式 interface
  - 替换对象字面量类型声明为命名接口
  - 符合 ArkTS 严格模式规范

### 涉及文件

- `entry/src/main/ets/common/viewmodel/AppViewModel.ets`
- `entry/src/main/ets/pages/Index.ets`
- `entry/src/main/ets/pages/HomePage.ets`
- `entry/src/main/ets/pages/PublishPage.ets`
- `entry/src/main/ets/pages/ProfilePage.ets`
- `entry/src/main/ets/pages/DetailPage.ets`

---

## [v1.0.0] - 2026-06-29

### 功能

- **feat: 初始化校园失物招领鸿蒙应用项目**
  - 首页：搜索、双分类切换（寻物/招领）、物品类型筛选、服务卡片、列表展示
  - 发布页：信息类型选择、物品分类、表单验证、图片上传占位
  - 详情页：图文展示、发布者信息、认领/下架操作
  - 个人中心：登录/退出、发布统计、我的发布列表、标记完成/下架
  - 全局状态管理：AppViewModel 单例模式
  - LazyForEach 列表懒加载优化
  - 多设备屏幕断点适配（sm/md/lg）
  - 8 条内置模拟数据

### 技术要点

- Navigation + Tabs 底部导航
- 云数据库预留接口（内存模拟数据）
- 云存储图片上传预留接口
- 服务卡片最新动态展示
- 双分类体系（失物/招领 + 物品类型）
- 信息状态管理（进行中/已认领/已寻回）
- 账号登录体系与个人发布管理

### 涉及文件

共 49 个文件，2402 行代码

- `entry/src/main/ets/common/bean/` - 数据模型
- `entry/src/main/ets/common/component/` - 通用组件
- `entry/src/main/ets/common/mock/` - 模拟数据
- `entry/src/main/ets/common/viewmodel/` - 状态管理
- `entry/src/main/ets/pages/` - 页面文件
- `entry/src/main/resources/` - 资源文件
- 配置文件及构建脚本
