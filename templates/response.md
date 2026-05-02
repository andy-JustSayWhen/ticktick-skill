# TickTick Skill Response Template

## Success: Create Task

```text
已添加到滴答清单：{{title}}
```

## Success: Create Reminder

```text
已设置提醒：{{datetime}} {{title}}
```

## Success: Complete Task

```text
已完成任务：{{title}}
```

## Need Confirmation: Delete

```text
我找到了这个任务：{{title}}。确认要删除吗？
```

## Error: Need Auth

```text
滴答清单授权可能失效了。请在 Hermes 后端容器里重新执行 dida365-openapi auth / exchange-code。
```
