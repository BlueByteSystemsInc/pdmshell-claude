// Optional integration test against the installed server. No vault operations.
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import assert from 'node:assert/strict';
const launcher = fileURLToPath(new URL('../plugins/pdmshell/scripts/Start-PDMShellMcp.ps1', import.meta.url));
const child = spawn('powershell.exe', ['-NoLogo', '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', launcher], { windowsHide: true });
let buffer = '', finished = false;
const timer = setTimeout(() => { console.error('MCP handshake timed out'); child.kill(); process.exitCode = 1; }, 20000);
const send = message => child.stdin.write(JSON.stringify(message) + '\n');
child.stderr.on('data', chunk => process.stderr.write(chunk));
child.on('error', error => { clearTimeout(timer); console.error(error.message); process.exitCode = 1; });
child.stdout.on('data', chunk => {
  buffer += chunk.toString('utf8');
  while (buffer.includes('\n')) {
    const at = buffer.indexOf('\n');
    const line = buffer.slice(0, at).trim(); buffer = buffer.slice(at + 1);
    if (!line) continue;
    try {
      const reply = JSON.parse(line);
      assert.ok(!reply.error, JSON.stringify(reply.error));
      if (reply.id === 1) {
        assert.ok(reply.result.serverInfo);
        send({ jsonrpc: '2.0', method: 'notifications/initialized' });
        send({ jsonrpc: '2.0', id: 2, method: 'tools/list', params: {} });
      } else if (reply.id === 2) {
        assert.ok(reply.result.tools.some(tool => tool.name === 'pdmshell_license_status'));
        send({ jsonrpc: '2.0', id: 3, method: 'tools/call', params: { name: 'pdmshell_license_status', arguments: {} } });
      } else if (reply.id === 3) {
        assert.ok(!reply.result.isError);
        assert.ok(reply.result.content.length);
        console.log('PASS: launcher initialize, tools/list and license-status call. No vault modified.');
        finished = true; clearTimeout(timer); child.stdin.end();
      }
    } catch (error) { clearTimeout(timer); console.error(error.message); child.kill(); process.exitCode = 1; }
  }
});
child.on('exit', code => { clearTimeout(timer); if (!finished || code !== 0) process.exitCode = 1; });
send({ jsonrpc: '2.0', id: 1, method: 'initialize', params: { protocolVersion: '2024-11-05', capabilities: {}, clientInfo: { name: 'pdmshell-plugin-test', version: '1.0.0' } } });
