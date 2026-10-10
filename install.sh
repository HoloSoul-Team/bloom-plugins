#!/bin/sh
# Bloom installer — detects the AI clients on this machine and connects each one to Bloom.
#
#   curl -fsSL https://bloombook.cn/install.sh | sh
#
# Install for specific clients only:
#   curl -fsSL .../install.sh | sh -s -- workbuddy cursor
# Clients: claude codex gemini cursor workbuddy claude-desktop
#
# Safe to run again: existing settings are kept, Bloom is added or updated.

set -u

REPO="HoloSoul-Team/bloom-plugins"
MCP_URL="https://bloombook.cn/api/mcp"
# The skill is tried from bloombook.cn first (reachable without a proxy in mainland China), then GitHub.
SKILL_URLS="${BLOOM_SKILL_URL:-https://bloombook.cn/bloom-plugin/SKILL.md https://raw.githubusercontent.com/$REPO/main/plugins/bloom/skills/bloom-study/SKILL.md}"

ONLY="$*"
DONE=""
NOTES=""

say() { printf '%s\n' "$*"; }
want() { [ -z "$ONLY" ] && return 0; case " $ONLY " in *" $1 "*) return 0 ;; esac; return 1; }
has() { command -v "$1" >/dev/null 2>&1; }
note() { NOTES="$NOTES
  - $*"; }
done_for() { DONE="$DONE $1"; }

# merge_mcp <file> <entry-json>: set mcpServers.bloom in a JSON file, keeping everything else.
merge_mcp() {
  file="$1"; entry="$2"
  mkdir -p "$(dirname "$file")"
  if [ ! -s "$file" ]; then
    printf '{\n  "mcpServers": {\n    "bloom": %s\n  }\n}\n' "$entry" > "$file"
    return 0
  fi
  node_bin=""
  if has node; then node_bin="node"
  elif [ -x "$HOME/.workbuddy/binaries/node/versions/current/bin/node" ]; then
    node_bin="$HOME/.workbuddy/binaries/node/versions/current/bin/node"
  fi
  if [ -n "$node_bin" ]; then
    "$node_bin" -e '
      const fs = require("fs"); const [file, entry] = process.argv.slice(1);
      const cfg = JSON.parse(fs.readFileSync(file, "utf8"));
      if (typeof cfg !== "object" || cfg === null || Array.isArray(cfg)) process.exit(2);
      cfg.mcpServers = Object.assign({}, cfg.mcpServers, { bloom: JSON.parse(entry) });
      fs.copyFileSync(file, file + ".bloom-backup");
      fs.writeFileSync(file, JSON.stringify(cfg, null, 2) + "\n");
    ' "$file" "$entry" 2>/dev/null
    return $?
  fi
  # macOS ships a python3 stub that opens an installer dialog unless the developer tools exist.
  if has python3 && { [ "$(uname)" != "Darwin" ] || [ "$(command -v python3)" != "/usr/bin/python3" ] || xcode-select -p >/dev/null 2>&1; }; then
    python3 - "$file" "$entry" 2>/dev/null <<'PY'
import json, shutil, sys
path, entry = sys.argv[1], sys.argv[2]
with open(path, encoding="utf-8") as f:
    cfg = json.load(f)
if not isinstance(cfg, dict):
    sys.exit(2)
servers = cfg.get("mcpServers")
if not isinstance(servers, dict):
    servers = {}
servers["bloom"] = json.loads(entry)
cfg["mcpServers"] = servers
shutil.copyfile(path, path + ".bloom-backup")
with open(path, "w", encoding="utf-8") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
    return $?
  fi
  return 3
}

merge_failed() {
  say "  ! 没能自动修改 $1（文件不是合法 JSON，或本机没有 node / python3）。"
  say "    请手动在它的 mcpServers 里加上: \"bloom\": $2"
}

install_claude() {
  say "→ Claude Code"
  claude plugin marketplace add "$REPO" </dev/null >/dev/null 2>&1 || claude plugin marketplace update bloom </dev/null >/dev/null 2>&1
  if claude plugin install bloom@bloom </dev/null >/dev/null 2>&1 || claude plugin update bloom@bloom </dev/null >/dev/null 2>&1; then
    done_for "Claude-Code"; note "Claude Code：新开一个会话即可（已在会话里就输入 /reload-plugins）。"
  else
    say "  ! 安装失败，请手动运行: claude plugin marketplace add $REPO && claude plugin install bloom@bloom"
  fi
}

install_codex() {
  say "→ Codex / ChatGPT 桌面版"
  codex plugin marketplace add "$REPO" </dev/null >/dev/null 2>&1 || codex plugin marketplace upgrade bloom </dev/null >/dev/null 2>&1
  if codex plugin add bloom@bloom </dev/null >/dev/null 2>&1; then
    done_for "Codex"; note "Codex / ChatGPT 桌面版：完全退出后重新打开，新开一个对话。"
  else
    say "  ! 安装失败，请手动运行: codex plugin marketplace add $REPO && codex plugin add bloom@bloom"
  fi
}

install_gemini() {
  say "→ Gemini CLI"
  if gemini extensions install "https://github.com/$REPO" --consent </dev/null >/dev/null 2>&1 \
    || gemini extensions update bloom-plugins </dev/null >/dev/null 2>&1; then
    done_for "Gemini-CLI"; note "Gemini CLI：重新启动 gemini。"
  else
    say "  ! 安装失败，请手动运行: gemini extensions install https://github.com/$REPO"
  fi
}

install_cursor() {
  say "→ Cursor"
  entry="{ \"url\": \"$MCP_URL\" }"
  if merge_mcp "$HOME/.cursor/mcp.json" "$entry"; then
    done_for "Cursor"; note "Cursor：重启 Cursor。"
  else
    merge_failed "$HOME/.cursor/mcp.json" "$entry"
  fi
}

install_workbuddy() {
  say "→ WorkBuddy"
  entry="{ \"type\": \"http\", \"url\": \"$MCP_URL\" }"
  if ! merge_mcp "$HOME/.workbuddy/mcp.json" "$entry"; then
    merge_failed "$HOME/.workbuddy/mcp.json" "$entry"
    return
  fi
  skill_dir="$HOME/.workbuddy/skills/bloom-study"
  mkdir -p "$skill_dir"
  got=0
  for url in $SKILL_URLS; do
    # A real skill file starts with front matter; anything else is an error page.
    if curl -fsSL -m 20 "$url" -o "$skill_dir/SKILL.md.tmp" 2>/dev/null && [ "$(head -c 3 "$skill_dir/SKILL.md.tmp")" = "---" ]; then
      mv "$skill_dir/SKILL.md.tmp" "$skill_dir/SKILL.md"; got=1; break
    fi
  done
  rm -f "$skill_dir/SKILL.md.tmp"
  if [ "$got" = 0 ]; then
    say "  ! 技能文件下载失败（不影响工具使用，只是不会自动推荐）。稍后重新运行本命令即可。"
  fi
  done_for "WorkBuddy"
  note "WorkBuddy：重启 WorkBuddy → 左侧「连接器」→ 右上角「自定义连接器」→ 在 bloom 那一行点「信任」。（只需点这一次）"
}

install_claude_desktop() {
  say "→ Claude Desktop"
  if ! has npx; then
    say "  ! Claude Desktop 需要 Node.js（https://nodejs.org），装好后重新运行本命令。"
    return
  fi
  entry="{ \"command\": \"npx\", \"args\": [\"-y\", \"mcp-remote\", \"$MCP_URL\"] }"
  if merge_mcp "$1" "$entry"; then
    done_for "Claude-Desktop"; note "Claude Desktop：完全退出后重新打开。"
  else
    merge_failed "$1" "$entry"
  fi
}

say "Bloom 安装器 · bloombook.cn"
say ""

FOUND=0

if want claude && has claude; then FOUND=1; install_claude; fi
if want codex && has codex; then FOUND=1; install_codex; fi
if want gemini && has gemini; then FOUND=1; install_gemini; fi
if want cursor && [ -d "$HOME/.cursor" ]; then FOUND=1; install_cursor; fi
if want workbuddy && [ -d "$HOME/.workbuddy" ]; then FOUND=1; install_workbuddy; fi

case "$(uname)" in
  Darwin) DESKTOP_DIR="$HOME/Library/Application Support/Claude" ;;
  *) DESKTOP_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Claude" ;;
esac
if want claude-desktop && [ -d "$DESKTOP_DIR" ]; then
  FOUND=1; install_claude_desktop "$DESKTOP_DIR/claude_desktop_config.json"
fi

say ""
if [ "$FOUND" = 0 ]; then
  if [ -n "$ONLY" ]; then
    say "没有在这台电脑上找到: ${ONLY}。请先安装并打开一次对应的应用，再运行本命令。"
  else
    say "没有在这台电脑上找到支持的 AI 客户端（Claude Code、Codex、Gemini CLI、Cursor、WorkBuddy、Claude Desktop）。"
    say "其它客户端可以手动添加 MCP 地址: $MCP_URL"
  fi
  exit 1
fi

if [ -z "$DONE" ]; then
  say "没有安装成功，请看上面的提示。"
  exit 1
fi

say "已安装:$DONE"
say "还差一步:$NOTES"
say ""
say "之后照常问学习问题就行（比如「我想了解一下扩散模型」），不用 @ 插件。"
