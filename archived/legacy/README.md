# Legacy Scenes and Scripts (v1.0–v3.0)

Moved from the main project because they are not used by v4.0.

## Scenes

- `Main.tscn` – v1–v3 main game scene (replaced by MainV4.tscn)
- `MainMenu.tscn` – v1–v3 main menu (replaced by MainMenuV4.tscn)
- `ShopScene.tscn` – Shop scene
- `Obstacle.tscn` – Obstacle prefab (used by Main.tscn)
- `Hold.tscn` – Hold prefab (used by Main.tscn)
- `BallQueue.tscn` – Ball queue (used by Main.tscn)

## Scripts

- `GameManager.gd` – v1–v3 game manager
- `BallQueue.gd`, `Obstacle.gd`, `Hold.gd` – Component scripts
- `MainMenuManager.gd`, `ShopManager.gd`, `UI.gd` – UI scripts
- `ObstacleSpawner.gd` – Obstacle placement
- `MultiballManager.gd`, `MultiballTarget.gd` – Multiball system

To use any of these, move them back and fix paths.
