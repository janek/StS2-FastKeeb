# Repository Guidelines

## Project Structure & Modules
- `FastKeebCode/`: C# mod source. Entry point `MainFile.cs` with `[ModInitializer]` and Harmony setup.
- `FastKeeb/`: mod assets (e.g., `mod_image.png`). Place localization JSON under `FastKeeb/localization/` if used.
- `FastKeeb.csproj`: build/publish logic, references to game DLLs, and copy/export to the Slay the Spire 2 mods folder.
- `project.godot`, `export_presets.cfg`: Godot 4.5 project configuration.
- `Makefile`: convenience targets for common dotnet actions.

## Build, Test, and Development Commands
- `make restore`: Restore NuGet packages.
- `make build`: Compile the mod; copies `.dll` and `FastKeeb.json` into the game `mods/FastKeeb/` folder when paths resolve.
- `make install`: `dotnet publish` + Godot export; writes `FastKeeb.pck` to `mods/FastKeeb/`.
- `make clean`: Remove build output (`bin/`, `obj/`).
- `open-mods-dir`: opens the mods folder (auto-detects OS).
- `open-game`: kills the game if running, then launches it.
- `restart-game`: alias for `open-game`.
- `wipe-mods`: clears this mod’s folder in the game’s mods directory.
- `wipe-all-mods`: clears the entire mods directory. Use `CONFIRM=1`.
Notes:
- Configure `GodotPath` and `SteamLibraryPath` in `FastKeeb.csproj` if the build errors about missing paths. Keep Godot at 4.5.1 (MegaDot).
- After install, launch the game to validate the mod loads.
- Optional: override the game path with `STS2_DIR` (defaults per OS). Example: `make STS2_DIR="$$HOME/SteamLibrary/steamapps/common/Slay the Spire 2" open-game`.
- To avoid Steam init errors, set `STEAM_APPID` or ensure `$(STS2_DIR)/steam_appid.txt` exists; `open-game` will prefer launching via Steam when an AppID is available.

## Coding Style & Naming Conventions
- C# (`net9.0`), nullable enabled; 4-space indentation.
- Naming: PascalCase for types/methods/constants (e.g., `ModId`), camelCase for locals/parameters.
- Logging: use `MainFile.Logger.Info("...")`.
- Harmony patches: keep minimal and well-scoped; prefer small helper methods for testable logic.
- Analyzers: `Alchyr.Sts2.ModAnalyzers` runs; keep localization files under `FastKeeb/localization/` as referenced in the project.

## Testing Guidelines
- No unit test suite yet; validate in-game.
- Smoke test: build/install, then confirm logs: "=== FastKeeb loaded ===" and "=== FastKeeb initialized, Harmony patches applied ===".
- For non-game logic, factor into pure methods to enable future unit tests.

## Commit & Pull Request Guidelines
- Commits: concise, present-tense, imperative (e.g., "Add Makefile", "Use Logger.Info for startup").
- PRs: clear description, linked issues, reproduction steps, logs/screenshots if behavior changes; note OS. Ensure `make build` passes and no unintended asset changes.

## Security & Configuration Tips
- Do not upgrade Godot beyond 4.5.1; newer exports may not load in-game.
- Avoid committing user-specific paths/keys; keep machine paths in local overrides, not VCS.
