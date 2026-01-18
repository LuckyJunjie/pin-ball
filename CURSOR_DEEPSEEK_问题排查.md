# Cursor IDE DeepSeek 配置问题排查指南

## 当前问题
配置已添加到 `settings.json`，但 Cursor IDE UI 中看不到 DeepSeek 模型选项。

## 可能的原因和解决方案

### 1. 检查 Cursor 版本

**要求**: Cursor 版本需要 **0.44 或更高版本** 才支持自定义模型。

**检查方法**:
- 打开 Cursor IDE
- 点击菜单栏 `Cursor` → `About Cursor` 查看版本号
- 或者在终端运行：`/Applications/Cursor.app/Contents/MacOS/Cursor --version`

**你的当前版本**: v22.20.0 (从之前的检查中获取)

如果版本低于 0.44，需要更新 Cursor IDE。

### 2. 查找 Models 选项卡的正确位置

**方法 A: 通过设置界面**
1. 打开 Cursor IDE
2. 点击左下角齿轮图标 ⚙️ 或按 `Cmd + ,`
3. 在设置界面左侧，查找以下任一选项：
   - **"Models"** 或 **"AI Models"**
   - **"AI"** 或 **"AI Settings"**
   - **"Extensions"** → 查找 AI 相关设置
   - **"Features"** → 查找模型设置

**方法 B: 通过命令面板**
1. 按 `Cmd + Shift + P` 打开命令面板
2. 输入以下命令尝试：
   - "Models"
   - "Add Model"
   - "Custom Model"
   - "AI Model"
   - "Configure Model"

**方法 C: 通过设置搜索**
1. 打开设置 (`Cmd + ,`)
2. 在设置搜索框中输入：
   - "model"
   - "custom"
   - "openai"
   - "api"

### 3. 尝试不同的配置键名

如果 UI 中确实找不到 Models 选项，可能是配置键名不正确。尝试以下配置格式：

#### 方案 A: 使用 `anysphere` 前缀（Cursor 的内部命名）

编辑 `~/Library/Application Support/Cursor/User/settings.json`:

```json
{
    "window.commandCenter": false,
    "anysphere.aiModel": "deepseek-chat",
    "anysphere.openAIModel": "deepseek-chat",
    "anysphere.openAIBaseURL": "https://api.deepseek.com/v1",
    "anysphere.openAIApiKey": "你的完整API密钥",
    "anysphere.chatModel": "deepseek-chat",
    "anysphere.composerModel": "deepseek-chat"
}
```

#### 方案 B: 使用环境变量（如果支持）

在终端中设置环境变量，然后启动 Cursor：

```bash
export CURSOR_OPENAI_API_KEY="你的完整API密钥"
export CURSOR_OPENAI_BASE_URL="https://api.deepseek.com/v1"
export CURSOR_AI_MODEL="deepseek-chat"

# 然后启动 Cursor
open -a Cursor
```

#### 方案 C: 检查是否有单独的模型配置文件

可能 Cursor 使用单独的配置文件存储模型设置。查找：

```bash
# 在 Cursor 配置目录中查找
find ~/Library/Application\ Support/Cursor -name "*model*" -o -name "*ai*" | grep -v node_modules
```

### 4. 检查是否有隐藏设置或实验性功能

某些 Cursor 版本可能将自定义模型功能放在实验性设置中：

1. 打开设置 (`Cmd + ,`)
2. 查找 **"Experimental"** 或 **"Features"** 相关选项
3. 查找 **"Enable Custom Models"** 或类似的开关
4. 如果找到，启用它

### 5. 手动创建模型配置文件

如果 Cursor 使用单独的文件存储模型配置，可能需要手动创建：

#### 查找模型配置文件位置

```bash
# 检查可能的配置文件位置
ls -la ~/Library/Application\ Support/Cursor/User/
ls -la ~/Library/Application\ Support/Cursor/User/globalStorage/
```

#### 可能的配置文件格式

如果找到相关的配置文件（如 `models.json` 或 `ai-config.json`），尝试添加：

```json
{
  "customModels": [
    {
      "name": "deepseek-chat",
      "apiType": "openai",
      "baseURL": "https://api.deepseek.com/v1",
      "apiKey": "你的完整API密钥",
      "modelID": "deepseek-chat",
      "enabled": true
    }
  ]
}
```

### 6. 通过 Cursor 的开发者工具检查

1. 在 Cursor 中按 `Cmd + Shift + P`
2. 输入 "Toggle Developer Tools" 或 "打开开发者工具"
3. 在 Console 标签页中，输入以下命令查看配置：

```javascript
// 查看当前配置
console.log(JSON.parse(JSON.stringify(require('electron').remote.getGlobal('settings'))))
```

或者查看是否有相关的 API 或配置对象。

### 7. 验证 API 密钥和网络连接

即使 UI 中看不到模型选项，配置可能已经生效。验证方法：

1. **测试 API 连接**:
   ```bash
   curl https://api.deepseek.com/v1/models \
     -H "Authorization: Bearer 你的完整API密钥"
   ```

2. **查看 Cursor 的网络请求**:
   - 打开开发者工具 (`Cmd + Option + I`)
   - 切换到 Network 标签页
   - 在 Cursor 中使用 AI 功能
   - 查看是否有对 `api.deepseek.com` 的请求

### 8. 联系 Cursor 支持或社区

如果以上方法都不行，可能是 Cursor 版本或配置的问题：

1. **检查 Cursor 官方文档**: https://cursor.sh/docs
2. **查看 Cursor 社区**: https://forum.cursor.sh 或 Reddit r/cursor
3. **联系 Cursor 支持**: 通过应用内反馈或邮件

### 9. 临时解决方案：使用代码中的 API 调用

如果 Cursor IDE 本身不支持配置，可以在你的项目代码中直接调用 DeepSeek API。我们已经创建了 `scripts/DeepSeekAPI.gd`，你可以：

1. 在 Godot 项目中使用 DeepSeek API
2. 或者创建一个本地代理服务，让 Cursor 通过本地服务调用 DeepSeek

## 推荐的操作步骤

按以下顺序尝试：

1. ✅ **确认 Cursor 版本** - 确保 >= 0.44
2. ✅ **搜索设置界面** - 使用设置搜索功能查找 "model"
3. ✅ **检查命令面板** - 搜索相关命令
4. ✅ **尝试不同的配置键名** - 使用 `anysphere` 前缀
5. ✅ **验证 API 连接** - 使用 curl 测试 API
6. ✅ **查看开发者工具** - 检查网络请求和错误信息
7. ✅ **更新 Cursor** - 确保使用最新版本
8. ✅ **联系支持** - 如果以上都不行

## 当前配置文件内容

你的 `settings.json` 当前内容：

```json
{
    "window.commandCenter": false,
    "cursor.aiModel": "deepseek-chat",
    "cursor.openAIModel": "deepseek-chat",
    "cursor.openAIBaseURL": "https://api.deepseek.com/v1",
    "cursor.openAIApiKey": "sk-d7923***********************dca3",
    "cursor.chatModel": "deepseek-chat",
    "cursor.composerModel": "deepseek-chat"
}
```

**⚠️ 重要**: 记得将 `sk-d7923***********************dca3` 替换为完整的 API 密钥！

## 下一步

请按照上述步骤逐一检查，并告诉我：
1. 你的 Cursor 版本号是多少？
2. 在设置界面中能找到 "Models" 相关的选项吗？
3. 在命令面板中搜索 "model" 能找到相关命令吗？
4. 使用 curl 测试 API 是否正常工作？

根据你的反馈，我可以提供更具体的解决方案。
