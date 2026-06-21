// Headless PDF export version — renders directly to PDF without a display.
// Uses the PDF renderer as the primary renderer so no window is needed.

import processing.pdf.*;

int numEyes = 45;
float[] eyeX = new float[numEyes];
float[] eyeY = new float[numEyes];
float[] eyeSize = new float[numEyes];
float[] gazeAngle = new float[numEyes];

void setup() {
  size(1000, 700, PDF, "watchers.pdf");
  randomSeed(42);
  noiseSeed(42);
  generateEyeField();

  background(18, 18, 22);
  drawTitle();
  for (int i = 0; i < numEyes; i++) {
    drawEye(eyeX[i], eyeY[i], eyeSize[i], gazeAngle[i]);
  }

  println("Exported watchers.pdf");
  exit();
}

void draw() {}

void generateEyeField() {
  float noiseScale = 0.08;
  for (int i = 0; i < numEyes; i++) {
    eyeX[i] = random(60, width - 60);
    eyeY[i] = random(100, height - 60);
    float sizeNoise = noise(eyeX[i] * noiseScale, eyeY[i] * noiseScale);
    float gazeNoise = noise(eyeX[i] * noiseScale + 500, eyeY[i] * noiseScale + 500);
    eyeSize[i] = map(sizeNoise, 0, 1, 35, 130);
    gazeAngle[i] = map(gazeNoise, 0, 1, -QUARTER_PI, QUARTER_PI);
  }
}

void drawTitle() {
  fill(235, 235, 90);
  textAlign(CENTER);
  textSize(38);
  text("watchers", width / 2, 60);
}

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
