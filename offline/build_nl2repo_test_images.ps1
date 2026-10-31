# 为 NL2Repo 选中的 10 个任务构建离线测试镜像（预装构建后端/依赖，标签与原镜像相同）
$ErrorActionPreference = 'Continue'
$BASE = 'D:\ai\code\git\bench'
$TASKS = @('aiofiles','humanize','sqlparse','tenacity','cerberus','tinydb','markupsafe','jsonlines','freezegun','python-slugify')
$LOG = "$BASE\sandbox\batch2\build_nl2repo_test.log"
Remove-Item $LOG -ErrorAction SilentlyContinue

foreach ($t in $TASKS) {
    $img = "ghcr.io/multimodal-art-projection/nl2repobench/$($t):1.0"
    "=== $t" | Tee-Object -FilePath $LOG -Append
    docker build --pull=false --build-arg "BASE_IMAGE=$img" -f "$BASE\offline\nl2repo-test-fix\Dockerfile" -t $img "$BASE\offline\nl2repo-test-fix" *>> $LOG
    if ($LASTEXITCODE -eq 0) { "OK $t" | Tee-Object -FilePath $LOG -Append } else { "FAIL $t" | Tee-Object -FilePath $LOG -Append }
}
"ALL DONE" | Tee-Object -FilePath $LOG -Append
