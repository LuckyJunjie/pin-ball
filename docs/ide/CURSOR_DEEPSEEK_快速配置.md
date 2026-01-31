# Cursor IDE 配置 DeepSeek - 快速指南

## ✅ 配置已完成！

你的 Cursor IDE 配置文件已经更新，添加了 DeepSeek API 配置。

## 🔧 需要完成的最后一步

### 1. 替换完整的 API 密钥

配置文件位置：`~/Library/Application Support/Cursor/User/settings.json`

**当前配置中的 API 密钥是掩码版本，需要替换为完整密钥：**

```json
"cursor.openAIApiKey": "sk-d7923***********************dca3"
```

**替换为：**
```json
"cursor.openAIApiKey": "你的完整API密钥"
```

你的 API 密钥信息：
- Key 名称: `game_worker_20260110`
- 完整密钥: 需要从 DeepSeek 平台获取（替换掩码部分）

### 2. 重启 Cursor IDE

配置修改后，**必须重启 Cursor IDE** 才能生效：
1. 完全退出 Cursor（`Cmd + Q`）
2. 重新打开 Cursor IDE
3. 配置应该已经生效

### 3. 验证配置

重启后验证是否成功：

1. **打开聊天界面**：按 `Cmd/Ctrl + L`
2. **询问模型**：输入 "你是什么模型？" 或 "What model are you?"
3. **检查响应**：应该会显示 DeepSeek 相关的信息

或者：
- 使用代码补全功能（`Cmd/Ctrl + K`）
- 查看是否使用 DeepSeek 进行响应

## 📝 当前配置内容

你的 `settings.json` 现在包含：

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

## 🔍 如果配置不生效

### 检查清单：

1. ✅ API 密钥是否正确（完整密钥，不是掩码版本）
2. ✅ JSON 格式是否正确（没有语法错误）
3. ✅ 是否已重启 Cursor IDE
4. ✅ 网络是否可以访问 `https://api.deepseek.com`
5. ✅ API 密钥是否有效（在 DeepSeek 平台验证）

### 手动验证配置

打开终端运行：

```bash
# 查看配置文件
cat ~/Library/Application\ Support/Cursor/User/settings.json

# 验证 JSON 格式
python3 -m json.tool ~/Library/Application\ Support/Cursor/User/settings.json
```

### 查看 Cursor 日志

如果配置不生效，可以查看 Cursor 的日志：
1. 在 Cursor 中按 `Cmd/Ctrl + Shift + P`
2. 输入 "Toggle Developer Tools"
3. 查看 Console 标签页的错误信息

## 🎯 切换模型

配置完成后，你可以在 Cursor 中：

- **使用聊天功能**：`Cmd/Ctrl + L` → 使用 DeepSeek 模型
- **代码补全**：`Cmd/Ctrl + K` → 使用 DeepSeek 模型
- **Composer**：`Cmd/Ctrl + I` → 使用 DeepSeek 模型

## 📚 更多信息

详细配置说明请查看：`CURSOR_DEEPSEEK_CONFIG.md` (same directory)

---

**重要提醒**：记得替换配置文件中的 API 密钥为完整密钥，然后重启 Cursor IDE！
