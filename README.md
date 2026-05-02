# TickTick Skill

A Hermes Agents skill for natural-language interaction with TickTick / Dida365 / 滴答清单 through `dida365-openapi`.

> 中文说明：这个 Skill 让 Hermes Agent 可以通过自然语言调用滴答清单 / TickTick，例如“记个待办”“明天提醒我”“看看收集箱”。

## What it does

This skill wraps the CLI:

```bash
/usr/local/bin/dida365-openapi
```

and exposes common actions to Hermes Agents:

- list projects
- list inbox tasks
- create inbox tasks
- search tasks
- complete tasks
- delete tasks
- create reminder tasks

## Repository structure

```text
ticktick-skill/
├── skill.md
├── README.md
├── scripts/
│   └── ticktick_task.sh
├── examples/
│   ├── input.md
│   └── output.md
└── templates/
    └── response.md
```

## Prerequisites

Inside the Hermes backend container, the CLI should already work:

```bash
/usr/local/bin/dida365-openapi --help
/usr/local/bin/dida365-openapi projects list
```

If the CLI is installed under `/root/.local/bin`, create a stable symlink:

```bash
ln -sf /root/.local/bin/dida365-openapi /usr/local/bin/dida365-openapi
```

## Install

Copy this repository folder into your Hermes skills directory.

Example:

```bash
cp -r ticktick-skill /opt/data/skills/ticktick-skill
```

Make the wrapper executable:

```bash
cd /opt/data/skills/ticktick-skill
chmod +x scripts/ticktick_task.sh
```

Restart Hermes if your Hermes version requires a restart to reload skills.

## Self-check

```bash
bash scripts/ticktick_task.sh health
```

## Common commands

List projects:

```bash
bash scripts/ticktick_task.sh projects-list
```

List inbox:

```bash
bash scripts/ticktick_task.sh inbox-list
```

Create inbox task:

```bash
bash scripts/ticktick_task.sh inbox-create "测试：Hermes 创建滴答任务"
```

Raw CLI call:

```bash
bash scripts/ticktick_task.sh raw projects list
```

## Natural-language examples

User:

```text
记个待办：买猫粮
```

Agent should call:

```bash
bash scripts/ticktick_task.sh inbox-create "买猫粮"
```

User:

```text
看看我的收集箱
```

Agent should call:

```bash
bash scripts/ticktick_task.sh inbox-list
```

User:

```text
明天上午 10 点提醒我给客户发报价单
```

Agent should call:

```bash
bash scripts/ticktick_task.sh remind-create "给客户发报价单" "2026-05-03 10:00"
```

## Security

Do not commit:

```bash
/root/.config/dida365-openapi/.env
/root/.config/dida365-openapi/*
```

Never expose:

- access token
- refresh token
- client secret
