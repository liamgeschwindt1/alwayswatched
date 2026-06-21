# Challenge 1 — Computational Poster: Gold Standard Reference

> Internal reference solution for DBB100. Builds on a real student draft ("Always Watched") to demonstrate what moves a submission from Pass/Good into Excellent territory across every rubric category.

---

## 1. Starting Point (Student Draft)

**Concept:** "Always Watched" — 7 eyes drawn across a canvas in an unnatural yellow/purple palette, evoking surveillance.

**What the original code does:**
```java
int eyes_number = 7;

void draw_eyes(float x, float y){
  noStroke();
  fill(255,255,98);
  ellipse(x, y, 110, 85);
  fill(56, 56, 98);
  ellipse(x,y,48,48);
  fill(0);
  ellipse(x,y, 18,18);
  noFill();
  stroke(56, 56, 98);
  strokeWeight(4);
  arc(x,y-40, 95, 45, PI, TWO_PI);
}

void setup(){
  size(1000,500);
  noLoop();
}

void draw() {
  background(150, 155, 5);
  fill(255,255,98);
  textAlign(CENTER);
  textSize(45);
  text("always watched", width/2, 80);

  float spacing = width / 8;
  for (int i=0; i<eyes_number; i++){
    float x = (i+1) * spacing;
    float y =  250 + random(-45, 45);
    draw_eyes(x,y);
  }
}
```

### Diagnosis Against the Rubric

| Rubric Category | Issue | Why It Matters |
|---|---|---|
| **LO6 (Docs)** | README claims PDF export via `processing.pdf`, but the `.pde` has no `import processing.pdf.*;`, no `beginRecord()`/`endRecord()`. | **This is an automatic-fail risk.** "Output (PDF) does not match code" is an explicit zero-grade condition on this rubric. |
| **LO1 (Fundamentals)** | Only one scalar variable (`eyes_number`); zero arrays. | LO1 explicitly grades "effective arrays for pattern generation" — none exist here. |
| **LO2 (Computational Thinking)** | `noLoop()` is set, but the README claims the layout is "randomly drawn... each time the code is run" to show unpredictability. `noLoop()` means `draw()` executes exactly once per program run — the random values are fixed for that run, not varying *within* it. The logic doesn't fully support the stated concept. | Algorithmic claims in documentation must match actual runtime behavior. |
| **LO3 (Modularity)** | Only one function (`draw_eyes`). Functional, but doesn't demonstrate decomposition into smaller, purposeful units. | Excellent tier wants "well-designed functions" (plural) and clear separation of concerns. |
| **LO6 (Naming)** | `eyes_number` — snake_case, inconsistent with Java/Processing camelCase convention. | Minor but explicitly graded ("consistent, meaningful naming"). |
| **LO4 (Visual Design)** | Concept is coherent (color palette reinforces theme) but composition is static/evenly spaced — limited "wow-effect." | Excellent tier wants "surprising and non-trivial" results. |

**What's already good and should be preserved:** the clear conceptual hook (surveillance / "always watched"), the deliberate and *explained* color choices, and comments that justify creative decisions rather than just describing syntax. This is exactly the kind of reasoning Reflection 1 should also surface — keep this practice in the gold-standard version.

---

## 2. Improved Concept

**Keep:** the surveillance/"always watched" theme — it's strong and gives students a template for how a simple idea can carry a rubric.

**Evolve it with an algorithmic upgrade:** instead of 7 evenly-spaced identical eyes, generate a **variable-density field of eyes** whose size, rotation, and "alertness" (pupil dilation) are driven by a noise field — so the piece visibly demonstrates *computational thinking* (LO2) rather than just *repetition*. The unsettling effect of surveillance is heightened when the eyes don't behave uniformly — some are large and staring, some are small and distant, some glance sideways.

**Concept pitch:** *"Watchers"* — a field of eyes of varying size and gaze direction, distributed using Perlin noise so density and "attention" cluster unpredictably across the canvas, evoking the feeling of being watched from everywhere, unevenly, at once.

