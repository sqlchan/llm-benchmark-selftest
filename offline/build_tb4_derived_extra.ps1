# 为扩题任务构建派生 env 镜像（离线 agent 载荷，含 mcp）
$ErrorActionPreference = 'Continue'
$BASE = 'D:\ai\code\git\bench'
$PAYLOAD = "$BASE\sandbox\batch2\payload"
$TASKS = (Get-Content "$BASE\sandbox\batch3\new_tasks.json" -Raw | ConvertFrom-Json).new_tasks
$LOG = "$BASE\sandbox\batch3\build_derived_extra.log"
Remove-Item $LOG -ErrorAction SilentlyContinue

foreach ($t in $TASKS) {
    $baseTag = "harborframework/terminal-bench:$t-environment-v4.0.0"
    $outTag = "tb4off/environment:$t"
    "=== $t" | Tee-Object -FilePath $LOG -Append
    docker build --pull=false --build-arg "BASE_IMAGE=$baseTag" -f "$BASE\offline\tb4-agent-payload\Dockerfile.derived-v2" -t $outTag $PAYLOAD *>> $LOG
    if ($LASTEXITCODE -eq 0) { "OK $t" | Tee-Object -FilePath $LOG -Append } else { "FAIL $t" | Tee-Object -FilePath $LOG -Append }
}
"ALL DONE" | Tee-Object -FilePath $LOG -Append
