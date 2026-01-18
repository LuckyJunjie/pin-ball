# Cursor IDE 配置 DeepSeek 模型指南

本指南将帮助你在 Cursor IDE 中配置 DeepSeek 模型，替代默认的 Claude、ChatGPT 等模型。

## ⚠️ 重要提示

**如果你的 Cursor IDE 设置界面中没有看到 DeepSeek API 选项（这是正常的），请直接使用方法二：直接编辑配置文件。**

Cursor IDE 的某些版本可能不在 UI 中显示自定义模型配置选项，但可以通过直接编辑配置文件来实现。

## 方法一：通过 Cursor IDE 设置界面配置（如果可用）

**注意**：如果你的 Cursor 版本不支持此方法，请跳过直接使用方法二。

### 步骤 1: 打开 Cursor 设置

1. 打开 Cursor IDE
2. 点击左下角的**齿轮图标** ⚙️ 或按快捷键 `Cmd + ,` (macOS) / `Ctrl + ,` (Windows/Linux)
3. 在设置界面左侧，查找 **"Models"**、**"AI"** 或 **"OpenAI"** 相关选项卡

### 步骤 2-5: 如果找到相关选项

按照界面提示配置 API 密钥和 Base URL。如果**找不到相关选项**，请使用方法二。

## 方法二：直接编辑配置文件（✅ 推荐方法 - 已自动配置）

**✅ 你的配置文件已经自动更新！** 如果 UI 中没有看到 DeepSeek 选项，这是正常现象，直接编辑配置文件即可。

### 配置文件位置

- **macOS**: `~/Library/Application Support/Cursor/User/settings.json`
- **Windows**: `%APPDATA%\Cursor\User\settings.json`
- **Linux**: `~/.config/Cursor/User/settings.json`

### ✅ 已自动添加的配置

你的 `settings.json` 已经包含以下配置：

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

### ⚠️ 必须完成的最后一步

**替换完整的 API 密钥**：

1. 打开配置文件：
   ```bash
   # macOS
   open ~/Library/Application\ Support/Cursor/User/settings.json
   ```

2. 找到这一行：
   ```json
   "cursor.openAIApiKey": "sk-d7923***********************dca3"
   ```

3. 替换为你的**完整** DeepSeek API 密钥（Key 名称: `game_worker_20260110`）

4. **保存文件**

5. **重启 Cursor IDE**（必须重启才能生效）

⚠️ **重要**：
- 配置文件中的 API 密钥是掩码版本，必须替换为完整密钥
- 确保 JSON 格式正确（有逗号分隔）
- 编辑前建议备份原文件

### 配置说明

- `cursor.aiModel`: 默认使用的 AI 模型名称
- `cursor.openAIModel`: OpenAI 兼容模型的名称
- `cursor.openAIBaseURL`: API 的基础 URL（DeepSeek 的端点）
- `cursor.openAIApiKey`: 你的 DeepSeek API 密钥

## 方法三：通过环境变量配置

你也可以通过设置环境变量来配置：

```bash
export CURSOR_OPENAI_API_KEY="sk-d7923***********************dca3"
export CURSOR_OPENAI_BASE_URL="https://api.deepseek.com/v1"
export CURSOR_AI_MODEL="deepseek-chat"
```

然后重启 Cursor IDE。

## 验证配置是否成功

1. 在 Cursor 中打开一个代码文件
2. 使用 `Cmd/Ctrl + K` 触发代码补全
3. 或使用 `Cmd/Ctrl + L` 打开聊天界面
4. 查看是否使用 DeepSeek 模型进行响应

你也可以在聊天界面中问："你是什么模型？" 来确认是否使用了 DeepSeek。

## 常见问题

### Q: 配置后 Cursor 仍然使用默认模型？

**A**: 
1. 确保已保存配置并重启 Cursor IDE
2. 检查 API 密钥是否正确（完整密钥，不是掩码版本）
3. 验证网络是否可以访问 `https://api.deepseek.com`
4. 检查模型名称是否正确：`deepseek-chat` 或 `deepseek-coder`

### Q: 某些功能（如 Composer）无法使用？

**A**: Cursor 的某些高级功能可能仅支持特定模型。DeepSeek 模型可能不完全兼容所有 Cursor 功能。这是正常的，基础聊天和代码补全功能应该可以正常使用。

### Q: API 调用失败？

**A**:
1. 检查 API 密钥是否正确且有效
2. 确认 DeepSeek API 服务状态正常
3. 检查网络连接和防火墙设置
4. 查看 Cursor 的错误日志（Help → Toggle Developer Tools → Console）

### Q: 如何切换到其他模型？

**A**: 在 Cursor 的模型选择下拉菜单中，可以随时切换回默认模型（Claude、ChatGPT 等）或其他已配置的模型。

## API 密钥信息

你的 DeepSeek API 配置信息：

- **API Base URL**: `https://api.deepseek.com/v1`
- **API Key 名称**: `game_worker_20260110`
- **API Key**: `sk-d7923***********************dca3` (需要替换为完整密钥)
- **可用模型**: 
  - `deepseek-chat` - 通用对话模型
  - `deepseek-coder` - 代码专用模型

## 相关资源

- [DeepSeek API 文档](https://platform.deepseek.com/api-docs/)
- [Cursor IDE 官方文档](https://cursor.sh/docs)
- [DeepSeek Cursor 配置指南](https://www.cursor-ide.com/blog/deepseek-v3-cursor-guide)

## 注意事项

⚠️ **安全提醒**：
- 不要将包含 API 密钥的配置文件提交到公共仓库
- API 密钥应该保密，不要在公共场所分享
- 如果密钥泄露，请立即在 DeepSeek 平台重新生成新密钥

---

**配置完成后，记得重启 Cursor IDE 使配置生效！**