This single change lets the reference solution legitimately hit:
- **Arrays** — storing each eye's position, size, and gaze angle as a struct-like array of values
- **Noise-driven generative logic** — textbook LO2 ("creative use of loops... generative rules")
- **Multiple functions** — `drawEye()`, `drawPupil()`, `drawEyebrow()`, `generateEyeField()` decomposed cleanly
- **A real "wow-effect"** — asymmetry and unpredictability read as more unsettling than a uniform grid

---

## 3. Gold Standard Code (Improved Version)

```java
// ============================================================
// "Watchers" — Computational Poster (Challenge 1)
// DBB100 Creative Programming — Gold Standard Reference
// ============================================================
//
// CONCEPT:
// A field of eyes of varying size, position, and gaze direction,
// distributed using Perlin noise rather than a uniform grid.
// The goal is to make "being watched" feel uneven and unpredictable —
// some eyes loom large and close, others are small and distant,
// some glance sideways rather than staring straight ahead.
//
// WHY NOISE INSTEAD OF RANDOM:
// random() produces uncorrelated jitter — neighboring eyes would have
// no relationship to each other. noise() produces smooth, continuous
// variation, so nearby eyes share similar size/gaze tendencies, which
// reads visually as "clusters of attention" rather than static noise.
// This is the computational decision that drives the visual outcome
// (LO2: code logic directly produces visual output).

import processing.pdf.*;

// ---- Configuration ----
int numEyes = 45;
float[] eyeX = new float[numEyes];
float[] eyeY = new float[numEyes];
float[] eyeSize = new float[numEyes];
float[] gazeAngle = new float[numEyes];

boolean exportPDF = false; // toggled by keyPress 'p'

// ---- Setup ----
void setup() {
  size(1000, 700);
  noLoop(); // static composition — see note in generateEyeField()
  randomSeed(42);
  noiseSeed(42);
  generateEyeField();
}

// ---- Core generative logic ----
// Populates the eye arrays using Perlin noise fields rather than
// independent random values, so neighboring eyes vary smoothly.
void generateEyeField() {
  float noiseScale = 0.08;

  for (int i = 0; i < numEyes; i++) {
    // Distribute positions with light jitter so the field doesn't
    // look like a rigid grid, but noise still drives the *attributes*.
    eyeX[i] = random(60, width - 60);
    eyeY[i] = random(100, height - 60);

    // Sample independent noise fields for size and gaze so each
    // attribute clusters differently across the canvas.
    float sizeNoise = noise(eyeX[i] * noiseScale, eyeY[i] * noiseScale);
    float gazeNoise = noise(eyeX[i] * noiseScale + 500, eyeY[i] * noiseScale + 500);

    eyeSize[i] = map(sizeNoise, 0, 1, 35, 130);
    gazeAngle[i] = map(gazeNoise, 0, 1, -QUARTER_PI, QUARTER_PI);
  }
}

// ---- Drawing ----
void draw() {
  background(18, 18, 22);
  drawTitle();

  for (int i = 0; i < numEyes; i++) {
    drawEye(eyeX[i], eyeY[i], eyeSize[i], gazeAngle[i]);
  }

  if (exportPDF) {
    endRecord();
    exportPDF = false;
    println("Exported watchers.pdf");
  }
}

void drawTitle() {
  fill(235, 235, 90);
  textAlign(CENTER);
  textSize(38);
  text("watchers", width / 2, 60);
}

// Draws a single eye: sclera, iris, pupil, eyebrow.
// Decomposed into sub-functions so each visual element can be
// adjusted independently (LO3: modularity & reusability).
void drawEye(float x, float y, float sz, float gaze) {
  drawSclera(x, y, sz);
  drawIrisAndPupil(x, y, sz, gaze);
  drawEyebrow(x, y, sz);
}

void drawSclera(float x, float y, float sz) {
  noStroke();
  fill(255, 255, 98);
  ellipse(x, y, sz, sz * 0.65);
}

void drawIrisAndPupil(float x, float y, float sz, float gaze) {
  // Gaze angle offsets the iris/pupil within the sclera, so eyes
  // appear to look in different directions across the canvas.
  float offsetX = cos(gaze) * sz * 0.18;
  float offsetY = sin(gaze) * sz * 0.10;

  noStroke();
  fill(56, 56, 98);
  ellipse(x + offsetX, y + offsetY, sz * 0.45, sz * 0.45);

  fill(0);
  ellipse(x + offsetX, y + offsetY, sz * 0.18, sz * 0.18);
}

void drawEyebrow(float x, float y, float sz) {
  noFill();
  stroke(56, 56, 98);
  strokeWeight(max(2, sz * 0.04));
  arc(x, y - sz * 0.55, sz * 0.9, sz * 0.45, PI, TWO_PI);
}

// ---- PDF export ----
// Press 'p' to export the current composition as a vector PDF.
// Export is triggered by user interaction (per assignment spec:
// "the visuals are generated and stored in a PDF by pushing a
// button at a certain moment").
void keyPressed() {
  if (key == 'p' || key == 'P') {
    beginRecord(PDF, "watchers.pdf");
    exportPDF = true;
    redraw(); // forces one extra draw() call with recording active
  }
}
```

