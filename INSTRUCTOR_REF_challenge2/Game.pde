// Game.pde
// Central coordinator — the only class that knows about all other classes.
// Single responsibility: owns all game objects, drives the update/display
// loop, spawns platforms, checks death conditions, shows game-over screen,
// and handles reset.
//
// setup() and draw() in the main .pde file are intentionally thin wrappers
// that call game.update() and game.display() exactly once per frame.

class Game {

  // ── Game objects ────────────────────────────────────────────────────────
  Baker              baker;
  ArrayList<Platform> platforms; // LO1: first array of objects
  Ground             ground;
  Sky                sky;        // sky owns ArrayList<Particle> — second array (LO1)

  // ── State ────────────────────────────────────────────────────────────────
  boolean gameOver;
  String  deathType; // "crushed" | "disintegrated" | "" (none yet)

  // ── World constants ──────────────────────────────────────────────────────
  // BASE_SCROLL: how many pixels per frame all world elements (platforms, clouds)
  // move downward. This creates the scrolling illusion of continuous upward movement
  // without ever moving the baker off-screen.
  final float BASE_SCROLL = 1.3;

  // Platform vertical gap: must be ≤ baker's maximum jump height (~144 px).
  // 80–110 px gives a comfortable but non-trivial challenge.
  final float MIN_GAP = 80;
  final float MAX_GAP = 110;

  // Minimum/maximum platform width
  final float MIN_W = 70;
  final float MAX_W = 160;

  Game() {
    setupGame();
  }

  // Initialises (or reinitialises) all game state. Called on first run and on reset.
  void setupGame() {
    baker     = new Baker(width / 2.0, height * 0.60);
    platforms = new ArrayList<Platform>();
    // Ground starts just off the bottom of the canvas and rises at a constant rate.
    ground    = new Ground(height + 10, 0.22);
    sky       = new Sky();
    gameOver  = false;
    deathType = "";

    // Seed enough initial platforms to fill the screen from bottom to above the top
    // so the baker is never immediately platformless at the start.
    float seedY = height * 0.70;
    for (int i = 0; i < 10; i++) {
      float pw  = random(MIN_W, MAX_W);
      float px  = random(20, width - pw - 20);
      platforms.add(new Platform(px, seedY - i * 100, pw));
    }

    // Place the baker on the first (lowest) seeded platform so they start grounded.
    Platform first = platforms.get(0);
    baker.y        = first.y - baker.H / 2;
    baker.onGround = true;
  }

  // ── Main update ──────────────────────────────────────────────────────────
  void update() {
    // Once disintegration particles have all faded, finalise the game-over state.
    if (sky.disintegrationDone && !gameOver) {
      gameOver  = true;
      deathType = "disintegrated";
      return;
    }

    if (gameOver) return;

    // During the disintegration animation, freeze all gameplay — the sky
    // continues updating its own particles independently.
    if (!sky.disintegrating) {

      // ── Scroll the baker with the world when grounded ─────────────────
      // If the baker is standing on a platform and the platform is about to
      // scroll down, the baker must move the same amount or they will drift
      // upward relative to the platform surface. We pre-apply the scroll
      // before baker.update() so physics and collision then happen in the
      // correct post-scroll frame. (Baker.onGround is still true here from
      // the previous frame's collision check — baker.update() will clear it.)
      if (baker.onGround) baker.y += BASE_SCROLL;

      // Apply baker physics and input (clears onGround internally)
      baker.update();

      // Check if baker has fallen off the bottom of the canvas
      if (baker.y > height + 60) {
        gameOver  = true;
        deathType = "crushed"; // fell into the rising ground below
        return;
      }

      // Re-establish ground contact via AABB collision with each platform.
      // Uses two distinct Platform arrays: platforms (ArrayList) and the baker's
      // onGround bool is set inside Baker. (LO1: two arrays — platforms + sky.particles)
      for (Platform p : platforms) {
        baker.checkPlatformCollision(p);
      }

      // Scroll all platforms downward; despawn any that have left the canvas.
      for (int i = platforms.size() - 1; i >= 0; i--) {
        platforms.get(i).update(BASE_SCROLL);
        if (platforms.get(i).isOffScreen()) platforms.remove(i);
      }

      // Keep platforms populated well above the top of the screen.
      spawnPlatformsIfNeeded();

      // Advance the rising ground (Death condition 1).
      ground.update();

      // ── Death condition 1 — Crushed ───────────────────────────────────
      if (ground.hasCrushed(baker)) {
        gameOver  = true;
        deathType = "crushed";
        return;
      }
    }

    // Sky update always runs — it needs baker.getY() for colour interpolation
    // AND it continues advancing disintegration particles even after gameplay freezes.
    sky.update(baker.getY());
  }

