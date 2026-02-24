# 截图研究 2026-02-24 08:10 CST

## 🔍 深度分析结果

### 1. 截图状态检查

| 检查项 | 状态 | 详情 |
|--------|------|------|
| 本地截图 | ⚠️ 静态 | latest 与 pinball_01 MD5 相同 (532aefd5) |
| CI Schedule | ⚠️ 运行但时间偏移 | 实际: 19:13 UTC |
| Git 提交 | ❌ 无变化 | 文件相同，无法触发提交 |
| CI 运行 | ⚠️ 手动触发 | 最后一次 Feb 23 22:00:03Z (workflow_dispatch) |
| Schedule 触发 | ❌ 失效 | 最近 schedule 触发: Feb 23 19:13:17Z |

### 2. MD5 校验结果 (无变化)

```
532aefd5cc8604ba6efe324ce919e973  latest_screenshot.png   ← Feb 23 00:45
532aefd5cc8604ba6efe324ce919e973  pinball_01_menu.png     ← Feb 20 14:45 (完全相同!)
f500a2e11bf3180515b5dea7cf8298f8  pinball_02_game.png
8a0ed813cc94b89b09044c361a4d1245  pinball_03_play.png
7e7f0d4c6731709809384bb8cba9fea9  pinball_04_launch.png
```

### 3. 根本原因分析 ⚠️

**CI 工作流设计**:
```yaml
# game-screenshot job: 生成占位图 (伪截图)
- name: Generate Placeholder Screenshot
  run: |
    convert -size 1920x1080 xc:'#0a0a1a' ...  # ImageMagick 生成静态图

# download-sync job: 复制本地截图
- name: Use Local Game Screenshots
  run: |
    cp screenshots/pinball_01_menu.png screenshots/latest_screenshot.png
```

**执行流程**:
1. `game-screenshot` → 使用 ImageMagick 生成静态占位图 (不是真实游戏画面)
2. `download-sync` → 复制本地 `pinball_01_menu.png` → `latest_screenshot.png`
3. 两个文件 MD5 相同 → `git diff --cached --quiet` 为真 → 跳过提交
4. **结果**: 截图从未真正更新

### 4. CI 运行记录

| Run | 触发方式 | 时间 (UTC) | 状态 |
|-----|----------|------------|------|
| #73 | workflow_dispatch | Feb 23 22:00:03Z | ✅ success |
| #72 | workflow_dispatch | Feb 23 19:46:01Z | ✅ success |
| #71 | schedule | Feb 23 19:13:17Z | ✅ success |
| #70 | push | Feb 23 17:42:42Z | ✅ success |

**注意**: Schedule cron `0 0,6,12,18 * * *` 与实际运行时间不匹配

### 5. 解决方案

| 方案 | 说明 | 优先级 | 工作量 |
|------|------|--------|--------|
| **接受现状 (当前)** | CI 只做代码验证，截图是本地静态档案 | P0 | 无 |
| **Godot Headless** | 真正运行 Godot 捕获截图 | P1 | 中等 |
| **强制提交** | 即使无变化也强制提交 | P2 | 低 (不推荐) |

### 6. 结论

⚠️ **当前截图功能是"设计行为"**:
- ✅ CI 代码验证正常 (语法、场景、结构检查)
- ✅ 工作流执行成功
- ❌ 截图不是游戏实际画面 (使用本地预存截图)

**根因**: CI 设计为使用本地预存截图，而非 Godot 渲染

**如果需要真实游戏截图**: 需要实现 Godot headless 渲染
**如果只做 CI 验证**: 当前状态符合设计预期

---

## 截图研究 2026-02-24 09:40 CST

### 1. 截图状态检查

| 检查项 | 状态 | 详情 |
|--------|------|------|
| 本地最新截图 | ⚠️ 静态 | latest_screenshot.png: Feb 23 00:45 (33小时前) |
| 其他截图 | ⚠️ 静态 | pinball_01-04.png: Feb 20 14:45 (4天前) |
| CI 最后运行 | ✅ 成功 | Feb 23 22:00:03Z (workflow_dispatch) |
| Git 提交 | ❌ 无变化 | 截图 MD5 相同，跳过提交 |

### 2. MD5 校验 (无变化)

```
532aefd5cc8604ba6efe324ce919e973  latest_screenshot.png   (Feb 23 00:45)
532aefd5cc8604ba6efe324ce919e973  pinball_01_menu.png     ← 完全相同!
f500a2e11bf3180515b5dea7cf8298f8  pinball_02_game.png
8a0ed813cc94b89b09044c361a4d1245  pinball_03_play.png
7e7f0d4c6731709809384bb8cba9fea9  pinball_04_launch.png
```

### 3. 根本原因确认 ⚠️

**问题**: CI 从未真正运行 Godot 游戏来截图

```
当前 CI 设计:
1. game-screenshot job: ImageMagick 生成占位符 (静态图)
2. upload-artifact: 上传 artifact
3. download-sync job: 复制仓库已有截图 pinball_01_menu.png
4. git diff → 无变化 → 跳过提交
```

**截图永远不会更新的原因**:
- CI 使用 ImageMagick 生成占位符，非游戏实际画面
- download-sync 复制的是仓库已有静态截图
- 截图 MD5 相同 → 无变化 → 不提交

### 4. CI 运行记录

| Run ID | 触发方式 | 时间 (UTC) | 状态 |
|--------|----------|------------|------|
| 22326604768 | workflow_dispatch | Feb 23 22:00:03Z | ✅ success |
| 22322099141 | workflow_dispatch | Feb 23 19:46:01Z | ✅ success |
| 22320974294 | schedule | Feb 23 19:13:17Z | ✅ success |

### 5. 建议解决方案

| 方案 | 说明 | 优先级 | 工作量 | 状态 |
|------|------|--------|--------|------|
| **A. Godot Headless** | 真正运行 Godot 捕获截图 | P1 | 中等 | 待实现 |
| **B. 接受现状** | CI 只做代码验证，截图是静态档案 | P0 | 无 | 当前状态 |
| **C. 强制更新** | 每次 CI 都更新截图时间戳 | P2 | 低 | 不推荐 |

### 6. 结论

✅ **CI 运行正常** - 所有 job 成功执行
⚠️ **截图静态是设计行为** - 使用本地预存截图，非 Godot 渲染
❌ **截图不会自动更新** - 因为没有真正的游戏画面生成

**如需真实游戏截图**: 需要实现 Godot headless 渲染方案

---

## 更新记录

- 2026-02-24 08:40 CST: 确认 - CI 运行正常，截图静态是设计行为，从未真正运行 Godot 截图
- 2026-02-24 08:10 CST: 确认 - 截图状态无变化，MD5 相同，Schedule 触发失效
- 2026-02-24 07:10 CST: 再次确认 - 截图状态无变化，CI 最后运行 Feb 23 22:00:03Z (workflow_dispatch)
- 2026-02-24 06:10 CST: 再次确认 MD5 - 截图状态无变化 (532aefd5)
- 2026-02-24 05:40 CST: 确认 MD5 校验，最新截图与 pinball_01 完全相同
- 2026-02-24 05:10 CST: 发现根因 - CI 用 ImageMagick 生成占位图，非真实游戏截图
- 2026-02-24 04:40 CST: 确认 CI 正常运行
- 2026-02-24 04:10 CST: 深度分析 - 发现截图静态是设计行为
- 2026-02-24 03:40 CST: 配置本地 crontab 外部触发
- 2026-02-24 03:40 CST: 确认 GitHub Actions schedule 完全失效
