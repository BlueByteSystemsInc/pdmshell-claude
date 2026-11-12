. (Join-Path $PSScriptRoot 'Common.ps1')
try {
    $server = Find-PDMShellMcp
    if (-not $server) { throw 'PDMShell MCP is not installed. Run /pdmshell:setup, then reconnect with /mcp.' }
    $start = New-Object System.Diagnostics.ProcessStartInfo
    $start.FileName = $server
    $start.WorkingDirectory = Split-Path -Parent $server
    $start.UseShellExecute = $false
    # Inherit stdin/stdout/stderr directly; never put PowerShell formatting in MCP output.
    $process = [Diagnostics.Process]::Start($start)
    try { $process.WaitForExit(); exit $process.ExitCode } finally { $process.Dispose() }
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