  // Spawns new platforms at the top of the canvas until there is always a
  // runway of platforms extending well above the visible area.
  void spawnPlatformsIfNeeded() {
    // Find the highest (lowest Y value) currently live platform.
    float highestY = height;
    for (Platform p : platforms) {
      if (p.y < highestY) highestY = p.y;
    }

    // Keep spawning until platforms extend 250 px above the top of the canvas.
    while (highestY > -250) {
      float gap = random(MIN_GAP, MAX_GAP);
      highestY -= gap;
      float pw = random(MIN_W, MAX_W);
      float px = random(20, width - pw - 20);
      platforms.add(new Platform(px, highestY, pw));
    }
  }

  // ── Main display ─────────────────────────────────────────────────────────
  void display() {
    // Sky calls background() first — everything else renders on top.
    sky.display();

    if (!sky.disintegrating) {
      // Draw platforms behind the baker.
      for (Platform p : platforms) p.display();

      // Baker sits above the platforms.
      baker.display();

      // Ground overlaps everything it has risen past.
      ground.display();

      // Heads-up display elements (altitude bar, ground warning).
      drawHUD();
    } else {
      // During disintegration: ground is still visible for dramatic effect.
      ground.display();
    }

    // Game-over overlay is drawn last so it sits above everything.
    if (gameOver) drawGameOver();
  }

  // ── HUD ─────────────────────────────────────────────────────────────────
  void drawHUD() {
    if (gameOver) return;

    int   barH = 180;
    int   barX = width - 26;
    int   barTop = height / 2 - barH / 2;

    // Altitude bar — shows baker's current on-screen height as a fraction.
    float altFraction = map(baker.getY(), height * 0.85, sky.DISINTEGRATE_Y + 20, 0, 1);
    altFraction = constrain(altFraction, 0, 1);

    // Track background
    fill(0, 0, 0, 70);
    noStroke();
    rect(barX, barTop, 14, barH, 7);

    // Fill level
    color barLow  = color(80, 210, 80);
    color barHigh = color(210, 60, 60);
    fill(lerpColor(barLow, barHigh, altFraction));
    float fillH = barH * altFraction;
    rect(barX, barTop + barH - fillH, 14, fillH, 7);

    // Label
    fill(255, 255, 255, 170);
    textSize(10);
    textAlign(CENTER);
    text("ALT", barX + 7, barTop - 7);

    // Ground proximity warning (appears when ground is within 220 px)
    float dist = ground.groundY - (baker.y + baker.H / 2);
    if (dist < 220) {
      float alpha = map(dist, 0, 220, 230, 40);
      fill(255, 50, 50, alpha);
      textSize(15);
      textAlign(CENTER);
      text("GROUND RISING!", width / 2, height - 18);
    }
  }

  // ── Game-over overlay ────────────────────────────────────────────────────
  void drawGameOver() {
    // Semi-transparent dim
    fill(0, 0, 0, 165);
    noStroke();
    rect(0, 0, width, height);

    textAlign(CENTER, CENTER);

    if (deathType.equals("crushed")) {
      fill(195, 55, 55);
      textSize(52);
      text("CRUSHED", width / 2, height / 2 - 65);
      fill(220, 215, 215);
      textSize(19);
      text("The ground caught up.", width / 2, height / 2 - 10);

    } else if (deathType.equals("disintegrated")) {
      fill(255, 205, 50);
      textSize(46);
      text("DISINTEGRATED", width / 2, height / 2 - 65);
      fill(220, 215, 215);
      textSize(19);
      text("The sky consumed the baker.", width / 2, height / 2 - 10);
    }

    fill(195, 195, 195);
    textSize(16);
    text("Press R to try again", width / 2, height / 2 + 38);

    fill(140, 140, 140);
    textSize(12);
    text("There is no winning. Only how it ends.", width / 2, height / 2 + 68);
  }

  // ── Reset ────────────────────────────────────────────────────────────────
  void reset() {
    sky.reset();
    setupGame();
  }
}
