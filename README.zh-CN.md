# Bloom 插件

[English](README.md) | **简体中文**

和 AI 聊完一个知识点，一键生成 [Bloom](https://bloombook.cn) 图文学习专题；也能搜索 Bloom 上已有的专题。

插件本身只是接入层：生成在 Bloom 服务器上完成，插件里没有提示词，也不需要 API key。

## 安装：一行命令

macOS / Linux，粘贴到"终端"里回车：

```
curl -fsSL https://bloombook.cn/install.sh | sh
```

Windows，粘贴到 PowerShell 里回车：

```
irm https://bloombook.cn/install.ps1 | iex
```

它会自动找出你电脑上装了哪些 AI 客户端（Claude Code、Codex / ChatGPT 桌面版、Gemini CLI、Cursor、WorkBuddy、Claude Desktop），逐个接上 Bloom，最后告诉你还差哪一步，一般就是重启一下应用。你原有的配置都会保留，重复运行也没问题。

之后照常问学习问题就行，不用 @ 插件。

不想开终端？把下面这段话发给你的 AI 助手，它会替你运行安装：

```
请帮我安装 Bloom 学习插件：在终端运行 curl -fsSL https://bloombook.cn/install.sh | sh ，然后把输出里"还差一步"的内容告诉我。
```

## 能做什么

- **找资料：** 问 AI "Bloom 上有讲扩散模型的专题吗？"，它会搜索 Bloom 并给出链接。
- **生成专题：** 和 AI 聊完一个知识点后说"帮我生成学习资料"，AI 会把这次对话整理成一份方案（你问了什么、卡在哪、已经懂了什么），给你一个链接。点开、登录 Bloom、确认后开始生成，约 20–40 分钟，完成后会通知你。专题会重点讲透你卡住的地方。

## 手动安装

上面那条命令已经覆盖了下面所有客户端。只有想自己手动配置某一个时，才需要看这里。

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

1. 左侧边栏打开**连接器** → 右上角**自定义连接器** → **添加 MCP**，加上：

   ```json
   {
     "mcpServers": {
       "bloom": { "type": "http", "url": "https://bloombook.cn/api/mcp" }
     }
   }
   ```

   对应的文件是 `~/.workbuddy/mcp.json`。然后在 `bloom` 那一行点**信任**。

2. 把 [`plugins/bloom/skills/bloom-study`](plugins/bloom/skills/bloom-study) 这个文件夹复制到 `~/.workbuddy/skills/`，重启 WorkBuddy。

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

- **WorkBuddy 装完了但没有工具：** 重启 WorkBuddy，然后打开"连接器 → 自定义连接器"，在 `bloom` 那一行点**信任**。WorkBuddy 只在启动时读取配置，新加的服务要你点过信任才会连接。
- **开着代理时看不到工具，或报 "error sending request"：** 有些代理软件对不同的应用分流不同，浏览器能打开 bloombook.cn，AI 客户端发出的请求却可能失败。在代理规则里把 `bloombook.cn` 设为直连，或者启动客户端前把它加进 `NO_PROXY`（例如 `NO_PROXY=localhost,127.0.0.1,bloombook.cn`）。
- **链接失效了：** 链接 7 天内有效，让 AI 重新生成一个就行。

## 隐私

生成专题时，AI 写的对话纪要会存到 Bloom 服务器上，用于生成这篇专题；链接 7 天后失效。请不要让 AI 在纪要里写入姓名、联系方式、密钥等个人或敏感信息。
