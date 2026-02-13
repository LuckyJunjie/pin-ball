# Pinball Godot Game - Agent Documentation

**生成日期:** 2026-02-13  
**系统总数:** 32个（4 阶段扩展，见 design/GDD-v4.0.md §10）  
**项目路径:** 见工作区根目录

---

## 目录

1. [核心系统](#1-核心系统)
2. [增强功能](#2-增强功能)
3. [打磨系统](#3-打磨系统)
4. [附加系统](#4-附加系统)
5. [高级功能](#5-高级功能)
6. [广告系统](#6-广告系统)
7. [使用说明](#7-使用说明)

---

## 1. 核心系统

### 1.1 GameManagerV4 (`scripts/v4/GameManagerV4.gd`)

**功能:** 游戏主状态管理

**信号:**
```gdscript
signal scored(points: int)
signal round_lost()
signal bonus_activated(bonus: Bonus)
signal multiplier_increased()
signal game_over()
signal game_started()
signal zone_ramp_hit(zone_name: String, hit_count: int)
```

**主要方法:**
```gdscript
func start_game()  # 开始游戏
func on_round_lost()  # 回合结束
func add_score(points: int)  # 加分
func increase_multiplier()  # 增加倍率
func register_zone_ramp_hit(zone_name: String)  # 区域斜坡命中
func set_character_theme(theme_key: String)  # 设置角色主题
```

**配置常量:**
```gdscript
const MAX_SCORE: int = 9999999999
const INITIAL_ROUNDS: int = 3
const MAX_MULTIPLIER: int = 6
const BONUS_BALL_DELAY: float = 5.0
const RAMP_HITS_PER_MULTIPLIER: int = 5
```

---

### 1.2 BallPoolV4 (`scripts/v4/BallPoolV4.gd`)

**功能:** 对象池管理（优化性能）

**主要方法:**
```gdscript
func initialize(scene: PackedScene, container: Node2D)  # 初始化
func spawn_ball_at_position(pos: Vector2, impulse: Vector2 = Vector2.ZERO) -> RigidBody2D
func return_ball(ball: RigidBody2D)  # 回收球
func get_active_ball_count() -> int  # 获取活跃球数
func is_initialized() -> bool  # 是否已初始化
```

**特性:**
- 预分配10个球
- 自动回收
- 防止内存泄漏

---

### 1.3 CharacterThemeManagerV4 (`scripts/v4/CharacterThemeManagerV4.gd`)

**功能:** 角色主题管理

**主题:**
```gdscript
const THEMES = {
    "sparky": {"color": Color(0.2, 0.8, 1.0), "name": "Sparky"},
    "dino": {"color": Color(0.2, 1.0, 0.4), "name": "Dino"},
    "dash": {"color": Color(0.4, 1.0, 0.4), "name": "Dash"},
    "android": {"color": Color(0.2, 0.8, 0.2), "name": "Android"}
}
```

**主要方法:**
```gdscript
func set_theme(theme_key: String)  # 设置主题
func get_current_theme() -> Dictionary  # 获取当前主题
func get_theme_color(theme_key: String) -> Color  # 获取主题色
```

---

### 1.4 BonusManagerV4 (`scripts/v4/BonusManagerV4.gd`)

**功能:** 奖励系统管理

**奖励类型:**
```gdscript
enum Bonus {
    GOOGLE_WORD,        # Google单词完成
    DASH_NEST,          # Dash巢穴完成
    SPARKY_TURBO_CHARGE, # Sparky涡轮充能
    DINO_CHOMP,          # 恐龙咬合
    ANDROID_SPACESHIP    # Android飞船
}
```

**主要方法:**
```gdscript
func activate_bonus(bonus: Bonus)  # 激活奖励
func get_bonus_score(bonus: Bonus) -> int  # 获取奖励分
func show_bonus_effect(bonus: Bonus)  # 显示奖励特效
```

---

### 1.5 存档（GameManagerV4 内置 + SaveManager）

**功能:** v4 游戏状态由 GameManagerV4 保存/加载到 `user://saves/v4.0_save.json`（`save_game_state()` / `load_game_state()`）。根目录 `SaveManager`（`scripts/SaveManager.gd`）为可选全局存档，用于其他数据。

---

## 2. 增强功能

### 2.1 DifficultySystem (`scripts/v4/DifficultySystem.gd`, Autoload: `DifficultySystem`)

**功能:** 难度选择系统

**难度级别:**
```gdscript
enum Difficulty { EASY, NORMAL, HARD }

const CONFIGS = {
    Difficulty.EASY: {
        "flipper_strength": 1500.0,
        "gravity_scale": 0.8,
        "bumper_force": 250.0,
        "multiplier_decay_enabled": false
    },
    Difficulty.NORMAL: {
        "flipper_strength": 2200.0,
        "gravity_scale": 1.0,
        "bumper_force": 300.0,
        "multiplier_decay_enabled": true
    },
    Difficulty.HARD: {
        "flipper_strength": 2800.0,
        "gravity_scale": 1.2,
        "bumper_force": 350.0,
        "multiplier_decay_enabled": false
    }
}
```

---

### 2.2 ScreenShake (`scripts/v4/ScreenShake.gd`, Autoload: `ScreenShake`)

**功能:** 屏幕震动效果

**震动级别:**
```gdscript
func shake_light()    # 轻微震动（弹射器命中）
func shake_medium()   # 中等震动（挡板命中）
func shake_heavy()   # 重震动（奖励激活）
func shake_extreme()  # 极强震动（游戏事件）
```

---

### 2.3 ComboSystem (`scripts/v4/ComboSystem.gd`, Autoload: `ComboSystem`)

**功能:** 连击系统

**连击机制:**
```gdscript
const COMBO_TIMEOUT: float = 3.0  # 3秒超时
const MAX_COMBO_BONUS_COMBO_COUNT: int = 20  # 最高20倍

func register_hit(hit_type: String, base_points: int) -> int
func get_combo_multiplier() -> float  # 获取连击倍率
```

---

### 2.4 BallTrailV4 (`scripts/v4/BallTrailV4.gd`)

**功能:** 球迹拖尾效果

**配置:**
```gdscript
@export var trail_color: Color = Color(1.0, 1.0, 1.0, 0.6)
@export var trail_width: float = 4.0
@export var trail_length: int = 20
@export var fade_start: float = 0.5
```

---

### 2.5 ParticleEffectsV4 (`scripts/v4/ParticleEffectsV4.gd`)

**功能:** 粒子特效系统

**特效类型:**
```gdscript
func spawn_hit_effect(position: Vector2, color: Color, count: int)
func spawn_score_popup(position: Vector2, score: int)
func spawn_bonus_effect(position: Vector2)
func spawn_letter_effect(position: Vector2, letter: String)
func spawn_multiplier_effect(multiplier: int)
func spawn_word_completion_effect(center: Vector2)
func spawn_ball_drain_effect(position: Vector2)
```

---

### 2.6 EnhancedAudioV4 (`scripts/v4/EnhancedAudioV4.gd`)

**功能:** 增强音频系统

**音量控制:**
```gdscript
func set_master_volume(volume: float)  # 主音量
func set_sfx_volume(volume: float)     # 音效音量
func set_music_volume(volume: float)  # 音乐音量
func set_ui_volume(volume: float)     # UI音量
```

**动态音频:**
```gdscript
func update_ball_speed(speed: float)  # 根据球速调整音量
func play_bumper_hit(zone_type: String)  # 区域专属音效
func play_combo_sound(combo_count: int)   # 连击音调递增
```

---

### 2.7 MobileControlsV4 (`scripts/v4/MobileControlsV4.gd`)

**功能:** 移动端触控

**触控区域:**
```gdscript
@export var flipper_left_zone: Rect2   # 左挡板区域
@export var flipper_right_zone: Rect2  # 右挡板区域
@export var launch_zone: Rect2         # 发射区域
@export var swipe_threshold: float = 50.0  # 滑动阈值
```

**手势识别:**
```gdscript
signal flipper_touched(side: String, is_pressed: bool)
signal launch_tap()
signal swipe_detected(direction: String, delta: Vector2)
```

---

### 2.8 AchievementSystemV4 (`scripts/v4/AchievementSystemV4.gd`)

**功能:** 成就系统

**成就类别:**
```gdscript
enum AchievementCategory {
    GENERAL,    # 通用
    SCORING,    # 得分
    ZONES,      # 区域
    COMBOS,     # 连击
    BONUSES     # 奖励
}
```

**25个成就示例:**
```gdscript
"first_game",           # 首次游戏
"five_games",          # 玩5场游戏
"multiplier_6x",       # 达到6倍倍率
"combo_20",            # 20倍连击
"all_zones_bonus",     # 单游戏激活所有区域奖励
```

---

### 2.9 AutoSave（GameManagerV4 内置）

**功能:** 自动保存（无独立脚本，由 GameManagerV4 实现）

**触发条件:**
- 每30秒自动保存
- 分数变化≥MIN_SCORE_CHANGE_FOR_AUTO_SAVE
- 回合结束、倍率提升、奖励激活时可选保存

---

## 3. 打磨系统

### 3.1 CRTEffectV4 (`scripts/v4/CRTEffectV4.gd`)

**功能:** CRT复古特效

**特效配置:**
```gdscript
@export var scanline_intensity: float = 0.3
@export var glow_strength: float = 0.5
@export var chromatic_aberration: float = 0.002
@export var curvature_amount: float = 0.05
@export var vignette_intensity: float = 0.3
@export var noise_intensity: float = 0.02
```

**切换方法:**
```gdscript
func set_enabled(enabled_state: bool)
func set_scanline_intensity(value: float)
func set_glow_strength(value: float)
func toggle()  # 开关切换
func flash(intensity: float = 0.5)  # 屏幕闪光
```

---

### 3.2 CharacterAnimatronicV4 (`scripts/v4/CharacterAnimatronicV4.gd`)

**功能:** 角色动画系统

**角色动画:**
```gdscript
# Sparky: idle, turbo_charge, celebrate, hit
# Dino: idle, chomp, celebrate, sleep
# Dash: idle, nest_complete, celebrate
# Android: idle, spaceship_land, celebrate
```

**动画控制:**
```gdscript
func play(anim_name: String, loop_animation: bool = true)
func play_once(anim_name: String, speed_multiplier: float = 1.0)
func set_theme(new_theme: String)
func queue_animation(anim_name: String)
```

---

### 3.3 LeaderboardV4 (`scripts/v4/LeaderboardV4.gd`)

**功能:** 排行榜系统

**排行榜类型:**
```gdscript
# 全局排行榜
func get_leaderboard(count: int = 10, character: String = "") -> Array

# 角色专属排行榜
func get_character_leaderboard(character: String, count: int = 10) -> Array
```

**主要方法:**
```gdscript
func submit_score(initials: String, score: int, character: String = "sparky") -> String
func get_rank(initials: String, score: int, character: String = "") -> int
func is_high_score(score: int) -> bool
func export_leaderboard() -> String
func import_leaderboard(json_string: String, merge: bool = true) -> bool
```

---

### 3.4 TutorialSystemV4 (`scripts/v4/TutorialSystemV4.gd`)

**功能:** 新手教程系统

**8步教程:**
```gdscript
const STEPS = [
    {"id": "welcome", "title": "Welcome!", "duration": 0},
    {"id": "flippers", "title": "Flippers", "duration": 0},
    {"id": "launch", "title": "Launch Ball", "duration": 0},
    {"id": "scoring", "title": "Scoring", "duration": 5},
    {"id": "multiplier", "title": "Multiplier", "duration": 5},
    {"id": "zones", "title": "Zones", "duration": 5},
    {"id": "bonuses", "title": "Bonuses", "duration": 5},
    {"id": "ready", "title": "Ready to Play!", "duration": 3}
]
```

**主要方法:**
```gdscript
func start_tutorial()  # 开始教程
func skip_tutorial()   # 跳过教程
func show_prompt(prompt_id: String, duration: float = 5.0)  # 显示提示
func has_completed_tutorial() -> bool
```

---

### 3.5 PerformanceMonitorV4 (`scripts/v4/PerformanceMonitorV4.gd`)

**功能:** 性能监控

**FPS监控:**
```gdscript
func get_average_fps() -> float
func get_min_fps() -> float
func get_max_fps() -> float
func is_performing_well() -> bool
```

**性能优化:**
```gdscript
func set_quality_preset(preset: String)  # low/medium/high/ultra
func start_benchmark(duration: float = 5.0)
func print_performance_report()
func get_status() -> Dictionary
```

---

## 4. 附加系统

### 4.1 DailyChallengeV4 (`scripts/v4/DailyChallengeV4.gd`)

**功能:** 每日挑战

**10个挑战模板:**
```gdscript
{"id": "high_score", "target": 500000, "reward": 100}
{"id": "multiplier_master", "target": 6, "reward": 150}
{"id": "bonus_hunter", "target": 3, "reward": 200}
{"id": "zone_king", "target": 5, "reward": 300}
{"id": "combo_king", "target": 10, "reward": 175}
{"id": "bumpers", "target": 50, "reward": 100}
{"id": "survivor", "target": 3, "reward": 150}
{"id": "speed_demon", "target": 100000, "reward": 250}
{"id": "perfectionist", "target": 1, "reward": 500}
{"id": "collector", "target": 6, "reward": 175}
```

---

### 4.2 StatisticsTrackerV4 (`scripts/v4/StatisticsTrackerV4.gd`)

**功能:** 统计追踪

**统计数据:**
```gdscript
lifetime:
    games_played, total_score, total_time_played,
    total_balls_lost, total_bonus_balls, high_score

scoring:
    total_hits, total_bumper_hits, total_ramp_hits,
    highest_multiplier_reached, highest_combo

zones:
    android_acres_bonuses, google_words_completed,
    dash_nests_completed, dino_chomps, sparky_turbos
```

---

### 4.3 EasterEggV4 (`scripts/v4/EasterEggV4.gd`)

**功能:** 彩蛋系统

**秘密成就:**
```gdscript
"lucky_ball"      # 第一个奖励球
"combo_master"    # 50倍连击
"flipper_god"     # 单局1000次挡板
"bumper_king"     # 累计1000次弹射器
"perfectionist"    # 无球掉落100万分
"night_owl"       # 午夜游戏
"speedy"          # 1分钟5万分
"collector"       # 解锁所有角色
```

**彩蛋效果:**
```gdscript
"invincible"     # 无敌10秒
"party_mode"     # 派对模式+15秒
"rainbow"        # 彩虹效果
"tiny_ball"      # 小球效果
"ghost_mode"     # 幽灵模式
```

---

### 4.4 SettingsV4 (`scripts/v4/SettingsV4.gd`)

**功能:** 设置系统

**设置类别:**
```gdscript
audio:           # 音量设置
    master_volume, sfx_volume, music_volume, ui_volume

video:           # 视频设置
    fullscreen, vsync, cr_effect, scanlines, glow

gameplay:        # 游戏设置
    difficulty, flipper_sensitivity, launch_power

accessibility:   # 无障碍设置
    large_text, high_contrast, reduce_motion, haptic_feedback
```

---

### 4.5 SocialSharingV4 (`scripts/v4/SocialSharingV4.gd`)

**功能:** 社交分享

**分享模板:**
```gdscript
"high_score": "I just scored {score} points in {game}!"
"achievement": "I just unlocked '{achievement}' in {game}!"
"challenge": "I completed {challenge} and earned {reward} coins!"
```

**分享方法:**
```gdscript
func share_high_score(score: int, character: String)
func share_achievement(achievement_name: String, points: int)
func share_challenge_completion(challenge_name: String, reward: int)
```

---

### 4.6 LocalizationV4 (`scripts/v4/LocalizationV4.gd`)

**功能:** 本地化支持

**支持语言:**
```gdscript
const LANGUAGES = [
    {"code": "en", "name": "English"},
    {"code": "zh", "name": "Chinese"},
    {"code": "ja", "name": "Japanese"},
    {"code": "ko", "name": "Korean"},
    {"code": "es", "name": "Spanish"},
    {"code": "de", "name": "German"},
    {"code": "fr", "name": "French"}
]
```

**使用方法:**
```gdscript
func tr(key: String, context: String = "") -> String
func set_language(lang_code: String)
func get_language() -> String
```

---

### 4.7 ReplayV4 (`scripts/v4/ReplayV4.gd`)

**功能:** 回放系统

**录制与回放:**
```gdscript
func start_recording(final_score: int = 0, character: String = "sparky")
func stop_recording() -> String
func load_replay(replay_id: String) -> bool
func start_replay() -> bool
func get_next_frame() -> Dictionary
```

**回放管理:**
```gdscript
func get_all_replays() -> Array
func delete_replay(replay_id: String) -> bool
func export_replay(replay_id: String) -> String
func import_replay(json_string: String) -> bool
```

---

## 5. 高级功能

### 5.1 LightingV4 (`scripts/v4/LightingV4.gd`)

**功能:** 动态光影系统

**区域光影:**
```gdscript
func set_zone_light(zone_name: String, color: Color, energy: float)
func pulse_light(zone_name: String, duration: float, intensity: float)
func flash_light(color: Color, duration: float)
func animate_light_to(zone_name: String, target_color: Color, duration: float)
```

---

### 5.2 BackgroundV4 (`scripts/v4/BackgroundV4.gd`)

**功能:** 背景动画系统

**动画类型:**
```gdscript
"idle"         # 待机动画
"pulse"        # 脉冲动画
"celebrate"    # 庆祝动画
```

**天气效果:**
```gdscript
func set_weather(weather_type: String)  # none/rain/snow/sparkles
func parallax_scroll(speed: Vector2)
func transition_to(background_name: String, duration: float = 1.0)
```

---

### 5.3 SpecialBallV4 (`scripts/v4/SpecialBallV4.gd`)

**功能:** 特殊球类型

**球类型:**
```gdscript
NORMAL:     {"probability": 0.7, "name": "Normal"}
FIREBALL:   {"probability": 0.1, "special": "double_points"}
GHOSTBALL:  {"probability": 0.1, "special": "phase_through"}
MULTIBALL:  {"probability": 0.05, "special": "spawn_balls"}
MEGABALL:   {"probability": 0.05, "special": "triple_points"}
```

---

### 5.4 ShopV4 (`scripts/v4/ShopV4.gd`)

**功能:** 游戏内商城

**商品列表:**
```gdscript
"double_points_1min"    # 2倍积分 ¥100
"extra_ball"            # 额外球 ¥200
"safe_landing"          # 安全着陆 ¥150
"theme_sparky"          # Sparky主题 ¥500
"theme_dino"            # Dino主题 ¥500
"gold_ball"             # 金球皮肤 ¥300
"rainbow_ball"          # 彩虹皮肤 ¥500
"title_pro"              # Pro称号 ¥1000
"title_master"           # Master称号 ¥2000
```

---

### 5.5 ChallengeModeV4 (`scripts/v4/ChallengeModeV4.gd`)

**功能:** 挑战模式

**挑战模式:**
```gdscript
TIME_ATTACK:  # 时间攻击 - 2分钟内尽可能高分
SURVIVAL:      # 生存 - 存活越久越好
PRECISION:     # 精准 - 击中指定目标
MADNESS:       # 疯狂 - 2x球大小+3x重力
```

---

### 5.6 AccessibilityV4 (`scripts/v4/AccessibilityV4.gd`)

**功能:** 无障碍系统

**无障碍功能:**
```gdscript
# 文字大小
func set_large_text(enabled: bool)
func set_text_scale(scale: float)

# 颜色模式
func set_high_contrast(enabled: bool)
func set_color_blind_mode(mode: int)  # 0=none, 1=red-green, 2=blue-yellow

# 运动
func set_reduce_motion(enabled: bool)

# 触觉
func set_haptic_feedback(enabled: bool)
func trigger_haptic(type: String)  # light/medium/heavy
```

---

### 5.7 CloudSaveV4 (`scripts/v4/CloudSaveV4.gd`)

**功能:** 云存档

**主要方法:**
```gdscript
func upload_save(data: Dictionary) -> bool
func download_save() -> Dictionary
func sync() -> void
func create_backup() -> bool
func restore_backup(backup_id: String) -> bool
```

---

## 6. 广告系统

### 6.1 AdSystemV4 (`scripts/v4/AdSystemV4.gd`)

**功能:** 广告变现系统

**广告类型:**
```gdscript
激励视频（主要）:
    extra_life:    # +1球
    double_score:  # 2倍得分30秒
    coin_bonus:    # +100金币
    temp_skin:      # 24小时皮肤
    continue:       # 复活

Banner（次要）:
    底部横幅（仅主菜单/商城）

插屏（可选）:
    全屏广告（场景切换时）
```

**配置:**
```gdscript
@export var enabled: bool = true
@export var ad_provider: String = "admob"
@export var reward_cooldown: float = 30.0
@export var daily_limit: int = 10
```

**使用方法:**
```gdscript
func is_ad_available(ad_type: String) -> bool
func show_rewarded_ad(ad_type: String, callback: Callable) -> bool
func get_available_rewards() -> Array
func get_ad_statistics() -> Dictionary
```

---

### 6.2 AdWatchUI (`scenes/AdWatchUI.tscn`)

**功能:** 广告观看UI

**UI组件:**
- 奖励图标
- 倒计时显示
- 观看按钮
- 跳过按钮
- 成功提示

**使用方式:**
```gdscript
func setup(reward_data: Dictionary)
func show_for_reward(reward_id: String)
```

---

## 7. 使用说明

### 7.1 项目结构

```
game/pin-ball/
├── scripts/v4/              # 所有GDScript文件
│   ├── Core/               # 核心系统
│   ├── Enhancement/         # 增强功能
│   ├── Polish/              # 打磨系统
│   ├── Bonus/               # 附加系统
│   └── NewPolishing/        # 高级功能
├── scenes/                  # 场景文件
├── assets/                  # 资源文件
├── project.godot           # 项目配置
└── agent_doc/              # 本文档
```

### 7.2 Autoload配置

在`project.godot`中已配置以下 autoload（部分名称与脚本不同）:

```ini
GlobalGameSettings="*res://scripts/GlobalGameSettings.gd"
SaveManager="*res://scripts/SaveManager.gd"
GameManagerV4="*res://scripts/v4/GameManagerV4.gd"
DifficultySystem="*res://scripts/v4/DifficultySystem.gd"
ScreenShake="*res://scripts/v4/ScreenShake.gd"
ComboSystem="*res://scripts/v4/ComboSystem.gd"
BallPoolV4="*res://scripts/v4/BallPoolV4.gd"
...（见 project.godot [autoload]，共 30+ 项）
```

### 7.3 快速开始

1. **运行游戏:**
```bash
cd /home/pi/game/pin-ball
godot4 .
```

2. **测试特定功能:**
- 保存/加载: `GameManagerV4.save_game_state()` / `GameManagerV4.load_game_state()`
- 成就: `AchievementSystemV4.unlock_achievement(ach_id)` 等
- 广告: `AdSystemV4.is_ad_available(ad_type)` 等

3. **调试模式:**
- 启用调试: `GlobalGameSettings.get().debug_mode = true`
- 查看日志: `tail -f ~/.openclaw/logs/*.log`

---

## 8. 文件索引

| # | 文件 | 大小 | 描述 |
|---|------|------|------|
| 1 | scripts/v4/GameManagerV4.gd | ~10KB | 游戏状态管理 |
| 2 | scripts/v4/BallPoolV4.gd | ~5KB | 对象池 |
| 3 | scripts/v4/CharacterThemeManagerV4.gd | ~3KB | 角色主题 |
| 4 | scripts/v4/BonusManagerV4.gd | ~4KB | 奖励管理 |
| 5 | scripts/v4/SaveManagerV4.gd | ~8KB | 存档管理 |
| 6-33 | 其他脚本 | 各2-10KB | 各类功能 |
| - | scenes/*.tscn | 各1-3KB | UI场景 |

---

## 9. 技术规格

**引擎版本:** Godot 4.x  
**语言:** GDScript  
**目标平台:** iOS, Android, PC, Mac, Linux  
**架构:** Autoload Singleton + Component Pattern

---

*文档版本:* 1.0  
*最后更新:* 2026-02-13
