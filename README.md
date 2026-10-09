# Bloom Plugin

**English** | [简体中文](README.zh-CN.md)

Finish learning something with your AI assistant, then turn the conversation into an illustrated, chapter-by-chapter study guide on [Bloom](https://bloombook.cn) — or search the study guides already on Bloom.

The plugin is only a connector: guides are generated on Bloom's servers. It bundles no prompts and needs no API key.

## What it does

- **Find material:** ask "Is there a guide on diffusion models on Bloom?" and your assistant searches Bloom and returns links.
- **Create a study guide:** after working through a topic, say "make this into study material". Your assistant writes up the conversation — what you asked, where you got stuck, what you already understand — and gives you a link. Open it, sign in to Bloom and confirm; the guide is ready in about 20–40 minutes and you get notified. It focuses on the points you were stuck on.

## Supported clients

| Client | How to install |
|---|---|
| [Claude Code](#claude-code) | Plugin marketplace (two commands) |
| [Codex](#codex) | Plugin marketplace (two commands) |
| [ChatGPT desktop](#chatgpt-desktop) | Plugins directory, after adding the marketplace |
| [Gemini CLI](#gemini-cli) | One command |
| [Cursor](#cursor) | One-click link or config file |
| [WorkBuddy](#workbuddy) | Connector + skill folder |
| [Claude Desktop](#claude-desktop) | Config file (local bridge) |
| [Other MCP clients](#other-mcp-clients) | MCP endpoint |

The plugin versions (Claude Code, Codex, ChatGPT, Gemini CLI) also include usage guidance, so your assistant searches Bloom when you look for material and offers once to create a guide when you've finished a topic. With the config-file options you get the same tools; just ask your assistant to use Bloom.

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

Or add the server only, in `~/.codex/config.toml`:

```toml
[mcp_servers.bloom]
url = "https://bloombook.cn/api/mcp"
```

### ChatGPT desktop

After adding the marketplace with the Codex command above, restart the ChatGPT desktop app, open the Plugins Directory, pick the **Bloom** marketplace and install the plugin.

### Gemini CLI

```
gemini extensions install https://github.com/HoloSoul-Team/bloom-plugins
```

### Cursor

[Add to Cursor](https://cursor.com/en/install-mcp?name=bloom&config=eyJ1cmwiOiJodHRwczovL2Jsb29tYm9vay5jbi9hcGkvbWNwIn0=), or add to `~/.cursor/mcp.json` (or `.cursor/mcp.json` in your project):

```json
{
  "mcpServers": {
    "bloom": { "url": "https://bloombook.cn/api/mcp" }
  }
}
```

### WorkBuddy

1. **Connect the server:** Settings → Connectors → Add, with the address `https://bloombook.cn/api/mcp`. If you edit the MCP config file instead, add:

   ```json
   {
     "mcpServers": {
       "bloom": { "url": "https://bloombook.cn/api/mcp" }
     }
   }
   ```

2. **Add the skill (optional, recommended):** copy the folder [`plugins/bloom/skills/bloom-study`](plugins/bloom/skills/bloom-study) into `~/.workbuddy/skills/` and restart WorkBuddy.

   macOS / Linux:

   ```
   git clone --depth 1 https://github.com/HoloSoul-Team/bloom-plugins.git /tmp/bloom-plugins
   mkdir -p ~/.workbuddy/skills && cp -R /tmp/bloom-plugins/plugins/bloom/skills/bloom-study ~/.workbuddy/skills/
   ```

   Windows (PowerShell):

   ```
   git clone --depth 1 https://github.com/HoloSoul-Team/bloom-plugins.git $env:TEMP\bloom-plugins
   New-Item -ItemType Directory -Force "$HOME\.workbuddy\skills" | Out-Null
   Copy-Item -Recurse "$env:TEMP\bloom-plugins\plugins\bloom\skills\bloom-study" "$HOME\.workbuddy\skills\"
   ```

### Claude Desktop

Claude Desktop's custom connectors require sign-in, so connect through a local bridge instead (needs [Node.js](https://nodejs.org)). Add to `claude_desktop_config.json` (Settings → Developer → Edit Config) and restart:

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

The same `npx -y mcp-remote https://bloombook.cn/api/mcp` command works for any client that only supports local (command-based) MCP servers.

### Other MCP clients

MCP endpoint: `https://bloombook.cn/api/mcp` (Streamable HTTP, no authentication). Tools: `search_bloom`, `create_learning_material`.

## Troubleshooting

- **Tools don't show up / "error sending request" behind a proxy:** some proxy tools route each app differently, and requests to `bloombook.cn` from your AI client may fail even though your browser works. Set `bloombook.cn` to connect directly in your proxy rules, or add it to `NO_PROXY` (for example `NO_PROXY=localhost,127.0.0.1,bloombook.cn`) before starting the client.
- **The link expired:** links are valid for 7 days. Ask your assistant to create a new one.

## Privacy

When you create a study guide, the conversation summary your assistant writes is stored on Bloom's servers to generate that guide. The link expires after 7 days. Don't let your assistant put names, contact details, secrets or other sensitive information in the summary.
