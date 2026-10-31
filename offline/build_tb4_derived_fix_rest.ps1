# 继续在旧派生镜像之上重放 agent 载荷（跳过已完成的 3 个）
$ErrorActionPreference = 'Continue'
$BASE = 'D:\ai\code\git\bench'
$PAYLOAD = "$BASE\sandbox\batch2\payload"
$DONE = @('bun-sourcemap-leak','session-window-debug','kv-live-surgery')
$TASKS = @('live-database-cutover','mvcc-lsm-compaction','wal-recovery-ordering','cumulative-layout-shift','react-lead-form','nextjs-performance','vf2-speedup-networkx','html-js-filter','shadow-relay','vba-userform-port','legacy-utility-triage','payments-pipeline-fix')
$LOG = "$BASE\sandbox\batch2\build_derived_fix_rest.log"
Remove-Item $LOG -ErrorAction SilentlyContinue

foreach ($t in $TASKS) {
    $tag = "tb4off/environment:$t"
    "=== $t" | Tee-Object -FilePath $LOG -Append
    docker build --pull=false --build-arg "BASE_IMAGE=$tag" -f "$BASE\offline\tb4-agent-payload\Dockerfile.derived-fix" -t $tag $PAYLOAD *>> $LOG
    if ($LASTEXITCODE -eq 0) { "OK $t" | Tee-Object -FilePath $LOG -Append } else { "FAIL $t" | Tee-Object -FilePath $LOG -Append }
}
"ALL DONE" | Tee-Object -FilePath $LOG -Append
