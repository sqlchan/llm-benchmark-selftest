# 有外网的机器上执行：拉镜像/拉数据 → docker save → 生成 manifest 与 SHA256
#
# 用法：
#   .\build_bundle.ps1 -Bundle D:\bench-bundle -Subset mvp
#   .\build_bundle.ps1 -Bundle D:\bench-bundle -SkipData          # 只处理镜像
#   .\build_bundle.ps1 -Bundle D:\bench-bundle -SkipImages        # 只处理数据
#
# 注意：脚本是模板；标注 TODO verify 的部分按实际镜像/数据集替换后再跑。
[CmdletBinding()]
param(
    [string]$Bundle = "D:\bench-bundle",
    [ValidateSet("mvp", "full")][string]$Subset = "mvp",
    [switch]$SkipImages,
    [switch]$SkipData
)

$ErrorActionPreference = "Stop"
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$imagesDir = Join-Path $Bundle "images"
$dataDir = Join-Path $Bundle "data"
$logsDir = Join-Path $Bundle "logs"
foreach ($d in @($Bundle, $imagesDir, $dataDir, $logsDir)) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

$errors = New-Object System.Collections.Generic.List[string]
$record = [ordered]@{
    created_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    subset      = $Subset
    host        = $env:COMPUTERNAME
    images      = @()
    data        = @()
}

# ---------- 1) 镜像：pull → save ----------
if (-not $SkipImages) {
    $manifestPath = Join-Path $scriptRoot "images.manifest.txt"
    $images = Get-Content $manifestPath | Where-Object { $_.Trim() -and -not $_.TrimStart().StartsWith("#") } | ForEach-Object { $_.Trim() }
    Write-Host "== 镜像：$($images.Count) 个 ==" -ForegroundColor Cyan
    foreach ($img in $images) {
        $safe = ($img -replace '[:/]', '_')
        $tar = Join-Path $imagesDir "$safe.tar"
        if (Test-Path $tar) { Write-Host "[skip] 已存在 $tar"; }
        else {
            try {
                Write-Host "[pull] $img"
                docker pull $img
                if ($LASTEXITCODE -ne 0) { throw "docker pull 退出码 $LASTEXITCODE" }
                Write-Host "[save] $tar"
                docker save -o $tar $img
                if ($LASTEXITCODE -ne 0) { throw "docker save 退出码 $LASTEXITCODE" }
            }
            catch { $errors.Add("镜像 $img : $_") }
        }
        if (Test-Path $tar) {
            $record.images += [ordered]@{ image = $img; file = (Split-Path $tar -Leaf) }
        }
    }
}

# ---------- 2) 数据：仓库快照 + gated 数据集 ----------
if (-not $SkipData) {
    Write-Host "== 数据 ==" -ForegroundColor Cyan
    # 仓库快照（TODO verify：建议锁 commit/tag，而不是随手 clone 最新 main）
    $repos = @(
        @{ name = "AutomationBench"; url = "https://github.com/zapier/AutomationBench.git" },
        @{ name = "deep-swe";       url = "https://github.com/datacurve-ai/deep-swe.git" },
        @{ name = "NL2RepoBench";   url = "https://github.com/multimodal-art-projection/NL2RepoBench.git" },
        @{ name = "programbench";   url = "https://github.com/facebookresearch/ProgramBench.git" }
    )
    foreach ($r in $repos) {
        $dest = Join-Path $dataDir $r.name
        if (Test-Path (Join-Path $dest ".git")) {
            Write-Host "[skip] $($r.name) 已存在"
        } else {
            try {
                git clone --depth 1 $r.url $dest
                if ($LASTEXITCODE -ne 0) { throw "git clone 退出码 $LASTEXITCODE" }
            } catch { $errors.Add("仓库 $($r.name) : $_") }
        }
        if (Test-Path (Join-Path $dest ".git")) {
            $commit = (git -C $dest rev-parse HEAD 2>$null)
            $record.data += [ordered]@{ name = $r.name; type = "git"; url = $r.url; commit = $commit }
        }
    }

    # gated HF 数据集（DeepSWE 轨迹等；ProgramBench 测试 blob 用官方 CLI 同步）
    # TODO verify：按实际用到的数据集补充；HF_TOKEN 必须有权限。
    if ($env:HF_TOKEN) {
        Write-Host "[hf] token 已设置；按需下载数据集（示例见 report/api-only-5bench-plan.md）"
        # python -c "from huggingface_hub import snapshot_download; snapshot_download('datacurve/deep-swe', repo_type='dataset', local_dir=r'$dataDir\hf\deep-swe')"
    } else {
        Write-Warning "未设置 HF_TOKEN：gated 数据集跳过（到公司后无法补下载）"
    }

    # Terminal-Bench 4.0 数据集与 prebuilt 镜像
    # TODO verify：用 Harbor 下载数据集 + 导入 release 里的 prebuilt tar
    #   uv run --directory <harbor> harbor download terminal-bench -o $dataDir\terminal-bench
    #   docker load -i terminal-bench-prebuilt-v4.0.0.tar.gz（先解压）
    $record.data += [ordered]@{ name = "TODO-terminal-bench"; type = "manual"; note = "见注释" }
}

# ---------- 3) 生成 manifest 与 SHA256 ----------
$manifestFile = Join-Path $Bundle "manifest.json"
$record | ConvertTo-Json -Depth 6 | Set-Content -Path $manifestFile -Encoding UTF8
Write-Host "[manifest] $manifestFile"

$hashLines = @()
Get-ChildItem -Path $imagesDir -Filter *.tar -ErrorAction SilentlyContinue | ForEach-Object {
    $h = Get-FileHash -Algorithm SHA256 -Path $_.FullName
    $hashLines += ("{0}  {1}" -f $h.Hash.ToLower(), $_.Name)
    Write-Host ("[sha256] {0}  {1}" -f $_.Name, ([math]::Round($_.Length / 1GB, 2)) + " GB")
}
$hashLines | Set-Content -Path (Join-Path $Bundle "SHA256SUMS") -Encoding ASCII

# ---------- 4) 汇总 ----------
$total = (Get-ChildItem -Path $imagesDir -Filter *.tar -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
Write-Host ("`n== 完成：{0} 个镜像，合计 {1:N2} GB，数据在 {2} ==" -f $record.images.Count, (($total / 1GB)), $dataDir) -ForegroundColor Green
if ($errors.Count -gt 0) {
    Write-Host "`n失败项：" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "下一步：docker build -f offline\Dockerfile.runner -t bench-eval-runner:local . 然后断网自测。"
