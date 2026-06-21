// Sky.pde
// Background, atmosphere, and the disintegration wow-effect.
// Single responsibility: sky-colour interpolation, cloud/sun rendering,
// and managing the Particle burst when altitude threshold is crossed.
// Does NOT know about platforms, ground, or game-over state directly.

class Sky {

  // ════════════════════════════════════════════════════════════════════════
  // LO2 — THE TWO NUMBERS THAT DRIVE EVERY STATE TRANSITION IN THIS GAME:
  //
  //   1. baker.getY()   — read here in update() to compute sky colour and
  //                        to decide when to trigger disintegration.
  //   2. ground.groundY — read in Ground.hasCrushed() to decide when the
  //                        baker is crushed.
  //
  // Every visual change and every game-ending condition flows from exactly
  // these two scalars. No other persistent state is needed to determine
  // what happens next in the simulation.
  // ════════════════════════════════════════════════════════════════════════

  color skyColor;
  boolean disintegrating;       // true once the altitude threshold is crossed
  boolean disintegrationDone;   // true once all particles have faded out

  ArrayList<Particle> particles;

  // Cloud data — five clouds stored as parallel arrays.
  // Clouds scroll downward slowly (same visual direction as platforms) to
  // reinforce the sense of upward movement without requiring world coordinates.
  float[] cloudX = { 80,  320,  580,  180,  490 };
  float[] cloudY = { 110,  70,  150,  240,   55 };
  float[] cloudW = { 110, 145,   95,  125,  105 };

  // Sun position — fixed on screen, fades as sky darkens.
  final float SUN_X = 680;
  final float SUN_Y =  75;
  final float SUN_R =  48; // radius

  // Altitude threshold: baker.getY() at or below this value triggers
  // disintegration. 90 px from the top is clearly visible as a target.
  final float DISINTEGRATE_Y = 90;

  Sky() {
    skyColor           = color(75, 155, 215); // daytime blue
    disintegrating     = false;
    disintegrationDone = false;
    particles          = new ArrayList<Particle>();
  }

  // bakerY: the baker's current on-screen Y coordinate (from Baker.getY()).
  void update(float bakerY) {
    if (disintegrating) {
      // Advance all particles; remove expired ones.
      for (int i = particles.size() - 1; i >= 0; i--) {
        particles.get(i).update();
        if (particles.get(i).isDead()) particles.remove(i);
      }
      if (particles.size() == 0) disintegrationDone = true;
      return; // sky colour no longer changes after disintegration begins
    }

    // ── Smooth sky colour interpolation ──────────────────────────────────
    // map() converts baker's on-screen Y into a 0..1 blend factor:
    //   t = 0  when baker is at the bottom third of the canvas (full blue)
    //   t = 1  when baker is near the top (near-black)
    float t = map(bakerY, height * 0.80, DISINTEGRATE_Y + 30, 0.0, 1.0);
    t = constrain(t, 0.0, 1.0);
    skyColor = lerpColor(color(75, 155, 215), color(4, 4, 18), t);

    // ── Altitude threshold check (Death condition 2 — Disintegrated) ─────
    if (bakerY <= DISINTEGRATE_Y) {
      triggerDisintegration();
    }

    // ── Scroll clouds downward (same direction as platforms) ──────────────
    for (int i = 0; i < cloudY.length; i++) {
      cloudY[i] += 0.5;
      if (cloudY[i] > height + 70) {
        cloudY[i]  = -70;
        cloudX[i]  = random(50, width - 50);
        cloudW[i]  = random(85, 155);
      }
    }
  }

  // Spawns a burst of 150+ particles and marks disintegration as active.
  // Called exactly once when the baker crosses DISINTEGRATE_Y.
  void triggerDisintegration() {
    disintegrating = true;

    // General scatter: fragments from random screen positions (upper half)
    for (int i = 0; i < 110; i++) {
      float angle = random(TWO_PI);
      float speed = random(1.5, 8.0);
      float px    = random(width);
      float py    = random(height * 0.55);
      color c = color(random(180, 255), random(80, 220), random(0, 120), 240);
      particles.add(new Particle(px, py, cos(angle) * speed, sin(angle) * speed, c));
    }

    // Sun burst — extra bright yellow/orange particles radiating outward
    for (int i = 0; i < 50; i++) {
      float angle = random(TWO_PI);
      float speed = random(2.5, 13.0);
      color c = color(255, random(160, 255), random(0, 60), 255);
      particles.add(new Particle(SUN_X, SUN_Y,
                                 cos(angle) * speed, sin(angle) * speed, c));
    }

    // Cloud fragments — pale debris from cloud positions
    for (int i = 0; i < cloudX.length; i++) {
      for (int j = 0; j < 8; j++) {
        float angle = random(TWO_PI);
        float speed = random(1.0, 5.0);
        color c = color(240, 240, 255, 220);
        particles.add(new Particle(cloudX[i] + random(-20, 20),
                                   cloudY[i] + random(-10, 10),
                                   cos(angle) * speed, sin(angle) * speed, c));
      }
    }
  }

  void display() {
    // background() must be the first draw call each frame so everything
    // else renders on top of it.
    background(skyColor);

    if (!disintegrating) {
      drawSun();
      drawClouds();
    } else {
      // During disintegration, draw all live particles over the darkened sky.
      for (Particle p : particles) {
        p.display();
      }
    }
  }

  void drawSun() {
    // Outer glow — concentric transparent rings
    noStroke();
    for (float r = SUN_R * 2.6; r > SUN_R; r -= 6) {
      float alpha = map(r, SUN_R, SUN_R * 2.6, 90, 0);
      fill(255, 215, 50, alpha);
      ellipse(SUN_X, SUN_Y, r * 2, r * 2);
    }
    // Core disc
    fill(255, 235, 65);
    ellipse(SUN_X, SUN_Y, SUN_R * 2, SUN_R * 2);
  }

  void drawClouds() {
    fill(255, 255, 255, 215);
    noStroke();
    for (int i = 0; i < cloudX.length; i++) {
      drawCloud(cloudX[i], cloudY[i], cloudW[i]);
    }
  }

  // Draws one fluffy cloud using overlapping ellipses.
  void drawCloud(float cx, float cy, float w) {
    ellipse(cx,            cy,            w * 0.60, w * 0.40);
    ellipse(cx + w * 0.22, cy - w * 0.10, w * 0.55, w * 0.36);
    ellipse(cx - w * 0.22, cy + w * 0.06, w * 0.46, w * 0.30);
    ellipse(cx + w * 0.38, cy + w * 0.06, w * 0.38, w * 0.26);
  }

  // Resets all sky state for a new game.
  void reset() {
    skyColor           = color(75, 155, 215);
    disintegrating     = false;
    disintegrationDone = false;
    particles.clear();
    // Reset cloud positions to defaults
    float[] defaultY = { 110, 70, 150, 240, 55 };
    for (int i = 0; i < cloudY.length; i++) cloudY[i] = defaultY[i];
  }
}
