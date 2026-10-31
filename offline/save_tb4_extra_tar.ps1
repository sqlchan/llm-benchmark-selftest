# 保存 TB4 扩题镜像 tar（21 题：派生 env + verifier + sidecar）
$ErrorActionPreference = 'Continue'
$BASE = 'D:\ai\code\git\bench'
$OUT = 'E:\bench-bundle\images\bench-images-tb4-extra.tar'

$newTasks = (Get-Content "$BASE\sandbox\batch3\new_tasks.json" -Raw | ConvertFrom-Json).new_tasks
$man = (Get-Content "$BASE\sandbox\tb4\prebuilt-images.json" -Raw | ConvertFrom-Json).tasks
$refs = New-Object System.Collections.Generic.List[string]
foreach ($t in $newTasks) { $refs.Add("tb4off/environment:$t") }
foreach ($t in $newTasks) { $refs.Add("harborframework/terminal-bench:$t-verifier-v4.0.0") }
foreach ($t in $man) {
    if ($newTasks -notcontains $t.task) { continue }
    foreach ($im in $t.images) {
        if ($im.kind -eq 'sidecar') { $refs.Add($im.release_ref) }
    }
}
$refs | Set-Content "$BASE\sandbox\batch3\image_refs.txt" -Encoding utf8
"refs: $($refs.Count)"
if (Test-Path $OUT) { Remove-Item $OUT -Force }
$t0 = Get-Date
docker save -o $OUT $refs 2>&1 | Out-String
"save done in $([math]::Round(((Get-Date)-$t0).TotalMinutes,1)) min"
$item = Get-Item $OUT
"size: $([math]::Round($item.Length/1GB,2)) GiB"
$h = (Get-FileHash -Algorithm SHA256 $OUT).Hash.ToLower()
"sha256: $h"
$h | Set-Content "$BASE\sandbox\batch3\tar_sha256.txt" -Encoding ascii
