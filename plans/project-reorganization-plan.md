# Project Reorganization Plan - Pin-Ball Game v1.0 to v4.0

## Current State Analysis

The project has evolved through multiple versions (v1.0 to v4.0) with assets, scripts, and design documents scattered throughout the structure. The current v4.0 implementation is the active version, while older versions are mixed in.

### Key Findings:

1. **Version-Specific Assets**: Assets are organized by version in `assets/sprites/` and `assets/sounds/`:
   - `v1.0-v2.0/` - Early version assets
   - `v3.0/` - Version 3.0 assets  
   - `v4.0/` - Current version assets
   - Root-level assets appear to be v4.0 assets

2. **Version-Specific Design Documents**: Separate design directories:
   - `design-v2.0/` - Version 2.0 design docs
   - `design-v3.0/` - Version 3.0 design docs
   - `design-v4.0/` - Current version design docs

3. **Source Code Organization**:
   - `scripts/v4/` - v4.0 specific scripts
   - Root `scripts/` - Mix of legacy and current scripts
   - `scenes/` - Mix of legacy scenes and v4.0 scenes (MainV4.tscn, MainMenuV4.tscn)

4. **Project Configuration**: `project.godot` references v4.0 scripts and scenes

## Proposed Reorganization Structure

```
pin-ball/
├── archived/                    # All historical versions (v1.0-v3.0)
│   ├── v1.0-v2.0/
│   │   ├── assets/
│   │   │   ├── sprites/
│   │   │   └── sounds/
│   │   ├── design/
│   │   ├── scripts/
│   │   └── scenes/
│   ├── v3.0/
│   │   ├── assets/
│   │   │   ├── sprites/
│   │   │   └── sounds/
│   │   ├── design/
│   │   ├── scripts/
│   │   └── scenes/
│   └── README.md
├── assets/                      # Current v4.0 assets only
│   ├── sprites/
│   │   ├── v4.0/               # Keep v4.0 subfolder for organization
│   │   └── (root sprites moved from v4.0/)
│   ├── sounds/
│   ├── particles/
│   └── tilesets/
├── design/                      # Current v4.0 design only
│   └── (contents from design-v4.0/)
├── scripts/
│   ├── v4/                     # v4.0 specific scripts (keep as is)
│   ├── core/                   # Core scripts used by v4.0
│   └── legacy/                 # Legacy scripts not used by v4.0
├── scenes/
│   ├── v4/                     # v4.0 specific scenes
│   ├── core/                   # Core scenes used by v4.0
│   └── zones/                  # Zone scenes (already organized)
├── analysis/
├── config/
├── docs/
├── requirements/
├── test/
├── tools/
├── .editorconfig
├── .gitignore
├── CHANGELOG.md
├── export_presets.cfg
├── icon.svg
├── LICENSE
├── project.godot
├── README.md
├── VERSION
└── VERSIONS.md
```

## Detailed Migration Plan

### Phase 1: Create Archive Structure
1. Create `archived/` directory with subdirectories for each version
2. Move version-specific design documents to `archived/{version}/design/`
3. Move version-specific assets to `archived/{version}/assets/`

### Phase 2: Reorganize Current v4.0 Assets
1. Move root-level sprites that belong to v4.0 into `assets/sprites/v4.0/`
2. Ensure all v4.0 assets are properly organized
3. Update any asset references in Godot scenes if paths change

### Phase 3: Reorganize Source Code
1. Identify which scripts in root `scripts/` are used by v4.0 vs legacy
2. Move legacy scripts to `scripts/legacy/`
3. Move core v4.0 scripts to `scripts/core/`
4. Keep `scripts/v4/` as is
5. Update any script references in Godot scenes

### Phase 4: Reorganize Scenes
1. Move v4.0 specific scenes to `scenes/v4/`
2. Move core scenes to `scenes/core/`
3. Update `project.godot` main scene reference if needed

### Phase 5: Update Project Configuration
1. Verify `project.godot` references are correct after reorganization
2. Update any autoload paths if scripts are moved
3. Test that the project loads correctly

### Phase 6: Cleanup
1. Remove empty directories
2. Update documentation references
3. Create README files in archived directories

## Risk Mitigation

1. **Backup Before Changes**: Create a backup of the entire project
2. **Incremental Testing**: Test after each major move to ensure v4.0 still works
3. **Godot Reference Updates**: Use Godot's refactoring tools to update resource paths
4. **Version Control**: Use git to track changes and allow rollback

## Success Criteria

1. v4.0 game builds and runs without errors
2. All v4.0 features work as before
3. Archived versions are accessible but not interfering with development
4. Project structure is clean and logical
5. Future development can focus on v4.0 without legacy clutter

## Next Steps

1. Review and approve this plan
2. Create detailed todo list for implementation
3. Begin Phase 1 implementation