# 公司（断网）机器上执行：校验 SHA256 → docker load 镜像 → 生成配置模板
#
# 用法：
#   .\load_bundle.ps1 -Bundle E:\bench-bundle
#   .\load_bundle.ps1 -Bundle E:\bench-bundle -SkipVerify   # 紧急/自测时跳过校验
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Bundle,
    [switch]$SkipVerify
)

$ErrorActionPreference = "Stop"
$imagesDir = Join-Path $Bundle "images"
if (-not (Test-Path $imagesDir)) { throw "找不到 $imagesDir，确认 Bundle 路径" }

# ---------- 1) SHA256 校验 ----------
# 优先用 images/SHA256SUMS（路径相对 images/）；否则用包根 SHA256SUMS（路径相对包根）
$sumInImages = Join-Path $imagesDir "SHA256SUMS"
$sumAtRoot = Join-Path $Bundle "SHA256SUMS"
if (-not $SkipVerify -and (Test-Path $sumInImages)) {
    Write-Host "== 校验 SHA256（images/SHA256SUMS） ==" -ForegroundColor Cyan
    $bad = 0
    Get-Content $sumInImages | ForEach-Object {
        $parts = $_ -split '\s+', 2
        if ($parts.Count -ne 2) { return }
        $expected, $name = $parts[0], $parts[1].Trim()
        $path = Join-Path $imagesDir $name
        if (-not (Test-Path $path)) { Write-Host "[missing] $name" -ForegroundColor Yellow; $bad++; return }
        $actual = (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLower()
        if ($actual -ne $expected) { Write-Host "[bad] $name" -ForegroundColor Red; $bad++ }
        else { Write-Host "[ok]  $name" -ForegroundColor Green }
    }
    if ($bad -gt 0) { throw "校验失败 $bad 个文件，停止加载" }
} elseif (-not $SkipVerify -and (Test-Path $sumAtRoot)) {
    Write-Host "== 校验 SHA256（SHA256SUMS） ==" -ForegroundColor Cyan
    $bad = 0
    Get-Content $sumAtRoot | ForEach-Object {
        $parts = $_ -split '\s+', 2
        if ($parts.Count -ne 2) { return }
        $expected, $name = $parts[0], $parts[1].Trim()
        $path = Join-Path $Bundle $name
        if (-not (Test-Path $path)) { Write-Host "[missing] $name" -ForegroundColor Yellow; $bad++; return }
        $actual = (Get-FileHash -Algorithm SHA256 -Path $path).Hash.ToLower()
        if ($actual -ne $expected) { Write-Host "[bad] $name" -ForegroundColor Red; $bad++ }
        else { Write-Host "[ok]  $name" -ForegroundColor Green }
    }
    if ($bad -gt 0) { throw "校验失败 $bad 个文件，停止加载" }
} elseif ($SkipVerify) {
    Write-Warning "已跳过 SHA256 校验"
} else {
    Write-Warning "未找到 SHA256SUMS，跳过校验"
}

# ---------- 2) docker load ----------
Write-Host "== 加载镜像 ==" -ForegroundColor Cyan
$tars = Get-ChildItem -Path $imagesDir -Filter *.tar | Sort-Object Name
foreach ($t in $tars) {
    Write-Host "[load] $($t.Name) ($([math]::Round($t.Length / 1GB, 2)) GB)"
    docker load -i $t.FullName
    if ($LASTEXITCODE -ne 0) { throw "docker load 失败：$($t.Name)" }
        }
Write-Host "已加载 $($tars.Count) 个镜像。" -ForegroundColor Green

# ---------- 3) 准备配置 ----------
$envDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "env"
if (-not (Test-Path $envDir)) { New-Item -ItemType Directory -Force -Path $envDir | Out-Null }
$company = Join-Path $envDir "company.env"
if (-not (Test-Path $company)) {
    Copy-Item (Join-Path $envDir "example.env") $company
    Write-Host "[config] 已生成 $company，请填入公司内网端点（不要提交 git）" -ForegroundColor Yellow
}

Write-Host @"

下一步：
  1. 编辑 $company（OPENAI_API_BASE / OPENAI_API_KEY / MODEL_NAME）
  2. docker compose -f offline\docker-compose.yml --env-file offline\env\company.env up -d
  3. docker compose exec runner bash /workspace/offline/run_stage1.sh
"@
