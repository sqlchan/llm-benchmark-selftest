# 为选中的 TB4 任务构建派生 environment 镜像（预装离线 agent 工具链）
$ErrorActionPreference = 'Continue'
$BASE = 'D:\ai\code\git\bench'
$PAYLOAD = "$BASE\sandbox\batch2\payload"
$SEL = Get-Content "$BASE\sandbox\tb4\selected_tasks.json" -Raw | ConvertFrom-Json
$log = "$BASE\sandbox\batch2\build_derived.log"
Remove-Item $log -ErrorAction SilentlyContinue

foreach ($p in $SEL.PSObject.Properties) {
    $task = $p.Name
    $baseTag = "harborframework/terminal-bench:$task-environment-v4.0.0"
    $outTag = "tb4off/environment:$task"
    "=== $task -> $outTag (from $baseTag)" | Tee-Object -FilePath $log -Append
    docker build --build-arg "BASE_IMAGE=$baseTag" -f "$BASE\offline\tb4-agent-payload\Dockerfile.derived" -t $outTag $PAYLOAD *>> $log
    if ($LASTEXITCODE -eq 0) { "OK $task" | Tee-Object -FilePath $log -Append }
    else { "FAIL $task" | Tee-Object -FilePath $log -Append }
}
"ALL DONE" | Tee-Object -FilePath $log -Append
