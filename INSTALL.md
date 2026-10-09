# Install Bloom — instructions for AI assistants

> 给 AI 助手看的安装说明。用户只需要把 README 顶部那段话发给自己的 AI，剩下的由 AI 照这份文件完成。
> This file is written for an AI assistant installing Bloom on the user's behalf.

Bloom (https://bloombook.cn) turns learning conversations into illustrated study guides and lets you search guides already on Bloom. It is a remote MCP server plus a skill:

- MCP endpoint: `https://bloombook.cn/api/mcp` (Streamable HTTP, **no authentication**). Tools: `search_bloom`, `create_learning_material`.
- Skill: [`plugins/bloom/skills/bloom-study/SKILL.md`](plugins/bloom/skills/bloom-study/SKILL.md) — tells the assistant when to search and when to offer a study guide.

## How to work

1. **Figure out which client you are running in** (see the list below). If you can run shell commands, do the steps yourself; otherwise give the user the exact steps for their client, one at a time.
2. **Install idempotently.** If something is already there, update it instead of failing. If an install "succeeds" but the tools still don't show up, do a clean reinstall (remove, then add again) — this fixes stale caches.
3. **Never ask for or print API keys.** Bloom needs none.
4. **New tools only appear in a new session.** After installing, tell the user to restart the app (or open a new conversation) — the current conversation won't see the tools.
5. **Verify** (see below), then tell the user in one or two sentences what you installed and how to use it: just ask learning questions as usual — no need to mention Bloom or use @.

## Claude Code

```sh
claude plugin marketplace add HoloSoul-Team/bloom-plugins   # if it already exists: claude plugin marketplace update bloom
claude plugin install bloom@bloom                           # if already installed: claude plugin update bloom@bloom
```

Clean reinstall if needed:

```sh
claude plugin uninstall bloom@bloom
claude plugin marketplace remove bloom
claude plugin marketplace add HoloSoul-Team/bloom-plugins
claude plugin install bloom@bloom
```

Inside an interactive session the equivalents are `/plugin marketplace add HoloSoul-Team/bloom-plugins`, `/plugin install bloom@bloom`, then `/reload-plugins`.

## Codex and ChatGPT desktop

```sh
codex plugin marketplace add HoloSoul-Team/bloom-plugins   # if it already exists: codex plugin marketplace upgrade bloom
codex plugin add bloom@bloom
```

Clean reinstall if needed:

```sh
codex plugin remove bloom@bloom
codex plugin marketplace remove bloom
codex plugin marketplace add HoloSoul-Team/bloom-plugins
codex plugin add bloom@bloom
```

The Codex CLI and desktop app share `~/.codex`. After adding the marketplace, fully quit and reopen the desktop app (Codex or ChatGPT) and start a new conversation; Bloom also shows up in the app's plugin directory, where it can be installed or reinstalled.

## Gemini CLI

```sh
gemini extensions install https://github.com/HoloSoul-Team/bloom-plugins --consent   # already installed: gemini extensions update bloom-plugins
```

## Cursor

Merge this entry into `~/.cursor/mcp.json` (Windows: `%USERPROFILE%\.cursor\mcp.json`). Keep the user's existing servers; create the file if it doesn't exist. Then restart Cursor.

```json
{ "mcpServers": { "bloom": { "url": "https://bloombook.cn/api/mcp" } } }
```

## Claude Desktop

Claude Desktop's custom connectors require sign-in, so use a local bridge (needs Node.js). Merge into `claude_desktop_config.json` — macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`, Windows: `%APPDATA%\Claude\claude_desktop_config.json` — keeping existing entries, then fully restart Claude Desktop.

```json
{ "mcpServers": { "bloom": { "command": "npx", "args": ["-y", "mcp-remote", "https://bloombook.cn/api/mcp"] } } }
```

## WorkBuddy

1. Connect the server: Settings → Connectors → Add, address `https://bloombook.cn/api/mcp` (or add `{"mcpServers":{"bloom":{"url":"https://bloombook.cn/api/mcp"}}}` to its MCP config).
2. Add the skill: copy the folder `plugins/bloom/skills/bloom-study` from this repo into `~/.workbuddy/skills/`, then restart WorkBuddy.

```sh
git clone --depth 1 https://github.com/HoloSoul-Team/bloom-plugins.git /tmp/bloom-plugins
mkdir -p ~/.workbuddy/skills && cp -R /tmp/bloom-plugins/plugins/bloom/skills/bloom-study ~/.workbuddy/skills/
```

## Any other client

- Supports remote MCP over HTTP: add `https://bloombook.cn/api/mcp`, no auth.
- Only supports local (command) MCP servers: command `npx`, args `-y mcp-remote https://bloombook.cn/api/mcp`.
- Supports skills / custom instructions: also add the content of `SKILL.md`.

## Verify

1. The server is reachable from this machine:

   ```sh
   curl -sS -X POST https://bloombook.cn/api/mcp -H 'content-type: application/json' -H 'accept: application/json, text/event-stream' -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
   ```

   The response lists `search_bloom` and `create_learning_material`.
2. In a **new** session, call `search_bloom` with `{"query": "扩散模型"}`. It returns a few results with `title` and `url`.

## Troubleshooting

- **Tools missing in the conversation:** the install only takes effect in a new session — restart the app or open a new conversation. If they're still missing, do the clean reinstall above.
- **Handshake timeout / "error sending request" while `curl` works:** a proxy app (Clash, ClashX, Surge…) is routing the AI client through a server that cannot reach mainland China. Tell the user and suggest making `bloombook.cn` connect directly — e.g. add `- DOMAIN-SUFFIX,bloombook.cn,DIRECT` at the top of the Clash `rules:` list, or set `NO_PROXY=bloombook.cn` before starting the client. Ask before editing the user's proxy configuration.
- **"请求太频繁 / Too many requests":** wait a while and try again; don't retry in a loop.
