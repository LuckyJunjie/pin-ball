#!/bin/bash
# Godot Pinball - Cloud Development Setup
# GitHub Codespaces Installation Script

set -e

echo "🎮 开始配置云端Godot开发环境..."

# 1. 安装系统依赖
echo "📦 安装系统依赖..."
apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    git \
    vim \
    fonts-noto-cjk \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libasound2 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libxi6 \
    libopenal1

# 2. 下载并安装Godot 4.x (headless + editor)
echo "⬇️ 下载Godot 4.4.1..."
GODOT_VERSION="4.4.1"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
GODOT_HEADLESS_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64_headless.zip"

cd /tmp
wget -q ${GODOT_URL} -O godot.zip
wget -q ${GODOT_HEADLESS_URL} -O godot_headless.zip

# 安装editor
echo "📀 安装Godot Editor..."
unzip -q godot.zip
mv Godot_v${GODOT_VERSION}_linux.x86_64 /usr/local/bin/godot
chmod +x /usr/local/bin/godot

# 安装headless (用于CLI测试)
echo "⚙️ 安装Godot Headless..."
unzip -q godot_headless.zip
mv Godot_v${GODOT_VERSION}_linux.x86_64 /usr/local/bin/godot_headless
chmod +x /usr/local/bin/godot_headless

# 安装模板
echo "📦 安装Godot Export Templates..."
mkdir -p ~/.local/share/godot/export_templates/${GODOT_VERSION}
cd /tmp
wget -q https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_export_templates.tpz -O templates.tpz
unzip -q templates.tpz
mv templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}/

# 3. 配置环境变量
echo "🔧 配置环境变量..."
export GODOT_BIN=/usr/local/bin/godot
export GODOT_HEADLESS_BIN=/usr/local/bin/godot_headless

# 4. 清理
rm -f godot.zip godot_headless.zip templates.tpz
rm -rf templates

echo ""
echo "✅ Godot安装完成!"
echo "   Editor: /usr/local/bin/godot"
echo "   Headless: /usr/local/bin/godot_headless"
echo "   Version: ${GODOT_VERSION}"
echo ""
echo "🎮 启动Godot Editor: godot"
echo "🧪 运行项目: godot_headless --path /workspaces/pin-ball"
