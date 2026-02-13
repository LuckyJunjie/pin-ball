# 🎮 Pinball Game - Cloud Development Guide

**Cloud-First Development with GitHub Codespaces + Godot**

---

## 🚀 Quick Start

### Option 1: GitHub Codespaces (Recommended)

1. **Open this repo in GitHub**
2. Click **"Code"** → **"Codespaces"** → **"Create codespace on main"**
3. Wait for Godot installation (~2-3 minutes)
4. Click **"Open in Browser"** or use **VS Code Web**

### Option 2: VS Code Remote SSH

1. Install **Remote SSH** extension
2. Connect to GitHub Codespaces or any cloud VM
3. Install Godot following `.devcontainer/setup.sh`

---

## 🛠️ Cloud Environment

| Component | Version | Purpose |
|-----------|---------|---------|
| Godot Editor | 4.4.1 | Full IDE with debugging |
| Godot Headless | 4.4.1 | CLI testing, export |
| GDScript | - | Game logic |

---

## 🎮 How to Test

### In Cloud (Primary)

```bash
# Test project loads correctly
godot --path /workspaces/pin-ball --quiet --headless

# Run with output
godot_headless --path /workspaces/pin-ball 2>&1

# Export to Web (if configured)
godot --headless --export-release "Web" build/web/
```

### On Your MacBook (Secondary)

```bash
# Pull latest changes
git pull origin main

# Test in local Godot
# Open Godot → Import project → Select pinball-game folder
```

---

## 📋 Workflow

```
┌─────────────────────────────────────────────────────────┐
│                    Development Flow                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   1. Cloud Dev (Pi/Vanguard001)                        │
│      ↓                                                  │
│      push to GitHub                                     │
│      ↓                                                  │
│   2. GitHub Actions (Auto Test)                        │
│      ↓                                                  │
│      ✅ CI Pass?                                         │
│         ↓         ↓                                     │
│        Yes       No → Fix bugs → Retry                  │
│         ↓                                                  │
│   3. Codespaces Testing (Primary)                       │
│      ↓                                                  │
│      4. User MacBook Testing (Secondary)                │
│      ↓                                                  │
│      5. Deploy/Iterate                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 Troubleshooting

### Godot Won't Start in Cloud?

```bash
# Check Godot installation
which godot
godot --version

# Reinstall if needed
bash .devcontainer/setup.sh
```

### Export Templates Missing?

```bash
# Download templates
mkdir -p ~/.local/share/godot/export_templates/4.4.1
wget -q https://github.com/godotengine/godot/releases/download/4.4.1/Godot_v4.4.1_export_templates.tpz
unzip -q Godot_v4.4.1_export_templates.tpz -d templates/
mv templates/* ~/.local/share/godot/export_templates/4.4.1/
```

### Performance Issues?

- Use **Godot Headless** for testing (faster)
- Use **Web Export** for quick visual testing
- Reserve GPU-heavy testing for MacBook

---

## 📁 Project Structure

```
pin-ball/
├── scenes/           # .tscn scene files
├── scripts/          # .gd GDScript files
├── assets/           # Images, sounds, etc.
├── .devcontainer/    # Cloud dev config
├── .github/         # CI/CD workflows
├── build/           # Exported builds
└── README.md        # This file
```

---

## 🎯 Best Practices

1. **Commit often** - Small, focused commits
2. **Test in cloud first** - Use CI as first gate
3. **Use MacBook for final validation** - Before major releases
4. **Document issues** - Add to project board

---

## 📞 Support

- **Primary Test:** GitHub Codespaces
- **Secondary Test:** Your MacBook (Godot 4.x)
- **Issues:** GitHub Issues tab

---

*Last Updated: 2026-02-13*
