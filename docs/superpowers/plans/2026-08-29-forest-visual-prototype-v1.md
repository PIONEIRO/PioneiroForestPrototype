# Forest Visual Prototype V1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a brand-new Godot 4.7.1 forest visual prototype with one 8-direction player, two forest monsters, layered 2D top-down 3/4 scenery, simple combat readability, and automated headless validation.

**Architecture:** A single hand-authored `ForestTest` scene owns environment composition and camera framing. Player and monster behavior are isolated in focused scripts, while all prototype artwork is stored as original SVG assets so the repository remains text-friendly and licensing is explicit. A small headless contract suite validates direction mapping, movement normalization, monster states and scene boot.

**Tech Stack:** Godot 4.7.1, GDScript, SVG textures, GitHub Actions

**Spec:** `docs/superpowers/specs/2026-08-29-forest-visual-prototype-v1-design.md`

## Global Constraints

- Start from scratch in `PIONEIRO/PioneiroForestPrototype`; do not read, copy or modify `PIONEIRO/PioneiroQuest`.
- Engine version target: Godot 4.7.1.
- Renderer: GL Compatibility.
- Main viewport: 1280x720.
- Visual target: illustrated 2D top-down 3/4, not low-resolution pixel art and not real-time 3D.
- V1 contains one forest scene, one player and exactly two monster archetypes: Forest Slime and Forest Boar.
- Third-party assets cannot be committed without verified provenance in `ASSET_LICENSES.md`.
- No inventory, equipment, quests, classes, towns, persistence, networking, login or economy in V1.

---

### Task 1: Establish the Godot project and headless boot contract

**Files:**
- Create: `project.godot`
- Create: `scenes/forest_test.tscn`
- Create: `scripts/forest_test.gd`
- Create: `tests/test_project_boot.gd`
- Create: `.github/workflows/forest-v1-headless.yml`

**Interfaces:**
- Produces: `res://scenes/forest_test.tscn` as the configured main scene.
- Produces: `ForestTest` root node with `World`, `Actors`, and `HUD` children.

- [ ] **Step 1: Write the failing boot test**

Create `tests/test_project_boot.gd` as a `SceneTree` script that calls `load("res://scenes/forest_test.tscn")`, asserts the result is non-null, instantiates it, and asserts nodes `World`, `Actors`, and `HUD` exist. It exits non-zero on failure and prints `FOREST_V1_BOOT_CONTRACT_PASS` on success.

- [ ] **Step 2: Run the test and verify RED**

Run:

```bash
godot --headless --path . --script res://tests/test_project_boot.gd
```

Expected: FAIL because `project.godot` / `forest_test.tscn` do not yet exist.

- [ ] **Step 3: Add minimal project and scene**

Create `project.godot` with `run/main_scene="res://scenes/forest_test.tscn"`, 1280x720 viewport, canvas-items stretch, and GL Compatibility renderer. Create a `Node2D` root named `ForestTest` with the required three children and attach `scripts/forest_test.gd`.

- [ ] **Step 4: Run the boot test and verify GREEN**

Expected stdout includes `FOREST_V1_BOOT_CONTRACT_PASS` and no parse/load errors.

- [ ] **Step 5: Add CI workflow**

Add a workflow that installs official Godot 4.7.1, imports the project headlessly, runs every `tests/test_*.gd` script, boots the main scene for a short smoke test, and rejects `SCRIPT ERROR`, `Parse Error`, `Failed to load script`, and `Failed loading resource` in logs.

- [ ] **Step 6: Commit**

```bash
git add project.godot scenes/forest_test.tscn scripts/forest_test.gd tests/test_project_boot.gd .github/workflows/forest-v1-headless.yml
git commit -m "feat: bootstrap Forest V1 Godot project"
```

### Task 2: Implement canonical 8-direction player movement

**Files:**
- Create: `scripts/player.gd`
- Create: `tests/test_player_contract.gd`
- Modify: `scenes/forest_test.tscn`

**Interfaces:**
- Produces: `Player.direction_index_from_vector(direction: Vector2) -> int`.
- Produces direction order: `0 S, 1 SE, 2 E, 3 NE, 4 N, 5 NW, 6 W, 7 SW`.
- Produces movement speed `220.0` pixels/second and normalized diagonal input.

