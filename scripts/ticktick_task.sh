#!/usr/bin/env bash
set -euo pipefail

CLI="${TICKTICK_CLI:-/usr/local/bin/dida365-openapi}"

die() {
  echo "ERROR: $*" >&2
  exit 1
}

need_cli() {
  if [ ! -x "$CLI" ]; then
    die "找不到 dida365-openapi CLI：$CLI。请确认已创建软链接：ln -sf /root/.local/bin/dida365-openapi /usr/local/bin/dida365-openapi"
  fi
}

print_usage() {
  cat <<'EOF'
TickTick Skill Wrapper for Hermes Agents

Usage:
  bash scripts/ticktick_task.sh health
  bash scripts/ticktick_task.sh help
  bash scripts/ticktick_task.sh projects-list
  bash scripts/ticktick_task.sh inbox-id
  bash scripts/ticktick_task.sh inbox-list
  bash scripts/ticktick_task.sh inbox-create "任务标题"
  bash scripts/ticktick_task.sh tasks-list
  bash scripts/ticktick_task.sh tasks-search "关键词"
  bash scripts/ticktick_task.sh tasks-get "TASK_ID"
  bash scripts/ticktick_task.sh tasks-complete "PROJECT_ID" "TASK_ID"
  bash scripts/ticktick_task.sh tasks-delete "PROJECT_ID" "TASK_ID"
  bash scripts/ticktick_task.sh remind-create "任务标题" "YYYY-MM-DD HH:MM"
  bash scripts/ticktick_task.sh raw <any dida365-openapi args...>

Notes:
  - Prefer /usr/local/bin/dida365-openapi.
  - This wrapper intentionally does not store token/client secret.
  - If a command fails due to upstream CLI arg differences, run:
      /usr/local/bin/dida365-openapi <module> <action> --help
EOF
}

run_or_show_help() {
  local help_cmd="$1"
  shift

  set +e
  output="$("$@" 2>&1)"
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    echo "$output" >&2
    echo "" >&2
    echo "命令执行失败。你可以查看参数帮助：" >&2
    echo "  $help_cmd" >&2
    exit "$status"
  fi

  echo "$output"
}

json_search_tasks_by_keyword() {
  local keyword="$1"

  "$CLI" tasks list | python3 - "$keyword" <<'PY'
import json, sys

keyword = sys.argv[1].lower()
raw = sys.stdin.read().strip()

try:
    data = json.loads(raw)
except Exception:
    print(raw)
    sys.exit(0)

matches = []

def walk(x):
    if isinstance(x, dict):
        title = str(x.get("title") or x.get("name") or "").lower()
        if keyword in title:
            matches.append(x)
        for v in x.values():
            walk(v)
    elif isinstance(x, list):
        for i in x:
            walk(i)

walk(data)
print(json.dumps(matches, ensure_ascii=False, indent=2))
PY
}

main() {
  need_cli

  action="${1:-help}"
  shift || true

  case "$action" in
    health)
      "$CLI" --help >/dev/null
      echo "OK: dida365-openapi CLI 可用：$CLI"
      ;;

    help|-h|--help)
      print_usage
      ;;

    projects-list)
      "$CLI" projects list
      ;;

    inbox-id)
      "$CLI" inbox id
      ;;

    inbox-list)
      "$CLI" inbox list
      ;;

    inbox-create)
      title="${1:-}"
      [ -n "$title" ] || die "缺少任务标题。用法：bash scripts/ticktick_task.sh inbox-create \"任务标题\""
      run_or_show_help \
        "$CLI inbox create --help" \
        "$CLI" inbox create --title "$title"
      ;;

    tasks-list)
      "$CLI" tasks list
      ;;

    tasks-search)
      keyword="${1:-}"
      [ -n "$keyword" ] || die "缺少关键词。用法：bash scripts/ticktick_task.sh tasks-search \"关键词\""
      json_search_tasks_by_keyword "$keyword"
      ;;

    tasks-get)
      task_id="${1:-}"
      [ -n "$task_id" ] || die "缺少 TASK_ID。"
      run_or_show_help \
        "$CLI tasks get --help" \
        "$CLI" tasks get --task-id "$task_id"
      ;;

    tasks-complete)
      project_id="${1:-}"
      task_id="${2:-}"
      [ -n "$project_id" ] || die "缺少 PROJECT_ID。"
      [ -n "$task_id" ] || die "缺少 TASK_ID。"
      run_or_show_help \
        "$CLI tasks complete --help" \
        "$CLI" tasks complete --project-id "$project_id" --task-id "$task_id"
      ;;

    tasks-delete)
      project_id="${1:-}"
      task_id="${2:-}"
      [ -n "$project_id" ] || die "缺少 PROJECT_ID。"
      [ -n "$task_id" ] || die "缺少 TASK_ID。"
      run_or_show_help \
        "$CLI tasks delete --help" \
        "$CLI" tasks delete --project-id "$project_id" --task-id "$task_id"
      ;;

    remind-create)
      title="${1:-}"
      remind_time="${2:-}"
      [ -n "$title" ] || die "缺少任务标题。"
      [ -n "$remind_time" ] || die "缺少提醒时间，例如：2026-05-03 09:00"

      run_or_show_help \
        "$CLI remind create --help" \
        "$CLI" remind create --title "$title" --time "$remind_time"
      ;;

    raw)
      "$CLI" "$@"
      ;;

    *)
      die "未知操作：$action。执行 bash scripts/ticktick_task.sh help 查看用法。"
      ;;
  esac
}

main "$@"
