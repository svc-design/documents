# Agent Design

Guidelines for designing LLM-powered agents for operations.

OpenAI 的 Agent Builder，有点像 n8n、Dify 这种可视化编排/智能体平台。下面给你一个超短对比，够你快速判断用哪一个。

一句话结论

OpenAI Agent Builder：官方“智能体工作台”，原生接入 OpenAI 模型/工具链，拖拽式多步流程+评测/部署一体，更像“从模型到应用的整套平台”。
n8n：通用自动化/集成（iPaaS）+ AI 节点，强在“连 500+ 外部应用做业务流程自动化”，AI 是其中一种能力。 n8n.io
Dify：开源 LLM 应用/智能体平台，内置 RAG、工作流、观测与模型管理，企业自建更灵活。 docs.dify.ai

快速对比
维度	OpenAI Agent Builder	n8n	Dify
核心定位	官方智能体开发&部署平台（AgentKit+可视化工作台）	通用自动化/集成平台，含 AI 节点	开源 LLM 应用/智能体平台
工作流/画布	可视化 Agent Builder，节点编排多步智能体	可视化工作流，侧重应用集成与条件/循环	可视化工作流+RAG/检索/记忆等
生态与集成	原生对接 OpenAI 模型/评测/UI 嵌入	500+ 应用连接器、Webhook、代码节点	多模型/向量库/RAG/观测，私有化更友好
部署	OpenAI 平台（托管）	云/自托管皆可	自托管为主，也有托管版
适合场景	要深用 OpenAI 生态、快速做“智能体到上线”的团队	“把各业务系统串起来”的自动化场景	想要开源可控、做 RAG/智能体产品化的团队

参考：OpenAI Agent 平台与 AgentKit 介绍与文档；n8n AI&特性页；Dify 官网与文档。
docs.dify.ai

怎么选（极简建议）

你要深度用 OpenAI、最短路径上线智能体 → 用 Agent Builder/AgentKit   OpenAI
你要把工单、CRM、表格、Slack、Webhook 全串起来 → 用 n8n，AI 当节点用。 n8n.io
你要开源自建、RAG 与观测都在自己控制里 → 用 Dify。 docs.dify.ai

