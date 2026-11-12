$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$plugin = Join-Path $root 'plugins/pdmshell'
. (Join-Path $plugin 'scripts/Common.ps1')
$script:passed = 0
function Assert($Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
    $script:passed++
}
function Assert-Throws([scriptblock]$Action, [string]$Pattern) {
    try { & $Action } catch { Assert ($_.Exception.Message -match $Pattern) $_.Exception.Message; return }
    throw "Expected failure: $Pattern"
}
$market = Get-Content (Join-Path $root '.claude-plugin/marketplace.json') -Raw | ConvertFrom-Json
$manifest = Get-Content (Join-Path $plugin '.claude-plugin/plugin.json') -Raw | ConvertFrom-Json
$mcp = Get-Content (Join-Path $plugin '.mcp.json') -Raw | ConvertFrom-Json
Assert ($market.name -eq 'bluebyte' -and $manifest.name -eq 'pdmshell') 'Install ID changed.'
Assert ((Resolve-Path (Join-Path $root $market.plugins[0].source)).Path -eq (Resolve-Path $plugin).Path) 'Marketplace path is invalid.'
Assert ($mcp.mcpServers.pdmshell.command -eq 'node') 'MCP must use the supported Node launcher.'
Assert ($mcp.mcpServers.pdmshell.args[-1] -eq '${CLAUDE_PLUGIN_ROOT}/scripts/start-mcp.mjs') 'MCP launcher path is invalid.'
Assert (Test-Path (Join-Path $plugin 'LICENSE')) 'Plugin license is missing.'
Add-Type -AssemblyName System.Drawing
$icon = [Drawing.Image]::FromFile((Join-Path $plugin '.claude-plugin/icon.png'))
try { Assert ($icon.Width -eq $icon.Height -and $icon.Width -ge 512 -and $icon.Width -le 2048) 'Invalid listing icon size.' } finally { $icon.Dispose() }
foreach ($file in Get-ChildItem $root -Recurse -Filter *.ps1) {
    $tokens = $null; $errors = $null
    [void][Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
    Assert ($errors.Count -eq 0) "PowerShell parse error in $file"
}
$oldOverride = $env:PDMSHELL_MCP_PATH
try {
    $env:PDMSHELL_MCP_PATH = Join-Path $root 'missing-server.exe'
    Assert ($null -eq (Find-PDMShellMcp)) 'Missing override must not fall back.'
    $env:PDMSHELL_MCP_PATH = 'relative.exe'
    Assert-Throws { Find-PDMShellMcp } 'absolute path'
    $env:PDMSHELL_MCP_PATH = $PSHOME + '\powershell.exe'
    Assert ((Find-PDMShellMcp) -eq $env:PDMSHELL_MCP_PATH) 'Custom path was not resolved.'
} finally { $env:PDMSHELL_MCP_PATH = $oldOverride }

# Signature and installer behavior are mocked; no software is installed.
$script:signature = [pscustomobject]@{Status='Valid'; SignerCertificate=[pscustomobject]@{Subject='CN=BLUE BYTE SYSTEMS INC, O=BLUE BYTE SYSTEMS INC, C=CA'}}
function Get-AuthenticodeSignature { param($LiteralPath) $script:signature }
$script:started = 0
$script:exitCode = 0
function Start-Process { param($FilePath, [switch]$PassThru, [switch]$Wait) $script:started++; [pscustomobject]@{ExitCode=$script:exitCode} }
Start-PDMShellInstaller 'fake.exe'
Assert ($script:started -eq 1) 'Verified installer should start.'
$script:signature.Status = 'NotSigned'
Assert-Throws { Start-PDMShellInstaller 'fake.exe' } 'valid Blue Byte'
Assert ($script:started -eq 1) 'Unsigned installer must never start.'
$script:signature.Status = 'Valid'
$script:signature.SignerCertificate.Subject = 'CN=Someone, O=Another Publisher, C=CA'
Assert-Throws { Start-PDMShellInstaller 'fake.exe' } 'valid Blue Byte'
Assert ($script:started -eq 1) 'Wrong publisher must never start.'
$script:signature.SignerCertificate.Subject = 'O=BLUE BYTE SYSTEMS INC, C=CA'
$script:exitCode = 1
Assert-Throws { Start-PDMShellInstaller 'fake.exe' } 'did not complete'
Write-Output "PASS: $script:passed plugin checks. No software installed or vault modified."
