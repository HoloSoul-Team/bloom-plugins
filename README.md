# Bloom Plugin

**English** | [简体中文](README.zh-CN.md)

Finish learning something with your AI assistant, then turn the conversation into an illustrated, chapter-by-chapter study guide on [Bloom](https://bloombook.cn) — or search the study guides already on Bloom.

The plugin is only a connector: guides are generated on Bloom's servers. It bundles no prompts and needs no API key.

## What it does

- **Find material:** ask "Is there a guide on diffusion models on Bloom?" and your assistant searches Bloom and returns links.
- **Create a study guide:** after working through a topic, say "make this into study material". Your assistant writes up the conversation — what you asked, where you got stuck, what you already understand — and gives you a link. Open it, sign in to Bloom and confirm; the guide is ready in about 20–40 minutes and you get notified. It focuses on the points you were stuck on.

## Claude Code

```
/plugin marketplace add HoloSoul-Team/bloom-plugins
/plugin install bloom@bloom
```

Once installed, your assistant searches Bloom first when you look for learning material, and offers once to create a study guide when you have clearly finished working through a topic.

## Codex

Add to `~/.codex/config.toml`:

```toml
[mcp_servers.bloom]
url = "https://bloombook.cn/api/mcp"
```

## Cursor

Add to `~/.cursor/mcp.json` (or `.cursor/mcp.json` in your project):

```json
{
  "mcpServers": {
    "bloom": { "url": "https://bloombook.cn/api/mcp" }
  }
}
```

## Other clients with remote MCP support

MCP endpoint: `https://bloombook.cn/api/mcp` (Streamable HTTP, no authentication).

## Privacy

When you create a study guide, the conversation summary your assistant writes is stored on Bloom's servers to generate that guide. The link expires after 7 days. Don't let your assistant put names, contact details, secrets or other sensitive information in the summary.
