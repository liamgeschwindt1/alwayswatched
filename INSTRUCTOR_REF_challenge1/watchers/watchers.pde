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
    exit();
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
