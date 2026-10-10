# Install Bloom — instructions for AI assistants

> 给 AI 助手看的安装说明。用户只需要把 README 顶部那段话发给自己的 AI，剩下的由 AI 照这份文件完成。
> This file is written for an AI assistant installing Bloom on the user's behalf.

Bloom (https://bloombook.cn) turns learning conversations into illustrated study guides and lets you search guides already on Bloom. It is a remote MCP server plus a skill:

- MCP endpoint: `https://bloombook.cn/api/mcp` (Streamable HTTP, **no authentication**). Tools: `search_bloom`, `create_learning_material`.
- Skill: [`plugins/bloom/skills/bloom-study/SKILL.md`](plugins/bloom/skills/bloom-study/SKILL.md) — tells the assistant when to search and when to offer a study guide.

## Do this first: run the installer

If you can run shell commands, run this one command and you are done — do not do the per-client steps below by hand:

```sh
curl -fsSL https://bloombook.cn/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://bloombook.cn/install.ps1 | iex
```

It detects every supported client on the machine (Claude Code, Codex / ChatGPT desktop, Gemini CLI, Cursor, WorkBuddy, Claude Desktop), installs or updates Bloom for each, keeps the user's existing settings, and prints what the user still has to do. **Relay that last part of its output to the user word for word** — it is the only thing left.

To install for some clients only, name them: `curl -fsSL https://bloombook.cn/install.sh | sh -s -- workbuddy cursor` (names: `claude codex gemini cursor workbuddy claude-desktop`).

If you cannot run shell commands, give the user that one command to paste into their terminal.

Rules:

1. **Never ask for or print API keys.** Bloom needs none.
2. **New tools only appear in a new session.** Do not try to call `search_bloom` in the current conversation to "verify" — it will not be there. Tell the user to restart the app or open a new conversation.
3. **WorkBuddy needs one click from the user** that you cannot do: after restarting WorkBuddy, they open Connectors → Custom connector and click **Trust** on the `bloom` row. Until then the tools do not exist. Do not report the install as finished without telling them this.
4. Afterwards, tell the user in one or two sentences how to use it: just ask learning questions as usual — no need to mention Bloom or use @.

The sections below are the manual steps the installer performs. Use them only if the installer fails for a client.

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

1. Merge this entry into `~/.workbuddy/mcp.json` (exactly this path and filename; Windows: `%USERPROFILE%\.workbuddy\mcp.json`). Keep the user's existing servers; create the file if it doesn't exist.

   ```json
   { "mcpServers": { "bloom": { "type": "http", "url": "https://bloombook.cn/api/mcp" } } }
   ```

2. Put the skill at `~/.workbuddy/skills/bloom-study/SKILL.md`:

   ```sh
   mkdir -p ~/.workbuddy/skills/bloom-study && curl -fsSL https://raw.githubusercontent.com/HoloSoul-Team/bloom-plugins/main/plugins/bloom/skills/bloom-study/SKILL.md -o ~/.workbuddy/skills/bloom-study/SKILL.md
   ```

3. The user must do this part: **restart WorkBuddy** (it only reads the config at startup), open **Connectors** in the left sidebar → **Custom connector** (top right), and click **Trust** on the `bloom` row. It then connects and lists two tools.

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
- **WorkBuddy: config is written but the tools don't exist / "No connectors installed":** WorkBuddy has not been restarted, or the user has not clicked Trust yet (Connectors → Custom connector → `bloom` row). Both are needed, then a new task.
- **Handshake timeout / "error sending request" while `curl` works:** a proxy app (Clash, ClashX, Surge…) is routing the AI client through a server that cannot reach mainland China. Tell the user and suggest making `bloombook.cn` connect directly — e.g. add `- DOMAIN-SUFFIX,bloombook.cn,DIRECT` at the top of the Clash `rules:` list, or set `NO_PROXY=bloombook.cn` before starting the client. Ask before editing the user's proxy configuration.
- **"请求太频繁 / Too many requests":** wait a while and try again; don't retry in a loop.
