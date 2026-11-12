# PDMShell for Claude Code

![PDMShell](.claude-plugin/icon.png)

Find files, inspect data cards and references, and perform requested SOLIDWORKS PDM operations through your local PDMShell installation.

Requires native Windows, Node.js on PATH, the SOLIDWORKS PDM client, a local vault view, and PDMShell. PDMShell licensing applies separately. The plugin is proprietary; see [LICENSE](LICENSE).

## Setup

Run `/pdmshell:setup`. It checks for PDMShell, asks before downloading and opening the official installer, and verifies the Blue Byte Systems publisher signature. Reconnect with `/mcp` after installation.

Try: “Find drawings in my sandbox vault and show their IDs and revisions. Do not change files.”

## What runs on your computer

The local MCP entry starts the bundled Node script directly. That script starts the installed PDMShell MCP executable, normally under your Windows Local AppData folder. It does not download software, use a shell, or log in to a vault. An optional `PDMSHELL_MCP_PATH` environment variable can select a custom installation.

The setup skill invokes bundled PowerShell scripts only when used. `-NoProfile` avoids user profile scripts, `-File` names the bundled setup script, and process-scoped `-ExecutionPolicy Bypass` allows that script to run without changing the machine's policy. `-Install` downloads and opens the official installer only after approval. Installation remains interactive.

This is a local stdio server for native Windows Claude Code, not a remote connector for claude.ai chat. Directory review and organization verification requirements still apply; using a Node launcher does not remove those requirements.

[User guide](https://pdmshell.com/src/claude-code.html) · [Repository](https://github.com/BlueByteSystemsInc/pdmshell-claude)
