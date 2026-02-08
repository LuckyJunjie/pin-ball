# Cursor IDE 中找不到 DeepSeek Models 选项 - 解决方案

## 问题说明
你的 Cursor IDE 版本是 **2.3.29**（从日志中获取），这个版本应该支持自定义模型，但你在设置界面中看不到 "Models" 选项卡。

## 解决方案

### 方案 1: 在 Cursor 设置中查找 Models 选项（最可能的位置）

根据 Cursor IDE 的最新版本，Models 配置可能在以下位置：

#### 方法 A: 通过主设置界面

1. **打开设置**:
   - 点击 Cursor 左上角的 **Cursor** 菜单
   - 选择 **Settings** 或 **Preferences**
   - 或者按快捷键 `Cmd + ,`

2. **查找 Models 选项卡**:
   - 在设置界面左侧，查找以下选项：
     - **"Features"** → 展开后查找 **"AI Models"** 或 **"Models"**
     - **"AI"** 或 **"AI Settings"**
     - **"General"** → 查找 **"Model Provider"** 或 **"Custom Models"**
     - **"Advanced"** → 查找模型相关设置

3. **如果找到了 "Models" 或 "AI Models" 选项**:
   - 点击进入
   - 应该能看到 **"Add Model"** 或 **"+"** 按钮
   - 点击添加自定义模型
   - 填写以下信息：
     ```
     Model Name: deepseek-chat
     API Type: OpenAI Compatible
     API URL: https://api.deepseek.com/v1
     API Key: [你的完整DeepSeek API密钥]
     Model ID: deepseek-chat
     ```

#### 方法 B: 通过命令面板

1. 按 `Cmd + Shift + P` 打开命令面板
2. 输入以下任一命令：
   - `Cursor: Settings`
   - `Preferences: Open Settings`
   - `Models`
   - `Add Custom Model`
   - `Configure AI Model`

3. 如果找到了相关命令，执行它应该会打开配置界面

#### 方法 C: 直接在设置中搜索

1. 打开设置 (`Cmd + ,`)
2. 在设置搜索框中输入：
   - `model`
   - `custom model`
   - `openai`
   - `api key`
   - `deepseek`

3. 应该会显示相关的设置选项

### 方案 2: 配置文件已更新（备用方案）

如果你的 Cursor 版本确实不支持通过 UI 配置，我已经更新了配置文件，添加了以下配置：

```json
{
    "window.commandCenter": false,
    "cursor.aiModel": "deepseek-chat",
    "cursor.openAIModel": "deepseek-chat",
    "cursor.openAIBaseURL": "https://api.deepseek.com/v1",
    "cursor.openAIApiKey": "sk-d7923***********************dca3",
    "cursor.chatModel": "deepseek-chat",
    "cursor.composerModel": "deepseek-chat",
    "anysphere.aiModel": "deepseek-chat",
    "anysphere.openAIModel": "deepseek-chat",
    "anysphere.openAIBaseURL": "https://api.deepseek.com/v1",
    "anysphere.openAIApiKey": "sk-d7923***********************dca3",
    "anysphere.chatModel": "deepseek-chat",
    "anysphere.composerModel": "deepseek-chat"
}
```

**重要**: 
1. 需要将 `sk-d7923***********************dca3` 替换为你的**完整** API 密钥
2. 替换后**重启 Cursor IDE**

### 方案 3: 验证配置是否已经生效

即使 UI 中看不到模型选择器，配置可能已经生效。验证方法：

1. **在 Cursor 中测试 AI 功能**:
   - 打开一个代码文件
   - 按 `Cmd + L` 打开聊天界面
   - 输入一个问题，查看响应
   - 检查是否使用 DeepSeek API（可以通过开发者工具的网络标签页查看）

2. **查看开发者工具**:
   - 按 `Cmd + Option + I` 或 `Cmd + Shift + P` → "Toggle Developer Tools"
   - 切换到 **Network** 标签页
   - 在 Cursor 中使用 AI 功能
   - 查看网络请求中是否有对 `api.deepseek.com` 的调用

3. **测试 API 连接**:
   在终端中运行：
   ```bash
   curl https://api.deepseek.com/v1/models \
     -H "Authorization: Bearer 你的完整API密钥"
   ```
   如果返回模型列表，说明 API 密钥有效。

### 方案 4: 更新 Cursor IDE

如果上述方法都不行，尝试更新到最新版本：

1. 点击 **Cursor** 菜单 → **Check for Updates**
2. 或者从官网下载最新版本：https://cursor.sh

### 方案 5: 联系 Cursor 支持或查看文档

1. **查看官方文档**: https://cursor.sh/docs
2. **查看 Cursor 博客**: https://www.cursor-ide.com/blog
   - 特别是这篇：https://www.cursor-ide.com/blog/deepseek-v3-cursor-guide
3. **查看视频教程**: 
   - [3步将DeepSeek接入Cursor](https://www.youtube.com/watch?v=xFOPkIVKwF8)

## 当前状态检查清单

请按照以下步骤逐一检查：

- [ ] **步骤 1**: 在 Cursor 设置中搜索 "model" - 找到相关选项了吗？
- [ ] **步骤 2**: 在命令面板 (`Cmd + Shift + P`) 中搜索 "model" - 找到相关命令了吗？
- [ ] **步骤 3**: 检查 Cursor 菜单栏 → Settings → 是否有 "Models" 或 "AI" 相关选项
- [ ] **步骤 4**: 已替换配置文件中的完整 API 密钥
- [ ] **步骤 5**: 已重启 Cursor IDE
- [ ] **步骤 6**: 使用开发者工具检查网络请求，看是否有对 DeepSeek API 的调用
- [ ] **步骤 7**: 测试 AI 功能是否正常工作（即使看不到模型选择器）

## 重要提醒

**配置文件中使用的是掩码 API 密钥，必须替换为完整密钥！**

配置文件位置：`~/Library/Application Support/Cursor/User/settings.json`

替换这一行：
```json
"cursor.openAIApiKey": "sk-d7923***********************dca3",
"anysphere.openAIApiKey": "sk-d7923***********************dca3",
```

替换为你的完整 DeepSeek API 密钥（Key 名称: `game_worker_20260110`）

替换后**必须重启 Cursor IDE**！

## 如果以上都不行

如果尝试了所有方法仍然看不到 Models 选项，可能是因为：

1. **Cursor 版本的特殊性**: 某些版本的 UI 布局可能不同
2. **功能限制**: 免费版可能不支持自定义模型
3. **地区限制**: 某些地区可能有限制

**最后的选择**:
- 在项目代码中直接使用 DeepSeek API（我们已经创建了 `scripts/DeepSeekAPI.gd`）
- 或者等待 Cursor 更新，或者联系 Cursor 支持获取帮助

---

**请告诉我你尝试了哪些步骤，以及结果如何，这样我可以提供更具体的帮助！**