- [ ] **Step 1: Write failing player contract tests**

Test all eight cardinal/diagonal vectors against the canonical indices. Also assert `Vector2(1,1).normalized().length()` is used by the controller path so diagonal speed never exceeds cardinal speed.

- [ ] **Step 2: Run test and verify RED**

Expected: FAIL because `scripts/player.gd` does not exist.

- [ ] **Step 3: Implement `Player`**

Use `CharacterBody2D`, gather WASD/arrow input with `Input.get_vector`, normalize non-zero movement, call `move_and_slide()`, retain last facing index, implement a 0.22-second melee pulse on Space, and expose `attack_started(direction_index: int)` signal.

- [ ] **Step 4: Add Player node to the scene**

Give it a small capsule/rectangle collision footprint centered at its feet and attach a `Camera2D` with position smoothing.

- [ ] **Step 5: Run tests and verify GREEN**

Expected stdout includes `FOREST_V1_PLAYER_CONTRACT_PASS`.

- [ ] **Step 6: Commit**

```bash
git add scripts/player.gd tests/test_player_contract.gd scenes/forest_test.tscn
git commit -m "feat: add eight-direction forest player"
```

### Task 3: Create original illustrated prototype art

**Files:**
- Create: `assets/art/player_ranger.svg`
- Create: `assets/art/forest_slime.svg`
- Create: `assets/art/forest_boar.svg`
- Create: `assets/art/tree_oak.svg`
- Create: `assets/art/tree_pine.svg`
- Create: `assets/art/bush.svg`
- Create: `assets/art/rock.svg`
- Create: `assets/art/log.svg`
- Create: `assets/art/flower_patch.svg`
- Create: `ASSET_LICENSES.md`
- Modify: `scripts/player.gd`

**Interfaces:**
- Produces self-contained SVG textures with transparent backgrounds.
- Artwork uses visible grounding shadows and a consistent three-quarter light direction.

- [ ] **Step 1: Add artwork contract test**

Extend boot validation to assert each required SVG exists and is loadable as a `Texture2D` after import.

- [ ] **Step 2: Verify RED**

Expected: asset contract fails because SVG files are absent.

- [ ] **Step 3: Create SVG artwork**

Create original vector illustrations at comfortable source resolutions: player/monsters near 256x320 and props near 256x320. Use layered silhouettes, highlights and shadows rather than flat icons. Keep transparent backgrounds.

- [ ] **Step 4: Wire player art**

Add a Sprite2D child to the player. Animate walk readability with a subtle art-only bob and horizontal lean; do not move the collision origin. Flip only for east/west variants and vary front/back shading through controller-driven modulation so facing changes remain readable during the prototype.

- [ ] **Step 5: Record provenance**

`ASSET_LICENSES.md` must mark every V1 SVG as `Project-original prototype artwork — created for PioneiroForestPrototype; no third-party source` and define the required record format for future external assets.

- [ ] **Step 6: Run tests and commit**

Expected asset contract passes.

```bash
git add assets/art scripts/player.gd ASSET_LICENSES.md tests
git commit -m "feat: add original illustrated Forest V1 art"
```

### Task 4: Build layered forest composition and collisions

**Files:**
- Modify: `scripts/forest_test.gd`
- Modify: `scenes/forest_test.tscn`
- Create: `tests/test_forest_layout_contract.gd`

**Interfaces:**
- `ForestTest` creates static props from deterministic placement data.
- Tall props use ground-contact Y ordering.
- Tree collision shapes cover trunk/base only.

- [ ] **Step 1: Write failing layout test**

Assert deterministic layout data contains at least 18 trees, 8 bushes, 6 rocks, 2 logs and 6 flower patches. Assert tree collision radius/half-size is substantially narrower than the rendered canopy width.

- [ ] **Step 2: Verify RED**

Expected: layout APIs are absent.

- [ ] **Step 3: Implement forest builder**

Create a meadow-green base, dirt path polygons, darker/lighter ground patches and deterministic decoration placements. Build trees/rocks/logs as `StaticBody2D` nodes with Sprite2D art and compact collision bases. Put visual props and actors under Y-sorted parents.

