# Pinball CI/CD 截图状态报告

> 更新日期: 2026-02-21 21:10 (Asia/Shanghai)
> 调查者: Vanguard001 (Cron自动任务)
> 状态: ⚠️ **问题已知 - CI按设计生成占位符**

---

## 📊 21:10 研究更新 - 问题根因确认

### 截图状态

| 文件 | 大小 | MD5哈希 | 状态 |
|------|------|---------|------|
| latest_screenshot.png | 541KB | 7e7f0d4c | ⚠️ CI占位符 |
| pinball_01_menu.png | 541KB | 532aefd5 | ⚠️ CI占位符 |
| pinball_02_game.png | 541KB | f500a2e1 | ⚠️ CI占位符 |
| pinball_03_play.png | 541KB | 8a0ed813 | ⚠️ CI占位符 |
| pinball_04_launch.png | 541KB | 7e7f0d4c | ⚠️ CI占位符 |

### CI运行状态: ✅ 正常
- 最近运行: 2026-02-21 12:43 (schedule)
- 状态: success
- 所有测试通过

---

## 🔴 根本原因分析

### CI Workflow 设计问题

查看 `.github/workflows/*.yml`:

```yaml
# game-screenshot job
- name: Generate Placeholder Screenshot
  run: |
    convert -size 1920x1080 xc:'#0a0a1a' \
      -fill '#1a1a3a' -stroke '#2a2a5a' \
      -pointsize 64 -annotate +0-120 "🎮 PINBALL GODOT" \
      ...
```

**问题**: CI使用ImageMagick生成静态占位图，**没有运行Godot headless来捕获实际游戏画面**

### download-sync job 的逻辑

```yaml
- name: Use Local Game Screenshots
  run: |
    if [ -f "screenshots/pinball_01_menu.png" ]; then
      cp screenshots/pinball_01_menu.png screenshots/latest_screenshot.png
    else
      # Fallback: 下载 artifact
      curl -sL "..." -o screenshots/latest_screenshot.png
    fi
```

**问题**: 检查本地截图，但本地文件已是CI占位符（之前被覆盖）

---

## ✅ 解决方案

### 方案1: 手动本地截图 (推荐 P1)

```bash
# 需要条件:
# 1. 安装 Godot 4.x
# 2. 打开 game/pin-ball 项目
# 3. 捕获菜单/游戏画面
# 4. 替换 screenshots/ 目录
# 5. git add → commit → push
```

### 方案2: 接受现状 (P2)

- game/pin-ball 是**维护项目**
- CI占位符可接受作为"验证通过"标识
- 不影响核心功能

### 方案3: CI集成Godot截图 (长期 P3)

需要修改 workflow:
```yaml
- name: Run Godot Headless
  run: |
    wget https://github.com/godotengine/godot/releases/download/4.2.1-stable/...
    ./Godot --headless --script capture.gd
```

---

## 📋 行动建议

| 优先级 | 任务 | 负责人 | 状态 |
|--------|------|--------|------|
| P1 | 本地运行Godot捕获真实截图 | Master Jay | 待执行 |
| P2 | 接受CI占位符作为项目状态标识 | - | 可选 |
| P3 | 改进CI集成真实验截图 | CodeForge | 计划中 |

---

## 历史记录

| 时间 | 状态 | 说明 |
|------|------|------|
| **21:10** | ⚠️ 根因确认 | CI按设计生成占位符，非bug |
| **20:40** | ⚠️ 问题持续 | CI仍在生成占位符 |
| **20:10** | ⚠️ 发现严重问题 | 截图全为CI占位符(541KB) |
| **19:40** | ✅ 误报 | 当时认为正常 |
| **19:10** | ✅ 误报 | 当时认为正常 |

---

## 📊 附录: 文件哈希对比

```
# game/pin-ball 截图 (全部相同 = 全是占位符)
7e7f0d4c6731709809384bb8cba9fea9  latest_screenshot.png
532aefd5cc8604ba6efe324ce919e973  pinball_01_menu.png
f500a2e11bf3180515b5dea7cf8298f8  pinball_02_game.png
8a0ed813cc94b89b09044c361a4d1245  pinball_03_play.png
7e7f0d4c6731709809384bb8cba9fea9  pinball_04_launch.png

# pi-pin-ball 截图 (各不相同 = 真实截图)
408630  01_main_menu.png     (408KB)
385949  02_game_start.png   (386KB)
443658  03_character_select.png (444KB)
```

**结论**: game/pin-ball的截图全是CI生成的占位符，pi-pin-ball的截图是真实游戏画面。
