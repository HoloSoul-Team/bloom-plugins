# Bloom Plugin

**English** | [简体中文](README.zh-CN.md)

Finish learning something with your AI assistant, then turn the conversation into an illustrated, chapter-by-chapter study guide on [Bloom](https://bloombook.cn) — or search the study guides already on Bloom.

The plugin is only a connector: guides are generated on Bloom's servers. It bundles no prompts and needs no API key.

## Install: one command

macOS / Linux — paste into Terminal:

```
curl -fsSL https://bloombook.cn/install.sh | sh
```

Windows — paste into PowerShell:

```
irm https://bloombook.cn/install.ps1 | iex
```

It finds the AI clients on your computer (Claude Code, Codex / ChatGPT desktop, Gemini CLI, Cursor, WorkBuddy, Claude Desktop), connects each one to Bloom, and tells you the one thing left to do — usually just restarting the app. Your existing settings are kept, and it is safe to run again.

Then ask learning questions as usual — no need to @ the plugin.

Prefer not to open a terminal? Send this to your AI assistant and it will run the install for you:

```
Please install the Bloom learning plugin for me: run `curl -fsSL https://bloombook.cn/install.sh | sh` in a terminal, then tell me what its output says is left to do.
```

## What it does

- **Find material:** ask "Is there a guide on diffusion models on Bloom?" and your assistant searches Bloom and returns links.
- **Create a study guide:** after working through a topic, say "make this into study material". Your assistant writes up the conversation — what you asked, where you got stuck, what you already understand — and gives you a link. Open it, sign in to Bloom and confirm; the guide is ready in about 20–40 minutes and you get notified. It focuses on the points you were stuck on.

## Manual install

The command above covers all of these. Use the steps below only if you want to set up one client by hand.

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

1. Open **Connectors** in the left sidebar → **Custom connector** (top right) → **Add MCP**, and add:

   ```json
   {
     "mcpServers": {
       "bloom": { "type": "http", "url": "https://bloombook.cn/api/mcp" }
     }
   }
   ```

   This is the file `~/.workbuddy/mcp.json`. Click **Trust** on the `bloom` row.

2. Copy the folder [`plugins/bloom/skills/bloom-study`](plugins/bloom/skills/bloom-study) into `~/.workbuddy/skills/` and restart WorkBuddy.

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

- **WorkBuddy: installed but the tools aren't there:** restart WorkBuddy, then open Connectors → Custom connector and click **Trust** on the `bloom` row. WorkBuddy only reads the config at startup and won't connect a new server until you trust it.
- **Tools don't show up / "error sending request" behind a proxy:** some proxy tools route each app differently, and requests to `bloombook.cn` from your AI client may fail even though your browser works. Set `bloombook.cn` to connect directly in your proxy rules, or add it to `NO_PROXY` (for example `NO_PROXY=localhost,127.0.0.1,bloombook.cn`) before starting the client.
- **The link expired:** links are valid for 7 days. Ask your assistant to create a new one.

## Privacy

When you create a study guide, the conversation summary your assistant writes is stored on Bloom's servers to generate that guide. The link expires after 7 days. Don't let your assistant put names, contact details, secrets or other sensitive information in the summary.
