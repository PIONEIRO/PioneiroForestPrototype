# Forest Visual Prototype V1 — Design

## Goal

Create a brand-new Godot 4.7.1 prototype, completely separate from PIONEIRO QUEST, whose only purpose is to validate the visual direction of a 2D top-down 3/4 forest scene with a player and two forest monsters.

## Scope

The prototype contains one playable scene, `ForestTest`, with:

- a compact forest clearing connected by a dirt path;
- dense trees, shrubs, rocks, flowers, logs and grass accents;
- depth ordering so actors can walk in front of and behind tall scenery;
- collision concentrated at trunks and solid bases instead of the full canopy;
- one player actor with 8-direction movement;
- two forest monsters with idle/wander/chase behavior;
- a very small attack interaction for readability testing;
- simple health bars and debug information only when useful for the prototype;
- camera follow and framing tuned for a top-down 3/4 illustrated look.

No inventory, equipment, quests, classes, towns, persistence, networking, login, economy or production gameplay systems belong in V1.

## Visual Direction

The visual target is an illustrated 2D top-down 3/4 game, not classic low-resolution pixel art and not real-time 3D. Characters and monsters must read at a comfortable size on a 1280x720 viewport. Forest props should have visible volume, layered foliage, grounded shadows and clear silhouettes.

For this first prototype, the repository will use original vector/SVG prototype art created specifically for the test. This avoids dependency on binary asset uploads and keeps licensing unambiguous. External CC0/free packs may replace or supplement these assets in later visual iterations once their exact license and source are recorded.

## Technical Architecture

- Engine: Godot 4.7.1.
- Renderer: GL Compatibility for broad Windows support.
- Main scene: `scenes/forest_test.tscn`.
- World controller: `scripts/forest_test.gd`.
- Player controller: `scripts/player.gd`.
- Monster controller: `scripts/forest_monster.gd`.
- Reusable actor art: SVG textures under `assets/art/`.
- Tall props use Y-sorting / Z ordering based on ground contact.
- Character collision remains independent from the visual artwork.
- Project resolution: 1280x720 with viewport stretching.

## Player

The player moves with WASD or arrow keys in 8 directions. Diagonal movement is normalized. The player keeps facing the last non-zero movement direction. A small visual walk bob may be used, but collision position must remain stable.

Attack is intentionally minimal: Space triggers a short melee pulse in the current facing direction. It exists only so the user can judge player/monster scale, visual overlap and combat readability.

## Monsters

V1 contains two monster archetypes:

1. Forest Slime — small, bright, soft silhouette.
2. Forest Boar — larger, darker, heavier silhouette.

Each monster idles, wanders inside a limited home radius and chases the player when close enough. When hit, it briefly flashes and loses health. When health reaches zero it disappears after a short delay. This is prototype behavior, not a production combat system.

## Forest Composition

The scene uses a hand-authored arrangement rather than a generated world. The purpose is visual control. The composition contains:

- large oak/pine style trees around the perimeter and in internal clusters;
- a readable central path and clearing;
- rocks and logs to break repetition;
- bushes, flowers and grass marks as secondary detail;
- subtle ground patches to avoid a flat single-color field;
- soft oval shadows at actor and prop bases.

The camera must allow enough room around the player to appreciate forest density without making the character tiny.

## Asset Policy

`ASSET_LICENSES.md` is the source of truth for asset provenance. V1 original SVG art is marked as project-original. Any future third-party asset must record:

- asset/package name;
- author;
- source URL;
- exact license;
- files used;
- modifications made.

No external asset may be committed before its license is verified as compatible with use in the game.

## Testing

Automated headless tests verify:

- the project parses under Godot 4.7.1;
- the main scene loads;
- the player direction helper maps all 8 canonical directions;
- diagonal movement stays normalized;
- monsters expose the required prototype states;
- key scene nodes exist.

A GitHub Actions workflow runs these checks on the prototype branch and on pull requests.

## Acceptance Criteria

The V1 prototype is ready for user visual review when:

- F5 opens directly into the forest scene;
- the player moves smoothly in 8 directions;
- the camera follows correctly;
- trees visibly layer in front of/behind the player based on ground position;
- trunk collisions feel natural;
- at least one slime and one boar are visible and animated enough to read as living monsters;
- monsters wander and chase;
- Space can hit nearby monsters;
- the scene contains enough vegetation and environmental detail to evaluate the art direction;
- the old PIONEIRO QUEST repository is never read from, copied from, or modified by this implementation.
