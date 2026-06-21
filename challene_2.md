# Challenge 2 — Interactive Application: Gold Standard Reference

> Implementation handoff spec for coding agent. This is NOT prose to summarize — it is a build spec. Implement exactly what is specified below, ask nothing, and flag deviations explicitly in code comments if a spec item turns out to be technically infeasible as written.

---

## 0. Context

This is a reference/model solution for a course assignment (DBB100 – Creative Programming, Challenge 2: Interactive Application, 50% of grade). It will be shown to students as an example of a gold-standard submission. It must satisfy the grading rubric below in full, including the rubric's hard automatic-fail gate. Code quality, comments, and structure matter as much as the final visual/interactive result — this is a teaching artifact, not just a working game.

---

## 1. Rubric Requirements (must all be satisfied)

**Platform:** Processing (Java mode), no external libraries, no gamepad/joystick hardware. Keyboard input only.

**Hard gate — automatic fail if violated:**
- Code must run without errors.
- **OOP must be used.** No classes = automatic fail. (This build uses 6 classes — see Section 3.)
- Output must match what the code actually does (no claims in README/comments that aren't true of the running code).
- No plagiarism; credit any external reference if one is ever added (none are used in this spec).

**Graded categories to satisfy:**
- **LO1 (Programming Fundamentals):** advanced/correct use of variables, loops, functions, **arrays** (plural array usage required — this spec uses two distinct arrays of objects).
- **LO2 (Computational Thinking):** clear algorithmic strategy where code logic visibly drives visual/interactive output. Two scalar values (baker's y-position, ground's y-position) should be the actual drivers of all major state transitions — this must be legible in code structure and comments, not just functional.
- **LO3 (Modularity & Scalability) — OOP required, gating category:** clean class separation, single responsibility per class, no duplicated logic, scalable structure (e.g. adding a new platform type or particle behavior should not require rewriting unrelated classes).
- **LO5 (I/O & Data Integration):** keyboard input handling (arrow keys + spacebar) implemented cleanly via Processing's `keyPressed`/`keyReleased`/boolean-state pattern (not single-shot `keyPressed()` checks for continuous movement, which causes jittery input — explain this choice in a comment).
- **LO6 (Documentation & Best Practices):** exemplary comments explaining *why*, not just *what*; consistent camelCase naming; clean file structure; a README that accurately describes setup/run instructions and concept.
- **LO4 (Interactivity & Visual Design, weighted heaviest at 20%):** responsive, intuitive controls; cohesive visual theme; a genuine "wow-effect" moment (the disintegration sequence is the intended wow-effect — it must look deliberate and polished, not janky).
- **LO7 (p5.js web bonus):** NOT in scope for this build. Skip entirely.

**Deliverables to produce:**
1. `baker.pde` (or split into multiple `.pde` tabs within the same sketch folder if cleaner — agent's discretion, but document the file layout in the README)
2. A short MP4-equivalent is NOT required from the agent — leave a placeholder note in the README that a demo video must be recorded by a human and added before final submission. Do not attempt to generate video.
3. `README.md` — concept, approach, controls, how to run, file structure
4. Folder name: `INSTRUCTOR_REF_challenge2`

---

## 2. Concept

**Title:** *Floating Bakery* (working title — agent may suggest alternatives in README "notes" section, but do not change without flagging)

**Theme:** Mario-Bros/Flappy-Bird-style side-on platformer aesthetic — grass ground texture, clouds, sunshine, bright primary-color palette.

**Character:** A human baker. Holds a rolling pin in one hand at all times (purely cosmetic — no interaction logic tied to the rolling pin itself; it is a visual prop only).

**Core narrative/mechanic:**
- The baker is perpetually climbing upward, jumping between **static horizontal baguette platforms**.
- **There is no win state.** The only variability is *how* the baker's run ends. This is intentional thematic design — frame this clearly in the README's concept section (something like: "the only choice is which way it ends — climb until the sky consumes you, or stop and let the ground catch up").
- **Death condition 1 — Crushed:** the ground continuously rises from the bottom of the screen over time, at a constant rate, independent of player action. If the rising ground's leading edge reaches the baker's current y-position, the baker is crushed and the game ends. This creates constant pressure to keep climbing — standing still is not a safe option.
- **Death condition 2 — Disintegration:** as the baker climbs, their **screen y-position** (not cumulative distance — must be based on current on-screen position, this is a deliberate simplification, do not implement cumulative-distance tracking) determines the sky color, interpolating smoothly from blue (low altitude / low on screen) to black (high altitude / near top of screen). Donuts may visually exist as a thematic/collectible decoration (optional — agent's discretion whether to implement collection logic; if implemented, donuts have no effect on win/lose state, purely score/flavor). Once the baker's y-position crosses a defined threshold near the top of the canvas, trigger the disintegration sequence: the sky and visible UI elements burst apart into particles that fly outward and fade, ending the game shortly after.

**Controls:**
- Left/Right arrow keys: move baker horizontally
- Spacebar: jump (must use proper physics — velocity + gravity + ground/platform collision, not a teleport-style jump)

**Visual world:**
- Side-scrolling: the baker should remain roughly fixed in the vertical middle-to-lower-middle of the screen; baguette platforms, clouds, and the rising ground all scroll downward relative to the baker as they climb, to create the illusion of continuous upward movement without literally moving the baker to the top of the screen.
- Daytime platformer palette: grass-green ground, blue sky (until it darkens), white clouds, a sun.

---

## 3. Required Class Structure (OOP — this satisfies the rubric's gating LO3 requirement)

Implement exactly these six classes. Each must have a single clear responsibility. Do not merge classes for convenience — the separation itself is part of what's being modeled for students.

### `Baker`
- Fields: x, y position; horizontal/vertical velocity; on-ground/jumping state; reference to rolling pin visual (can just be drawn inline in this class's `display()` method — no separate class needed for the rolling pin).
- Methods: `update()` (applies gravity, handles horizontal movement from input state, handles jump trigger), `display()` (draws baker sprite + rolling pin), `checkPlatformCollision(Platform p)`, `getY()` (used by `Sky` and `Ground` to check death conditions).
- Comment requirement: explain the gravity/jump physics constants chosen and why (e.g. why this jump height feels right relative to platform spacing).

### `Platform`
- Fields: x, y position; width.
- Methods: `update(float scrollSpeed)` (moves down each frame), `display()`, `isOffScreen()` (for despawning), collision-check helper used by `Baker`.
- Comment requirement: explain how platform spawn spacing relates to the baker's jump arc (so platforms are always reachable).

### `Ground`
- Fields: current y-position of the rising ground's top edge; rise speed.
- Methods: `update()` (rises over time), `display()`, `hasCrushed(Baker b)` (returns true if ground has reached baker's y).
- Comment requirement: explain why rise speed is constant rather than accelerating (deliberate simplicity choice for this reference — note that accelerating difficulty would be a reasonable student extension).

### `Sky`
- Fields: current background color (interpolated); disintegration-triggered boolean; reference to the particle system (an array/ArrayList of `Particle`).
- Methods: `update(float bakerY)` (computes blue→black interpolation based on baker's y-position, checks altitude threshold, triggers particle burst when crossed), `display()` (draws background gradient/color, draws clouds and sun while intact, draws particles once disintegration has triggered).
- Comment requirement: explicitly comment the two scalar values (baker's y, ground's y) as "the two numbers that drive every state transition in this game" — this is the LO2 algorithmic-clarity requirement, make it visible in the code itself, not just in this spec.

### `Particle`
- Fields: x, y; velocity x, y; lifespan/alpha; color.
- Methods: `update()` (moves, decrements lifespan/fades), `display()`, `isDead()` (lifespan expired).
- Used in an array/ArrayList instantiated by `Sky` when disintegration triggers (e.g. 80–150 particles flying outward from screen center or from cloud/sun positions).

### `Game`
- Fields: one `Baker` instance; `ArrayList<Platform>`; one `Ground`; one `Sky`; game-over boolean; which-death-occurred enum or string ("crushed" / "disintegrated").
- Methods: `update()` (calls update on all sub-objects in correct order, spawns new platforms as old ones scroll off, checks both death conditions, sets game-over state), `display()` (calls display on all sub-objects, shows a game-over screen with which death occurred when applicable), `reset()` (restart logic).
- This is the only class that should contain the main `draw()` loop's logic — `setup()`/`draw()` at the top level should be thin wrappers that just call into a single `Game` instance.

---

## 4. Implementation Notes / Constraints

- **No external libraries.** Pure Processing core only.
- **Continuous keyboard input:** use boolean flags set in `keyPressed()`/`keyReleased()` (e.g. `leftPressed`, `rightPressed`) checked every frame in `Baker.update()`, NOT single-event `keyPressed()` movement — this avoids jittery/unresponsive movement and is worth a comment explaining the choice, since it's a common beginner mistake this reference should model correctly.
- **Collision detection** can be simple AABB (axis-aligned bounding box) checks — no physics library needed.
- **Scrolling illusion:** achieved by moving platforms/ground/clouds downward each frame relative to a vertically-anchored baker, not by moving the baker upward off-screen.
- **Naming convention:** camelCase throughout (`bakerY`, `risingSpeed`, etc.) — flag and fix if anything slips into snake_case.
- **No PDF export needed for this challenge** (that's a Challenge 1 requirement only — do not add it here).
- **Do not implement a win condition.** This is deliberate. If you find yourself adding scoring/win logic, stop — re-read Section 2.

---

## 5. README.md Requirements

The README the agent produces alongside the code must include:
1. **Concept** — one paragraph framing the "no win, only how it ends" theme.
2. **Controls** — arrow keys to move, spacebar to jump.
3. **How to run** — open in Processing, press Run.
4. **File structure** — list of `.pde` tabs/files and what each contains.
5. **Note for instructor:** explicit placeholder line: *"Demo video (MP4) to be recorded separately and added before this is used as a student-facing example."*
6. Do not claim any feature in the README that isn't actually implemented in the code (this mirrors the exact mistake flagged in the Challenge 1 reference — do not repeat it here).

---

## 6. Definition of Done

- [ ] All six classes implemented with single responsibilities as specified
- [ ] Game runs, baker can move/jump, platforms scroll, ground rises, sky darkens, disintegration triggers and ends the game
- [ ] Both death conditions are reachable and distinguishable on a game-over screen
- [ ] No win state exists anywhere in the code
- [ ] Comments explain *why* for the key decisions flagged above (gravity constants, platform spacing, constant vs. accelerating ground speed, the "two numbers drive everything" framing, continuous-input pattern)
- [ ] README accurately reflects what the code does, nothing more
- [ ] Folder named `INSTRUCTOR_REF_challenge2`, files named consistently within it