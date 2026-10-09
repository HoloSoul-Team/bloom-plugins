# Bloom 插件

[English](README.md) | **简体中文**

和 AI 聊完一个知识点，一键生成 [Bloom](https://bloombook.cn) 图文学习专题；也能搜索 Bloom 上已有的专题。

插件本身只是接入层：生成在 Bloom 服务器上完成，插件里没有提示词，也不需要 API key。

## 能做什么

- **找资料：** 问 AI "Bloom 上有讲扩散模型的专题吗？"，它会搜索 Bloom 并给出链接。
- **生成专题：** 和 AI 聊完一个知识点后说"帮我生成学习资料"，AI 会把这次对话整理成一份方案（你问了什么、卡在哪、已经懂了什么），给你一个链接。点开、登录 Bloom、确认后开始生成，约 20–40 分钟，完成后会通知你。专题会重点讲透你卡住的地方。

## Claude Code

```
/plugin marketplace add HoloSoul-Team/bloom-plugins
/plugin install bloom@bloom
```

装好后，AI 会在你找学习资料时先搜 Bloom；在你明显学完一轮时，问一次要不要生成学习专题。

## Codex

在 `~/.codex/config.toml` 里加：

```toml
[mcp_servers.bloom]
url = "https://bloombook.cn/api/mcp"
```

## Cursor

在 `~/.cursor/mcp.json`（或项目里的 `.cursor/mcp.json`）里加：

```json
{
  "mcpServers": {
    "bloom": { "url": "https://bloombook.cn/api/mcp" }
  }
}
```

## 其它支持远程 MCP 的客户端

MCP 地址：`https://bloombook.cn/api/mcp`（Streamable HTTP，无需鉴权）。

## 隐私

生成专题时，AI 写的对话纪要会存到 Bloom 服务器上，用于生成这篇专题；链接 7 天后失效。请不要让 AI 在纪要里写入姓名、联系方式、密钥等个人或敏感信息。
