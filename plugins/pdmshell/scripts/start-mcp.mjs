import { spawn } from 'node:child_process';
import { existsSync } from 'node:fs';
import path from 'node:path';

try {
  if (process.platform !== 'win32') throw new Error('PDMShell requires native Windows and the SOLIDWORKS PDM client.');
  const override = process.env.PDMSHELL_MCP_PATH;
  if (!override && !process.env.LOCALAPPDATA) throw new Error('Windows LOCALAPPDATA is unavailable.');
  const server = override || path.join(process.env.LOCALAPPDATA, 'Blue Byte Systems', 'PDMShell', 'current', 'MCP', 'pdmcli.mcp.exe');
  if (!path.isAbsolute(server) || path.basename(server).toLowerCase() !== 'pdmcli.mcp.exe')
    throw new Error('PDMSHELL_MCP_PATH must be the absolute path to pdmcli.mcp.exe.');
  if (!existsSync(server)) throw new Error('PDMShell MCP was not found. Run /pdmshell:setup, then reconnect with /mcp.');
  // Start the installed .exe directly, without a shell, downloads or installation.
  const child = spawn(server, [], { cwd: path.dirname(server), stdio: 'inherit', windowsHide: true, shell: false });
  child.on('error', error => { console.error(error.message); process.exitCode = 1; });
  child.on('exit', code => { process.exitCode = code ?? 1; });
  for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => child.kill());
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
