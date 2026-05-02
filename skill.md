# TickTick Skill

## Purpose

Use this skill when the user wants Hermes Agents to operate TickTick / Dida365 / 滴答清单 tasks through natural language.

This skill calls the already-installed CLI inside the Hermes backend container:

```bash
/usr/local/bin/dida365-openapi
```

The CLI itself may be named `dida365-openapi`, but this skill is named **TickTick Skill** because it is intended to expose TickTick / Dida365 task operations to Hermes Agents.

## Trigger

Use this skill when the user says or implies any of the following:

- 创建待办
- 添加任务
- 记个任务
- 加入滴答清单
- 加入 TickTick
- 加入收集箱
- 设置提醒
- 明天提醒我
- 下午提醒我
- 查看今天任务
- 查看收集箱
- 查看滴答清单
- 查看 TickTick
- 完成某个任务
- 删除某个任务
- 修改某个任务
- 查询清单
- 查询项目列表
- Dida365
- 滴答清单
- TickTick

Typical user messages:

```text
明天上午 10 点提醒我给客户发报价单
```

```text
记个待办：买猫粮
```

```text
看看我的收集箱
```

```text
把买猫粮标记完成
```

## Available CLI

Always prefer this stable absolute path:

```bash
/usr/local/bin/dida365-openapi
```

Do not rely on shell PATH.

## Wrapper Script

Prefer using the wrapper script:

```bash
bash scripts/ticktick_task.sh <action> [arguments...]
```

Supported wrapper actions:

```bash
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
```

If a wrapper command fails because the upstream CLI argument format is different, run the corresponding help command and adapt:

```bash
/usr/local/bin/dida365-openapi inbox create --help
/usr/local/bin/dida365-openapi remind create --help
/usr/local/bin/dida365-openapi tasks list --help
/usr/local/bin/dida365-openapi tasks complete --help
/usr/local/bin/dida365-openapi tasks delete --help
```

## Behavior Rules

### Create normal tasks

When the user says:

- “记个待办”
- “帮我记一下”
- “加入收集箱”
- “创建一个任务”

and does not specify a clear reminder time, create an inbox task.

Example:

User:

```text
记个待办：买猫粮
```

Call:

```bash
bash scripts/ticktick_task.sh inbox-create "买猫粮"
```

Reply:

```text
已添加到 TickTick / 滴答清单收集箱：买猫粮
```

### Create reminder tasks

When the user says:

- “提醒我”
- “明天提醒我”
- “下午 3 点提醒我”
- “下周一提醒我”

extract:

- title
- date
- time

Then call:

```bash
bash scripts/ticktick_task.sh remind-create "任务标题" "YYYY-MM-DD HH:MM"
```

If the user only says a date but no time, default to `09:00`.

If the user only says “稍后提醒我” but no clear time, ask one short clarification question.

### Query tasks

When the user asks to view tasks:

- “看看收集箱”
- “我的任务有哪些”
- “查一下滴答清单”
- “今天有什么任务”

Start with:

```bash
bash scripts/ticktick_task.sh inbox-list
```

or:

```bash
bash scripts/ticktick_task.sh tasks-list
```

Return a concise Chinese list. Do not paste huge raw JSON unless the user asks for raw output.

### Complete tasks

When the user says:

```text
把“买猫粮”标记完成
```

First search or list tasks:

```bash
bash scripts/ticktick_task.sh tasks-search "买猫粮"
```

If exactly one matching active task is found, complete it.

If multiple matching tasks are found, ask the user to choose.

If the wrapper needs `PROJECT_ID` and `TASK_ID`, extract both from the JSON.

### Delete tasks

Deletion is destructive.

Before deleting, always confirm unless the user has already explicitly confirmed.

Flow:

1. Search task by title.
2. If exactly one match, say which task will be deleted.
3. Ask for confirmation.
4. Only then call delete.

### Update tasks

If the user asks to modify a task, first search the task. If the CLI update parameters are not known, inspect:

```bash
/usr/local/bin/dida365-openapi tasks update --help
```

Then update only the requested fields.

## Safety and Privacy

Never print or store:

- access token
- refresh token
- client secret
- `.env` content

Never suggest committing config files under:

```bash
/root/.config/dida365-openapi/
```

to GitHub.

## Error Handling

If the CLI says:

```text
缺少 access token，请先执行 auth。
```

Reply that OAuth authorization has expired or the token file is missing. Ask the user to re-run auth / exchange-code in the Hermes backend container.

If the CLI command is not found, use:

```bash
/usr/local/bin/dida365-openapi --help
```

If that fails, tell the user the CLI may not be installed or the symlink is missing.

## Output Style

Reply in short, clear Chinese.

Preferred successful replies:

```text
已添加到滴答清单：买猫粮
```

```text
已设置提醒：明天 10:00 给客户发报价单
```

```text
已完成任务：买猫粮
```

Preferred query replies:

```text
你的收集箱里有这些任务：

1. 买猫粮
2. 给客户发报价单
3. 整理 B 站选题
```

Avoid dumping raw JSON unless the user asks.
