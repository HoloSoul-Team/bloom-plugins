# Bloom installer for Windows — detects the AI clients on this PC and connects each one to Bloom.
#
#   irm https://bloombook.cn/install.ps1 | iex
#
# Safe to run again: existing settings are kept, Bloom is added or updated.

$ErrorActionPreference = 'Stop'

$Repo = 'HoloSoul-Team/bloom-plugins'
$McpUrl = 'https://bloombook.cn/api/mcp'
# The skill is tried from bloombook.cn first (reachable without a proxy in mainland China), then GitHub.
$SkillUrls = @(
  'https://bloombook.cn/bloom-plugin/SKILL.md',
  "https://raw.githubusercontent.com/$Repo/main/plugins/bloom/skills/bloom-study/SKILL.md"
)

$installed = @()
$notes = @()

function Test-Cmd($name) { [bool](Get-Command $name -ErrorAction SilentlyContinue) }

# Set mcpServers.bloom in a JSON file, keeping everything else.
function Merge-Mcp($file, $entry) {
  $dir = Split-Path -Parent $file
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
  $cfg = $null
  if ((Test-Path $file) -and ((Get-Item $file).Length -gt 0)) {
    try { $cfg = Get-Content -Raw -Encoding UTF8 $file | ConvertFrom-Json } catch { return $false }
    if ($cfg -isnot [pscustomobject]) { return $false }
    Copy-Item $file "$file.bloom-backup" -Force
  } else {
    $cfg = [pscustomobject]@{}
  }
  if (-not ($cfg.PSObject.Properties.Name -contains 'mcpServers') -or $cfg.mcpServers -isnot [pscustomobject]) {
    $cfg | Add-Member -NotePropertyName mcpServers -NotePropertyValue ([pscustomobject]@{}) -Force
  }
  $cfg.mcpServers | Add-Member -NotePropertyName bloom -NotePropertyValue $entry -Force
  $json = $cfg | ConvertTo-Json -Depth 32
  [IO.File]::WriteAllText($file, $json + "`n", (New-Object Text.UTF8Encoding($false)))
  return $true
}

function Show-MergeFailed($file, $hint) {
  Write-Host "  ! 没能自动修改 $file（文件不是合法 JSON）。"
  Write-Host "    请手动在它的 mcpServers 里加上: `"bloom`": $hint"
}

function Invoke-Quiet($exe, $cmdArgs) {
  try { & $exe @cmdArgs *> $null; return ($LASTEXITCODE -eq 0) } catch { return $false }
}

Write-Host 'Bloom 安装器 · bloombook.cn'
Write-Host ''

if (Test-Cmd claude) {
  Write-Host '→ Claude Code'
  if (-not (Invoke-Quiet claude @('plugin', 'marketplace', 'add', $Repo))) {
    Invoke-Quiet claude @('plugin', 'marketplace', 'update', 'bloom') | Out-Null
  }
  if ((Invoke-Quiet claude @('plugin', 'install', 'bloom@bloom')) -or (Invoke-Quiet claude @('plugin', 'update', 'bloom@bloom'))) {
    $installed += 'Claude Code'; $notes += 'Claude Code：新开一个会话即可（已在会话里就输入 /reload-plugins）。'
  } else {
    Write-Host "  ! 安装失败，请手动运行: claude plugin marketplace add $Repo; claude plugin install bloom@bloom"
  }
}

if (Test-Cmd codex) {
  Write-Host '→ Codex / ChatGPT 桌面版'
  if (-not (Invoke-Quiet codex @('plugin', 'marketplace', 'add', $Repo))) {
    Invoke-Quiet codex @('plugin', 'marketplace', 'upgrade', 'bloom') | Out-Null
  }
  if (Invoke-Quiet codex @('plugin', 'add', 'bloom@bloom')) {
    $installed += 'Codex'; $notes += 'Codex / ChatGPT 桌面版：完全退出后重新打开，新开一个对话。'
  } else {
    Write-Host "  ! 安装失败，请手动运行: codex plugin marketplace add $Repo; codex plugin add bloom@bloom"
  }
}

if (Test-Cmd gemini) {
  Write-Host '→ Gemini CLI'
  if ((Invoke-Quiet gemini @('extensions', 'install', "https://github.com/$Repo", '--consent')) -or (Invoke-Quiet gemini @('extensions', 'update', 'bloom-plugins'))) {
    $installed += 'Gemini CLI'; $notes += 'Gemini CLI：重新启动 gemini。'
  } else {
    Write-Host "  ! 安装失败，请手动运行: gemini extensions install https://github.com/$Repo"
  }
}

$cursorDir = Join-Path $HOME '.cursor'
if (Test-Path $cursorDir) {
  Write-Host '→ Cursor'
  $file = Join-Path $cursorDir 'mcp.json'
  if (Merge-Mcp $file ([pscustomobject]@{ url = $McpUrl })) {
    $installed += 'Cursor'; $notes += 'Cursor：重启 Cursor。'
  } else {
    Show-MergeFailed $file "{ `"url`": `"$McpUrl`" }"
  }
}

