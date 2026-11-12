---
name: setup
description: Check or install PDMShell for the local SOLIDWORKS PDM MCP connection on Windows.
---

Run the bundled `scripts/Setup-PDMShell.ps1` from this plugin's root with native Windows PowerShell (`powershell.exe -NoProfile -ExecutionPolicy Bypass -File "<plugin-root>/scripts/Setup-PDMShell.ps1"`). Resolve the plugin root from this skill's location, two levels above this folder. Quote its absolute path.

The initial check does not download or install anything. Exit 2 means PDMShell is missing. Explain that PDMShell installs the MCP server, requires the SOLIDWORKS PDM client, and uses its own licensing. Ask the user whether to download and open the official installer. Only after they approve, run the same script with `-Install`. Let the user complete the interactive installer. Do not install or update the PDM client, accept licensing terms, or install a shared vault add-in on their behalf.

If PDMShell is found, reconnect its server with `/mcp` (or restart Claude Code). Call `pdmshell_license_status` to verify the connection. Report licensing requirements accurately; installation alone does not grant a license. Do not run a vault operation merely to test connectivity.

For a custom installation, the user can set `PDMSHELL_MCP_PATH` to the full path of `pdmcli.mcp.exe` before starting Claude Code. Native Windows is required; do not attempt this setup in WSL or on macOS/Linux.
