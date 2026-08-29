# Asset Licenses — Forest Prototype

This file is the source of truth for art provenance in this repository.

## V1 assets

All files under `assets/art/` are **project-original prototype artwork** created specifically for `PioneiroForestPrototype`. They were not copied from PIONEIRO QUEST and do not contain third-party artwork.

## V2 assets

All files under `assets/art_v2/` are **project-original pixel-art prototype assets** created specifically for the Forest Visual Prototype V2. They were drawn as new raster assets for this repository and are not extracted from third-party preview images or paid/free asset archives.

The V2 art direction was informed by references supplied during design review, including ToffeeCraft's Forest Nature Pack, OboroPixel's Characters Animations Asset Pack, KayKit Fantasy Weapons Bits, and other top-down RPG references. Those third-party packs are **not redistributed in this repository**.

### Why the external packs are not committed yet

- ToffeeCraft's free Forest Nature Pack license allows game use but says not to redistribute/resell the assets; committing raw files to a public Git repository would itself redistribute them.
- OboroPixel likewise allows game use/modification but prohibits redistribution/resale of the asset files.
- KayKit Fantasy Weapons Bits is CC0 and can be used later, but its 3D weapons are not needed for this forest visual proof.

If we later use a third-party pack in production, we will either keep it outside the public source repository, obtain the appropriate license/permission, or use a CC0 source that can safely be committed.

## Rule for future external assets

Before an external asset is integrated, record the package name, author, source URL, exact license, files used and modifications. Prefer CC0/public-domain material when the raw asset must live in a public repository.