$wbDir = Join-Path $HOME '.workbuddy'
if (Test-Path $wbDir) {
  Write-Host '→ WorkBuddy'
  $file = Join-Path $wbDir 'mcp.json'
  if (Merge-Mcp $file ([pscustomobject]@{ type = 'http'; url = $McpUrl })) {
    $skillDir = Join-Path $wbDir 'skills\bloom-study'
    New-Item -ItemType Directory -Force $skillDir | Out-Null
    $got = $false
    foreach ($url in $SkillUrls) {
      try {
        Invoke-WebRequest -UseBasicParsing $url -OutFile (Join-Path $skillDir 'SKILL.md') -TimeoutSec 20
        $got = $true; break
      } catch { }
    }
    if (-not $got) {
      Write-Host '  ! 技能文件下载失败（不影响工具使用，只是不会自动推荐）。稍后重新运行本命令即可。'
    }
    $installed += 'WorkBuddy'
    $notes += 'WorkBuddy：重启 WorkBuddy → 左侧「连接器」→ 右上角「自定义连接器」→ 在 bloom 那一行点「信任」。（只需点这一次）'
  } else {
    Show-MergeFailed $file "{ `"type`": `"http`", `"url`": `"$McpUrl`" }"
  }
}

$desktopDir = Join-Path $env:APPDATA 'Claude'
if (Test-Path $desktopDir) {
  Write-Host '→ Claude Desktop'
  if (-not (Test-Cmd npx)) {
    Write-Host '  ! Claude Desktop 需要 Node.js（https://nodejs.org），装好后重新运行本命令。'
  } else {
    $file = Join-Path $desktopDir 'claude_desktop_config.json'
    $entry = [pscustomobject]@{ command = 'npx'; args = @('-y', 'mcp-remote', $McpUrl) }
    if (Merge-Mcp $file $entry) {
      $installed += 'Claude Desktop'; $notes += 'Claude Desktop：完全退出后重新打开。'
    } else {
      Show-MergeFailed $file "{ `"command`": `"npx`", `"args`": [`"-y`", `"mcp-remote`", `"$McpUrl`"] }"
    }
  }
}

Write-Host ''
if ($installed.Count -eq 0) {
  Write-Host '没有安装成功：没有在这台电脑上找到支持的 AI 客户端（Claude Code、Codex、Gemini CLI、Cursor、WorkBuddy、Claude Desktop），或上面的步骤失败了。'
  Write-Host "其它客户端可以手动添加 MCP 地址: $McpUrl"
  return
}

Write-Host ('已安装: ' + ($installed -join '、'))
Write-Host '还差一步:'
$notes | ForEach-Object { Write-Host "  - $_" }
Write-Host ''
Write-Host '之后照常问学习问题就行（比如「我想了解一下扩散模型」），不用 @ 插件。'
