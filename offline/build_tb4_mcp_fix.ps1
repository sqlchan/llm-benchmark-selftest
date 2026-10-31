# 为 15 个 TB4 派生镜像追加 mcp 补丁层（小层 ~5.6MB）
$ErrorActionPreference = 'Continue'
$BASE = 'D:\ai\code\git\bench'
$PAYLOAD = "$BASE\sandbox\batch2\payload"
$TASKS = @('bun-sourcemap-leak','session-window-debug','kv-live-surgery','live-database-cutover','mvcc-lsm-compaction','wal-recovery-ordering','cumulative-layout-shift','react-lead-form','nextjs-performance','vf2-speedup-networkx','html-js-filter','shadow-relay','vba-userform-port','legacy-utility-triage','payments-pipeline-fix')
$LOG = "$BASE\sandbox\batch2\build_mcp_fix.log"
Remove-Item $LOG -ErrorAction SilentlyContinue

foreach ($t in $TASKS) {
    $tag = "tb4off/environment:$t"
    "=== $t" | Tee-Object -FilePath $LOG -Append
    docker build --pull=false --build-arg "BASE_IMAGE=$tag" -f "$BASE\offline\tb4-agent-payload\Dockerfile.agent-mcp-fix" -t $tag $PAYLOAD *>> $LOG
    if ($LASTEXITCODE -eq 0) { "OK $t" | Tee-Object -FilePath $LOG -Append } else { "FAIL $t" | Tee-Object -FilePath $LOG -Append }
}
"ALL DONE" | Tee-Object -FilePath $LOG -Append
