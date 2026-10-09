# Bloom 插件

[English](README.md) | **简体中文**

和 AI 聊完一个知识点，一键生成 [Bloom](https://bloombook.cn) 图文学习专题；也能搜索 Bloom 上已有的专题。

插件本身只是接入层：生成在 Bloom 服务器上完成，插件里没有提示词，也不需要 API key。

## 能做什么

- **找资料：** 问 AI "Bloom 上有讲扩散模型的专题吗？"，它会搜索 Bloom 并给出链接。
- **生成专题：** 和 AI 聊完一个知识点后说"帮我生成学习资料"，AI 会把这次对话整理成一份方案（你问了什么、卡在哪、已经懂了什么），给你一个链接。点开、登录 Bloom、确认后开始生成，约 20–40 分钟，完成后会通知你。专题会重点讲透你卡住的地方。

## 支持的客户端

| 客户端 | 安装方式 |
|---|---|
| [Claude Code](#claude-code) | 插件市场（两条命令） |
| [Codex](#codex) | 插件市场（两条命令） |
| [ChatGPT 桌面版](#chatgpt-桌面版) | 添加市场后在插件目录安装 |
| [Gemini CLI](#gemini-cli) | 一条命令 |
| [Cursor](#cursor) | 一键链接或配置文件 |
| [WorkBuddy](#workbuddy) | 连接器 + 技能文件夹 |
| [Claude Desktop](#claude-desktop) | 配置文件（本地桥接） |
| [其它 MCP 客户端](#其它-mcp-客户端) | MCP 地址 |

插件版本（Claude Code、Codex、ChatGPT、Gemini CLI）自带使用说明：你找资料时 AI 会先搜 Bloom，你明显学完一轮时会问一次要不要生成专题。用配置文件接入的方式工具是一样的，直接让 AI 用 Bloom 就行。

### Claude Code

```
/plugin marketplace add HoloSoul-Team/bloom-plugins
/plugin install bloom@bloom
```

### Codex

```
codex plugin marketplace add HoloSoul-Team/bloom-plugins
codex plugin add bloom@bloom
```

也可以只接服务，在 `~/.codex/config.toml` 里加：

```toml
[mcp_servers.bloom]
url = "https://bloombook.cn/api/mcp"
```

### ChatGPT 桌面版

先用上面的 Codex 命令添加市场，然后重启 ChatGPT 桌面版，打开插件目录，选择 **Bloom** 市场并安装插件。

### Gemini CLI

```
gemini extensions install https://github.com/HoloSoul-Team/bloom-plugins
```

### Cursor

[一键添加到 Cursor](https://cursor.com/en/install-mcp?name=bloom&config=eyJ1cmwiOiJodHRwczovL2Jsb29tYm9vay5jbi9hcGkvbWNwIn0=)，或者在 `~/.cursor/mcp.json`（或项目里的 `.cursor/mcp.json`）里加：

```json
{
  "mcpServers": {
    "bloom": { "url": "https://bloombook.cn/api/mcp" }
  }
}
```

### WorkBuddy

1. **接入服务：** 设置 → 连接器 → 添加，地址填 `https://bloombook.cn/api/mcp`。如果是直接编辑 MCP 配置文件，加上：

   ```json
   {
     "mcpServers": {
       "bloom": { "url": "https://bloombook.cn/api/mcp" }
     }
   }
   ```

2. **加上技能（可选，推荐）：** 把 [`plugins/bloom/skills/bloom-study`](plugins/bloom/skills/bloom-study) 这个文件夹复制到 `~/.workbuddy/skills/`，然后重启 WorkBuddy。

   macOS / Linux：

   ```
   git clone --depth 1 https://github.com/HoloSoul-Team/bloom-plugins.git /tmp/bloom-plugins
   mkdir -p ~/.workbuddy/skills && cp -R /tmp/bloom-plugins/plugins/bloom/skills/bloom-study ~/.workbuddy/skills/
   ```

   Windows（PowerShell）：

   ```
   git clone --depth 1 https://github.com/HoloSoul-Team/bloom-plugins.git $env:TEMP\bloom-plugins
   New-Item -ItemType Directory -Force "$HOME\.workbuddy\skills" | Out-Null
   Copy-Item -Recurse "$env:TEMP\bloom-plugins\plugins\bloom\skills\bloom-study" "$HOME\.workbuddy\skills\"
   ```

### Claude Desktop

Claude Desktop 的自定义连接器要求登录授权，所以改用本地桥接接入（需要安装 [Node.js](https://nodejs.org)）。在 `claude_desktop_config.json`（设置 → 开发者 → 编辑配置）里加上，然后重启：

```json
{
  "mcpServers": {
    "bloom": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://bloombook.cn/api/mcp"]
    }
  }
}
```

只支持本地命令方式 MCP 的客户端，都可以用同一条 `npx -y mcp-remote https://bloombook.cn/api/mcp`。

### 其它 MCP 客户端

MCP 地址：`https://bloombook.cn/api/mcp`（Streamable HTTP，无需鉴权）。工具：`search_bloom`、`create_learning_material`。

## 常见问题

- **开着代理时看不到工具，或报 "error sending request"：** 有些代理软件对不同的应用分流不同，浏览器能打开 bloombook.cn，AI 客户端发出的请求却可能失败。在代理规则里把 `bloombook.cn` 设为直连，或者启动客户端前把它加进 `NO_PROXY`（例如 `NO_PROXY=localhost,127.0.0.1,bloombook.cn`）。
- **链接失效了：** 链接 7 天内有效，让 AI 重新生成一个就行。

## 隐私

生成专题时，AI 写的对话纪要会存到 Bloom 服务器上，用于生成这篇专题；链接 7 天后失效。请不要让 AI 在纪要里写入姓名、联系方式、密钥等个人或敏感信息。