- [ ] **Step 4: Add HUD guidance**

Display compact controls: `WASD/Setas mover • Espaço atacar` and prototype title. Keep HUD out of the world camera.

- [ ] **Step 5: Run tests and commit**

Expected stdout includes `FOREST_V1_LAYOUT_CONTRACT_PASS`.

```bash
git add scripts/forest_test.gd scenes/forest_test.tscn tests/test_forest_layout_contract.gd
git commit -m "feat: compose layered forest test map"
```

### Task 5: Add Slime and Boar behavior plus melee readability

**Files:**
- Create: `scripts/forest_monster.gd`
- Create: `tests/test_monster_contract.gd`
- Modify: `scripts/forest_test.gd`
- Modify: `scripts/player.gd`

**Interfaces:**
- Monster states: `IDLE`, `WANDER`, `CHASE`, `HURT`, `DEAD`.
- Monster configuration fields: `monster_kind`, `max_health`, `move_speed`, `detection_radius`, `home_radius`.
- Player attack checks a short directional area and calls `take_hit(damage: int, origin: Vector2)`.

- [ ] **Step 1: Write failing monster contract test**

Assert the five state constants exist, slime and boar configuration dictionaries are valid, and detection/home radii are positive.

- [ ] **Step 2: Verify RED**

Expected: FAIL because `forest_monster.gd` is absent.

- [ ] **Step 3: Implement monster state machine**

Use `CharacterBody2D`. Idle waits, wander selects deterministic/randomized nearby goals inside home radius, chase follows the player inside detection range, hurt briefly flashes/staggers, dead disables collision and fades.

- [ ] **Step 4: Spawn both archetypes**

Place at least two slimes and two boars around the clearing. Give each a small world-space health bar above its art.

- [ ] **Step 5: Connect melee pulse**

On player attack, inspect monsters in range and facing cone. Apply prototype damage and small knockback. No loot, XP or production combat features.

- [ ] **Step 6: Run tests and commit**

Expected stdout includes `FOREST_V1_MONSTER_CONTRACT_PASS`.

```bash
git add scripts/forest_monster.gd scripts/forest_test.gd scripts/player.gd tests/test_monster_contract.gd
git commit -m "feat: add Forest V1 monsters and combat probe"
```

### Task 6: Final visual polish, documentation and release gate

**Files:**
- Modify: `README.md`
- Modify: `scripts/forest_test.gd`
- Modify: `.github/workflows/forest-v1-headless.yml`

**Interfaces:**
- README gives exact GitHub Desktop + Godot opening steps.
- CI provides final marker `FOREST_VISUAL_PROTOTYPE_V1_PASS`.

- [ ] **Step 1: Add final smoke requirements**

CI boots `res://scenes/forest_test.tscn` headlessly after all contract tests and scans logs for targeted load/parse/script failures.

- [ ] **Step 2: Polish visual composition**

Tune camera zoom, ground detail density, path width, actor scale, shadow placement and prop ordering without adding new gameplay systems.

- [ ] **Step 3: Write README instructions**

Document controls, Godot 4.7.1 requirement, how to clone/open with GitHub Desktop, how to import `project.godot`, and how to run with F5.

- [ ] **Step 4: Run full verification**

Run all contract scripts and scene smoke boot. Expected final logs include all four contract PASS markers and `FOREST_VISUAL_PROTOTYPE_V1_PASS` with none of the forbidden error strings.

- [ ] **Step 5: Compare branch against main**

Verify only files belonging to the new standalone prototype were added/changed and that no reference to `PioneiroQuest` exists except the explicit prohibition in design documentation.

- [ ] **Step 6: Commit**

```bash
git add README.md scripts/forest_test.gd .github/workflows/forest-v1-headless.yml
git commit -m "docs: finalize Forest Visual Prototype V1"
```

## Self-Review

- Spec coverage: every acceptance criterion is assigned to Tasks 1–6.
- Placeholder scan: no implementation placeholders are used as requirements; every task identifies concrete files, behavior and test expectations.
- Type consistency: player direction indices, monster state names and scene node names remain identical across tasks.
- Scope: V1 remains a single visual forest prototype and intentionally excludes production RPG systems.
