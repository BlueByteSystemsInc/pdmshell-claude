# PDMShell for Claude Code

Connect Claude Code to SOLIDWORKS PDM using the PDMShell MCP server installed on your Windows computer.

## Install the plugin

In Claude Code:

```text
/plugin marketplace add BlueByteSystemsInc/pdmshell-claude
/plugin install pdmshell@bluebyte
/pdmshell:setup
```

Setup checks for PDMShell. If missing, it asks before downloading and opening the official signed installer. Complete that window, then reconnect PDMShell with `/mcp` or restart Claude Code. The plugin never installs software just because its MCP server starts.

You need native Windows, the SOLIDWORKS PDM client and a local vault view. PDMShell licensing applies; ask Claude to check the license status. The PDM client is not installed by this plugin. Installing the shared vault add-in is optional and is not required for the MCP connection.

Then ask, for example:

> Find drawings in my sandbox vault and show their file IDs and revisions. Do not change any files.

## Existing or custom installations

The launcher uses `%LOCALAPPDATA%\Blue Byte Systems\PDMShell\current\MCP\pdmcli.mcp.exe`. It uses your installed PDMShell version and does not bundle the application or credentials.

For a custom location, set `PDMSHELL_MCP_PATH` to the full executable path before starting Claude Code. A missing override is reported rather than silently using another installation.

The setup check can also be run directly:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\plugins\pdmshell\scripts\Setup-PDMShell.ps1
```

Exit 0 means installed; 2 means missing; 1 means a setup error. Add `-Install` only when you want to download and open the installer. Setup verifies its Authenticode signature and Blue Byte Systems publisher before running it.

## Troubleshooting

- **MCP not installed:** run `/pdmshell:setup`, complete installation, then reconnect using `/mcp`.
- **No vault:** install/configure the SOLIDWORKS PDM client and local vault view first.
- **License message:** follow the PDMShell license status result. Plugin installation does not activate Premium or bypass a trial limit.
- **Signature or download failure:** stop and contact support; do not bypass the signature check.
- **WSL, macOS or Linux:** use Claude Code natively on the Windows computer with PDM installed.

This package targets Claude Code. For Claude Desktop, use [PDMShell's desktop setup guide](https://pdmshell.com/src/mcp-server.html). Publication here does not imply inclusion in Anthropic's curated directory.

## Development

```powershell
powershell.exe -NoProfile -File .\tests\Test-Plugin.ps1
claude plugin validate .
claude plugin validate .\plugins\pdmshell
claude --plugin-dir .\plugins\pdmshell
```

Tests do not install software or modify a vault. Application source and releases are maintained separately from this integration.
