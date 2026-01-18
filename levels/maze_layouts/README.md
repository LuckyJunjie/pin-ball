# Maze Layouts

This directory contains JSON files defining maze pipe layouts for different levels.

## Format

Each layout file is a JSON object with the following structure:

```json
{
  "level_name": "level_1",
  "tile_size": 32,
  "tiles": [
    {"position": [x, y], "tile_id": id}
  ]
}
```

### Fields

- `level_name`: String identifier for the level
- `tile_size`: Integer pixel size of each tile (typically 32)
- `tiles`: Array of tile objects, each containing:
  - `position`: Array `[x, y]` in tile coordinates (not world coordinates)
  - `tile_id`: Integer tile ID (0 = empty, 1 = vertical wall, 2 = horizontal wall, etc.)

### Tile IDs

- `0`: Empty/no tile
- `1`: Vertical wall tile (atlas coords 0,0)
- `2`: Horizontal wall tile (atlas coords 1,0)
- Additional tile IDs can be added as needed

## Coordinate System

Tiles use tile coordinates, not world pixel coordinates. To convert:
- World X to tile X: `tile_x = int(world_x / tile_size)`
- World Y to tile Y: `tile_y = int(world_y / tile_size)`

For example, world position (720, 400) with tile_size 32 = tile (22, 12).

## Adding New Layouts

1. Create a new JSON file: `level_N.json`
2. Define the maze path using tile coordinates
3. Reference the layout in `MazePipeManager.gd` using the filename (without .json extension)
