# 第4月：前端框架进阶与全栈扩展（Next.js/React & 高级前端）

- 第13周：Next.js 高级特性（SSR/SSG/API Routes）
- 第14周：全局状态管理（Redux/Zustand/React Query）
- 第15周：复杂功能开发（订阅/支付/权限控制）
- 第16周：前端测试与性能优化

## 技能目标

- 深入掌握 Next.js/React 的进阶用法，理解 SSR/SSG/ISR 等渲染模式及其适用场景。
- 在 Next.js 中实践 BFF（Backend For Frontend）模式，使用 API Routes 编写轻量后端逻辑。
- 引入全局状态管理（Redux Toolkit/Zustand），结合 SWR/React Query 进行数据获取与缓存。
- 设计复杂前端功能，包括动态路由、权限控制、订阅支付流程和后台管理界面。
- 通过 Cypress、Lighthouse 等工具进行端到端测试与性能优化。

## 核心理论内容

- **Next.js 框架进阶**：
  - SSR、SSG、ISR 的原理与实现方式。
  - API Routes 构建 BFF 层，处理评论等轻量后端逻辑。
  - 动态与嵌套路由，权限跳转与参数传递。
- **组件设计与复用**：
  - 高阶组件、Render Props、自定义 Hooks。
  - 动态组件与懒加载，提高复用性和性能。
  - 页面级组件与 UI 组件分层。
- **全局状态管理**：
  - Redux Toolkit、Zustand、Recoil 等方案的比较与应用。
  - React Query/SWR 的数据获取与缓存，SSR 数据注水与 Hydration。
- **前端路由与导航**：
  - Next.js Router 与 React Router 的差异。
  - 登录状态与权限控制（未登录跳转登录页、管理员后台等）。
- **前端性能优化**：
  - Next.js Image、Script 优化。
  - 浏览器性能分析、虚拟滚动、大列表分页。
  - 使用 Lighthouse 和 Webpack Bundle Analyzer 评估与优化。

## 实践项目

- **后台管理面板**：
  - 管理员登录后增删改查影片和用户数据，审核评论。
  - 使用 Next.js API Routes 构建 `/api/movies`、`/api/comments` 等接口，练习 BFF 模式。
- **主项目功能扩展**：
  - 引入 Redux Toolkit 或 Zustand 实现全局用户登录态与订阅状态。
  - 实现订阅购买流程（可模拟支付），为订阅用户展示额外内容或权限标识。
  - 评论功能增强：编辑、删除、点赞。
  - 集成管理员后台页面，区分普通用户与管理员权限。

## 前端测试与质量

- 使用 Cypress 编写端到端测试（登录 → 评论 → 订阅流程）。
- 使用 Jest/React Testing Library 测试核心组件。
- 运行 Lighthouse、Webpack Bundle Analyzer 进行性能分析和优化。

## 软技能练习

- 通过项目迁移总结学习新框架的思路，形成系统设计文档和架构图。
- 小组协作模拟：角色分工（API、UI 等），练习接口对齐与团队沟通。
- 根据反馈快速迭代产品需求，如调整订阅逻辑或后台权限。
- 撰写阶段报告，记录技术挑战与收获。

## 学习计划

| 月份 | 周次 | 技能目标 | 核心内容 | 实践任务 | 软技能 |
| --- | --- | --- | --- | --- | --- |
| 第4月 前端进阶 | 第13周 | Next.js 进阶 | 动态路由、API Routes | 增加 `/api/comments` API | 画架构图，梳理模块关系 |
| 第4月 前端进阶 | 第14周 | 状态管理 | Redux Toolkit/Zustand + SWR/React Query | 实现全局用户登录态 | 小组协作模拟（角色分工） |
| 第4月 前端进阶 | 第15周 | 复杂功能 | 订阅/支付流程、权限控制 | 实现订阅购买页面 | 产品经理模拟：新增需求迭代 |
| 第4月 前端进阶 | 第16周 | 测试与优化 | Cypress、Lighthouse、性能分析 | E2E 测试 + 性能分析 | 写阶段报告：技术挑战与收获 |

