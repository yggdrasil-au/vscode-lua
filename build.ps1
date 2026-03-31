# build.ps1

# 1. Initialize Submodules and Build Server (Ref: make.bat)
Write-Host "--- Initializing Submodules and Building Server ---" -ForegroundColor Cyan
# git submodule update --init --recursive

Set-Location "server"
Set-Location "3rd\luamake"
cmd /c "compile\build.bat"
Set-Location "..\.."

# Define the command and arguments based on user input 
$luamakePath = ".\3rd\luamake\luamake.exe"
$buildArgs = if ($args.Count -eq 0) { "rebuild" } else { "rebuild --platform $($args[0])" }

Write-Host "Launching build in new window..." -ForegroundColor Yellow

# Start the process in a new PowerShell window
# We wrap the command in a script block that exits with the tool's exit code
$process = Start-Process powershell -ArgumentList "-Command", "& { & '$luamakePath' $buildArgs; exit `$LASTEXITCODE }" -Wait -PassThru

# Capture and return the status
$exitStatus = $process.ExitCode

if ($exitStatus -eq 0) {
    Write-Host "Build completed successfully (Exit Code: 0)." -ForegroundColor Green
} else {
    Write-Error "Build failed in the external window with Exit Code: $exitStatus"
    exit $exitStatus
}
Set-Location "../"

# 2. Build Client and WebVue (Ref: buildClient.bat)
Write-Host "`n--- Building VS Code Extension Client ---" -ForegroundColor Cyan
Set-Location "client"
pnpm install
pnpm run build

Set-Location "../"

# 3. Prepare Publish Directory (Ref: publish.lua)
Write-Host "`n--- Preparing Distribution Folder ---" -ForegroundColor Cyan
$packageJson = Get-Content "package.json" | ConvertFrom-Json
$version = $packageJson.version
$publishDir = "publish/test"

if (Test-Path $publishDir) {
    Remove-Item -Recurse -Force $publishDir
}
New-Item -ItemType Directory -Path $publishDir | Out-Null


$readmeContent = Get-Content "server/README.md"
$readmeContent -replace '\.svg', '.png' | Set-Content "README.md"

# 4. Copy Files to Staging (Selective Copying)
Write-Host "Copying files to $publishDir..." -ForegroundColor Yellow

$includeList = @(
    "LICENSE",
    #".vscodeignore",
    "client/node_modules",
    "client/out",
    "client/package.json",
    "client/3rd/vscode-lua-doc/doc",
    "client/3rd/vscode-lua-doc/extension.js",
    "client/web",
    "server/bin",
    "server/doc",
    "server/locale",
    "server/script",
    "server/main.lua",
    "server/debugger.lua",
    "server/meta/template",
    "server/meta/3rd",
    "server/meta/spell",
    "images/logo.png",
    "syntaxes",
    "package.json",
    "README.md",
    "package.nls.json",
    "package.nls.zh-cn.json",
    "package.nls.zh-tw.json",
    "package.nls.pt-br.json"
)

foreach ($item in $includeList) {
    $source = Join-Path (Get-Location) $item
    $destination = Join-Path $publishDir $item
    
    if (Test-Path $source) {
        $parent = Split-Path $destination
        if (!(Test-Path $parent)) { New-Item -ItemType Directory -Path $parent | Out-Null }
        Copy-Item -Path $source -Destination $destination -Recurse -Force
    }
}

# 5. Cleanup unnecessary files (Ref: publish.lua)
Write-Host "Cleaning up staging directory..." -ForegroundColor Yellow
$cleanupList = @(
    "server/log",
    "server/meta/Lua 5.4 zh-cn"
)

foreach ($item in $cleanupList) {
    $path = Join-Path $publishDir $item
    if (Test-Path $path) { Remove-Item -Recurse -Force $path }
}

# 6. Package VSIX
Write-Host "`n--- Packaging VSIX ---" -ForegroundColor Cyan
if (Get-Command vsce -ErrorAction SilentlyContinue) {
    $vsixName = "lua-$version.vsix"
    Set-Location $publishDir
    vsce package -o "../../$vsixName"
    Set-Location "../.."
    Write-Host "Successfully created $vsixName" -ForegroundColor Green
} else {
    Write-Error "vsce command not found. Please install it via 'pnpm install -g @vscode/vsce'"
}