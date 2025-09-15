
前端页面路由（Frontend Routing）

定义：前端路由指的是用户在浏览器地址栏输入不同的 URL（如 /home、/about），前端应用（React、Vue、Next.js 等）通过 JavaScript 来决定展示哪个组件或页面，而不是每次都请求一个新的 HTML 文件。

实现方式：

Hash 路由：如 /#/about，依靠 window.location.hash 判断。

History 路由：如 /about，利用 HTML5 History API（pushState、replaceState）改变地址栏而不刷新页面。

特点：

无需后端参与即可切换页面（单页应用 SPA 的核心）。

用户体验更快、更流畅。

前端框架（如 React Router、Vue Router、Next.js App Router）负责渲染页面。

后端接口路由（Backend Routing / API Routing）

定义：后端路由是指后端服务器（如 Express、Spring Boot、Django、Gin）根据请求的 URL 和方法（GET/POST/PUT/DELETE）来匹配并执行对应的处理逻辑。

例子：

GET /api/users → 获取用户列表

POST /api/users → 新建用户

GET /api/users/:id → 获取某个用户详情

特点：

负责业务逻辑、数据库操作、权限校验。

返回数据（JSON、XML、二进制文件等），而不是前端 UI。
