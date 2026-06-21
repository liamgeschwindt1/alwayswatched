// INSTRUCTOR_REF_challenge2.pde
// DBB100 – Creative Programming | Challenge 2: Interactive Application
// Instructor reference / gold-standard example
//
// Entry point only. All game logic lives in Game.pde.
// This file is intentionally thin — its only job is to wire Processing's
// lifecycle callbacks into the single Game instance.
//
// File layout (each class has its own tab/file):
//   INSTRUCTOR_REF_challenge2.pde  — setup(), draw(), input callbacks (this file)
//   Baker.pde    — player character: physics, input response, display
//   Platform.pde — baguette platform: scrolling, display, collision surface
//   Ground.pde   — rising ground: constant upward movement, crush-check
//   Sky.pde      — background, atmosphere, disintegration particle trigger
//   Particle.pde — single disintegration fragment: motion, fade, expiry
//   Game.pde     — central coordinator: owns all objects, drives the loop

Game game;

// ─── Continuous-input boolean flags ────────────────────────────────────────
// WHY booleans instead of checking keyCode inside keyPressed()?
// Processing fires keyPressed() as a single event per key-event, not every
// frame. If movement were driven by that callback, the baker would lurch one
// step per keypress — classic beginner jitter. Instead we set a flag on press,
// clear it on release, and read it every frame inside Baker.update() for
// smooth, responsive movement. (LO5 — documented pattern)
boolean leftPressed  = false;
boolean rightPressed = false;
boolean spacePressed = false;

void setup() {
  size(800, 600);
  frameRate(60);
  game = new Game();
}

void draw() {
  game.update();
  game.display();
}

void keyPressed() {
  if (keyCode == LEFT)  leftPressed  = true;
  if (keyCode == RIGHT) rightPressed = true;
  if (key    == ' ')    spacePressed = true;
  if (key == 'r' || key == 'R') game.reset();
}

void keyReleased() {
  if (keyCode == LEFT)  leftPressed  = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (key    == ' ')    spacePressed = false;
}
