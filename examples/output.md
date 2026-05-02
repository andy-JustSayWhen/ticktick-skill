# Example Outputs

## 创建普通待办

User:

```text
记个待办：买猫粮
```

Agent action:

```bash
bash scripts/ticktick_task.sh inbox-create "买猫粮"
```

Agent reply:

```text
已添加到滴答清单收集箱：买猫粮
```

## 查看收集箱

User:

```text
看看我的收集箱
```

Agent action:

```bash
bash scripts/ticktick_task.sh inbox-list
```

Agent reply:

```text
你的收集箱里有这些任务：

1. 买猫粮
2. 给客户发报价单
3. 整理 B 站选题
```

## 设置提醒

User:

```text
明天上午 10 点提醒我给客户发报价单
```

Agent action:

```bash
bash scripts/ticktick_task.sh remind-create "给客户发报价单" "2026-05-03 10:00"
```

Agent reply:

```text
已设置提醒：明天 10:00 给客户发报价单
```
