[CmdletBinding()]
param([switch]$Install)
. (Join-Path $PSScriptRoot 'Common.ps1')
try {
    $server = Find-PDMShellMcp
    if ($server) {
        Write-Output "PDMShell MCP found: $server"
        Write-Output 'Use /mcp to reconnect PDMShell, then check its license status.'
        exit 0
    }
    if (-not $Install) {
        Write-Output 'PDMShell MCP was not found. With your approval, setup can download and open the official PDMShell installer.'
        Write-Output 'The SOLIDWORKS PDM client must already be installed. Run again with -Install after approving installation.'
        exit 2
    }
    if ($env:PDMSHELL_MCP_PATH) { throw 'The configured PDMSHELL_MCP_PATH does not exist. Correct or remove it before installing.' }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $download = 'https://bluebyte.biz/wp-json/slm_custom/downloadpdmshell'
    $scratch = Join-Path ([IO.Path]::GetTempPath()) ('pdmshell-setup-' + [Guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($scratch)
    $archive = Join-Path $scratch 'pdmshell.zip'
    Write-Output 'Downloading the official PDMShell installer...'
    Invoke-WebRequest -Uri $download -OutFile $archive -UseBasicParsing -TimeoutSec 600
    $destination = Join-Path $scratch 'installer'
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Compression.ZipFile]::ExtractToDirectory($archive, $destination)
    $installers = @(Get-ChildItem -LiteralPath $destination -Filter pdmcli_installer.exe -Recurse -File)
    if ($installers.Count -ne 1) { throw 'The download must contain exactly one pdmcli_installer.exe.' }
    Write-Output 'Verifying the publisher and opening the installer. Complete the installer window to continue.'
    Start-PDMShellInstaller $installers[0].FullName
    $server = Find-PDMShellMcp
    if (-not $server) { throw 'The installer closed, but the MCP server was not found. Complete or repair PDMShell installation.' }
    Write-Output "Installed PDMShell MCP: $server"
    Write-Output 'Reconnect PDMShell with /mcp, then check its license status. Download files remain in the Windows temporary folder.'
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
