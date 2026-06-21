# Floating Bakery

**Course:** DBB100 – Creative Programming
**Challenge:** Challenge 2 — Interactive Application (50% of grade)
**Status:** Instructor Reference / Gold-Standard Example

---

## Concept

*Floating Bakery* is a side-on platformer in which a baker leaps endlessly between baguette platforms that drift perpetually downward from an infinite sky. There is no winning — no score to reach, no exit to find, no safe moment to stop. The only variability is *how* the run ends: climb urgently enough and the altitude itself will consume you, the sky splitting apart in a particle burst that swallows the world; dawdle long enough and the rising ground will swallow you from below. Every jump is only ever a choice about which ending to reach, and how long it takes.

---

## Controls

| Key | Action |
|-----|--------|
| ← Left Arrow | Move baker left |
| → Right Arrow | Move baker right |
| Spacebar | Jump (physics-based — hold does not extend height) |
| R | Restart after game over |

---

## How to Run

1. Download and install [Processing 4](https://processing.org/download) (Java mode — the default).
2. Open the `INSTRUCTOR_REF_challenge2` folder in Processing:
   **File → Open** → navigate to the folder → select `INSTRUCTOR_REF_challenge2.pde`.
3. Press the **Run** button (▶) or use **Ctrl+R** / **Cmd+R**.
4. No external libraries are required. Pure Processing core only.

---

## File Structure

| File | Contents |
|------|----------|
| `INSTRUCTOR_REF_challenge2.pde` | Entry point: `setup()`, `draw()`, `keyPressed()`, `keyReleased()`. Thin wrappers only — all logic lives in `Game`. Declares the three global boolean input flags (`leftPressed`, `rightPressed`, `spacePressed`). |
| `Baker.pde` | Player character class. Fields: position, velocity, `onGround`. Methods: `update()` (physics + continuous input), `display()` (baker sprite + rolling pin), `checkPlatformCollision()` (AABB), `getY()`. |
| `Platform.pde` | Single baguette platform class. Fields: position, width. Methods: `update(scrollSpeed)` (scrolls downward), `display()` (baguette visual), `isOffScreen()`. |
| `Ground.pde` | Rising ground class. Fields: `groundY`, `riseSpeed`. Methods: `update()` (constant upward movement), `display()` (grass/soil layers, danger flash), `hasCrushed(Baker)`. |
| `Sky.pde` | Background and atmosphere class. Fields: `skyColor`, `disintegrating`, `disintegrationDone`, `ArrayList<Particle> particles`, cloud/sun data. Methods: `update(bakerY)` (colour interpolation, threshold check, cloud scroll), `display()`, `triggerDisintegration()`, `reset()`. |
| `Particle.pde` | Single disintegration fragment class. Fields: position, velocity, lifespan, colour, size. Methods: `update()` (motion + fade), `display()`, `isDead()`. |
| `Game.pde` | Central coordinator. Owns one `Baker`, `ArrayList<Platform>`, one `Ground`, one `Sky`. Methods: `update()` (drives everything per frame), `display()` (renders in correct z-order), `spawnPlatformsIfNeeded()`, `drawHUD()`, `drawGameOver()`, `reset()`. |

---

## Death Conditions

**Crushed** — the ground rises from below at a constant rate throughout the entire run. If its leading edge reaches the baker's feet, the run ends. Standing still is never safe: even without jumping, the world scrolls downward and the ground climbs upward.

**Disintegrated** — as the baker climbs higher on screen (lower Y value), the sky interpolates from daytime blue to deep black. Once the baker's on-screen Y position crosses the altitude threshold near the top of the canvas, the sky and scene burst apart in an expanding particle explosion. The game ends when the last particle fades.

---

## Design Notes

**No win state.** There is no score target, no level end, no successful ending. This is intentional — see the Concept section. No winning logic exists anywhere in the code.

**Constant ground speed.** The ground rises at a flat rate rather than accelerating. This makes the pressure predictable and legible — the simplest correct version. Accelerating difficulty (multiply riseSpeed by a factor slightly above 1 each frame) would be a natural student extension.

**Continuous input pattern.** Movement uses boolean flags (`leftPressed`, `rightPressed`) read every frame in `Baker.update()`, not a per-event `keyCode` check in `keyPressed()`. This eliminates the jittery one-step-per-keypress behaviour that is a common beginner mistake. The choice is documented in comments in both `INSTRUCTOR_REF_challenge2.pde` and `Baker.pde`.

**The two numbers that drive everything.** `baker.getY()` and `ground.groundY` are the only two scalar values needed to determine every major game-state transition. This is called out explicitly in `Sky.pde` and `Ground.pde` comments to satisfy the LO2 algorithmic-clarity requirement.

**Two distinct arrays of objects.** `ArrayList<Platform> platforms` (owned by `Game`) and `ArrayList<Particle> particles` (owned by `Sky`) satisfy the LO1 plural-array requirement.

**Scrolling illusion.** The baker moves in screen space. Platforms, clouds, and the ground scroll downward each frame. The baker rises on-screen by actively jumping to platforms that have not yet scrolled past. No camera or world-coordinate transform is involved.

---

## Notes

> **Working title:** *Floating Bakery*. If an alternative title is preferred for student-facing materials, update this README and the game-over screen text in `Game.pde → drawGameOver()`.

> **Demo video (MP4):** to be recorded separately and added before this is used as a student-facing example. The recording should include at least one run reaching the **Crushed** ending and one reaching the **Disintegrated** ending.