### What this version demonstrates, mapped to the rubric

- **LO1 (Fundamentals):** four parallel arrays (`eyeX`, `eyeY`, `eyeSize`, `gazeAngle`) directly drive pattern generation; `map()` and `noise()` used deliberately.
- **LO2 (Computational Thinking):** noise fields — not raw randomness — are the explicit algorithmic choice, and the code comments explain *why* (smooth clustering vs. uncorrelated jitter). The logic visibly produces the "uneven attention" effect described in the concept.
- **LO3 (Modularity):** `drawEye()` decomposes into `drawSclera()`, `drawIrisAndPupil()`, `drawEyebrow()` — each independently adjustable, DRY, clear separation from `generateEyeField()`.
- **LO6 (Docs & PDF):** PDF export is real, triggered by a keypress (matches the assignment's explicitly allowed pattern), and the code comment explains the mechanism — so README claims and code behavior will actually match.
- **LO4 (Visual Design):** noise-driven size/gaze variation produces genuine unpredictability and asymmetry, which is the "wow-effect" lever the original draft was missing.

### Known teaching point to flag for students
`noLoop()` + `keyPressed()` + `redraw()` is a slightly advanced pattern (forcing a single extra draw call with recording active). It's included here because it's the *correct* way to satisfy "export triggered by interaction," and it's worth walking through explicitly in class rather than assuming students will infer it — this is precisely where the original draft's claim/code mismatch happened.

---

## 4. Deliverables Checklist (for this reference folder)

- [ ] `watchers.pde` — source code above
- [ ] `watchers.pdf` — actual vector PDF generated by running the code and pressing `p`
- [ ] `README.md` — concept, approach, and run instructions (see template below)
- [ ] Folder named `INSTRUCTOR_REF_challenge1`

### README template to pair with this code

```markdown
# Watchers — Challenge 1 Reference Solution

**Concept:** A field of eyes varying in size and gaze direction, distributed
using Perlin noise so "attention" clusters unevenly across the canvas —
evoking the feeling of being watched unpredictably rather than uniformly.

**Approach:** Eye attributes (size, gaze angle) are sampled from independent
noise fields rather than random(), so neighboring eyes vary smoothly instead
of jittering independently. Drawing is decomposed into drawSclera(),
drawIrisAndPupil(), and drawEyebrow() for modularity.

**How to run:**
1. Open `watchers.pde` in Processing.
2. Press Run.
3. Press the `p` key to export the current composition as `watchers.pdf`
   (vector graphics, generated directly from the running sketch).
```