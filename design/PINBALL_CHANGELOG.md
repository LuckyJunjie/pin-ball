# Pinball v4.0 – Changelog (Minimax Extension)

**Generated:** 2026-02-13  
**Source:** Minimax 2.1 extension (four phases)

---

## Summary

| Phase | Date | Systems | Content |
|-------|------|---------|---------|
| **Phase 1** | 2026-02-11 | 5 | Core: GameManager, BallPool, Theme, Bonus, Save |
| **Phase 2** | 2026-02-12 | 9 | Enhancement: Difficulty, Shake, Combo, Trail, Particles, Audio, Mobile, Achievements, Auto-save |
| **Phase 3** | 2026-02-13 | 5 | Polish: CRT, Animatronic, Leaderboard, Tutorial, Performance |
| **Phase 4** | 2026-02-13 | 8 | Additional: Daily Challenge, Stats, Easter Egg, Settings, Social, Localization, Replay, Ads |

**Total: 32 systems** (27 script/autoload systems + 5 zone scripts).

---

## File Mapping (Actual Scripts vs Names)

Some autoloads use shorter names than “V4” suffix:

| Changelog name | Actual script | Autoload name |
|----------------|---------------|---------------|
| SaveManagerV4 | GameManagerV4 (internal save) + `scripts/SaveManager.gd` | SaveManager |
| AutoSaveV4 | Built into GameManagerV4 | — |
| DifficultySystemV4 | DifficultySystem.gd | DifficultySystem |
| ScreenShakeV4 | ScreenShake.gd | ScreenShake |
| ComboSystemV4 | ComboSystem.gd | ComboSystem |

Zones: AndroidAcresV4.gd, GoogleGalleryV4.gd, FlutterForestV4.gd, DinoDesertV4.gd, SparkyScorchV4.gd.

---

## Design Doc Updates

- **GDD-v4.0.md**: §10 Implementation History added (phase table + design notes).
- **agent_doc/SYSTEMS.md**: Corrected filenames and autoload names; Save/AutoSave and BallPoolV4 static-call notes.
- **agent_doc/README.md**: Corrected file index and autoload examples.
- **design/README.md**: Reference to changelog and §10 added.

See **GDD-v4.0.md §10** and **agent_doc/SYSTEMS.md** for full system list and API details.
