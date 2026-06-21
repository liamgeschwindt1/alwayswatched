// Baker.pde
// Represents the player character — a baker who always carries a rolling pin.
// Single responsibility: position, physics, input response, platform collision.
// Does NOT know about the sky, ground, game-over state, or scroll speed.

class Baker {

  float x, y;   // centre of the baker's bounding box (screen coordinates)
  float vx, vy; // current velocity (pixels per frame)
  boolean onGround; // true when standing on a platform surface this frame

  // ── Hitbox dimensions ──────────────────────────────────────────────────
  final float W = 28; // half-width: baker spans x±14
  final float H = 40; // full height: feet at y + H/2, head at y - H/2

  // ── Physics constants ──────────────────────────────────────────────────
  // GRAVITY: 0.5 px/frame² — feels floaty-but-controlled for a platformer.
  //   Higher (e.g. 1.0) makes the baker feel heavy and snappy; lower feels
  //   weightless. 0.5 gives about 24 frames of air time per jump, matching
  //   the platform scroll rhythm.
  //
  // JUMP_VEL: −12 px/frame. Maximum height = v² / (2g) = 144 / 1.0 = 144 px.
  //   Platforms are spaced 80–110 px apart vertically (see Platform.pde),
  //   so the baker can always reach the next one — even from the far edge of
  //   a platform, because horizontal reach during a 144-px arc is generous.
  //
  // MOVE_SPEED: 4 px/frame gives snappy left/right without being uncontrollable.
  final float GRAVITY    = 0.5;
  final float JUMP_VEL   = -12.0;
  final float MOVE_SPEED = 4.0;

  Baker(float startX, float startY) {
    x  = startX;
    y  = startY;
    vx = 0;
    vy = 0;
    onGround = false;
  }

  // Called once per frame by Game before collision checks.
  // Reads the global boolean input flags (set in the main .pde file).
  void update() {
    // ── Horizontal movement (continuous-input pattern — see main .pde) ──
    vx = 0;
    if (leftPressed)  vx = -MOVE_SPEED;
    if (rightPressed) vx =  MOVE_SPEED;

    // ── Jump: only fires when grounded; onGround is reset to false at end ─
    if (spacePressed && onGround) {
      vy = JUMP_VEL;
      onGround = false; // immediately airborne so jump can't re-fire this frame
    }

    // ── Gravity accumulates downward pull every frame ──────────────────
    vy += GRAVITY;

    x += vx;
    y += vy;

    // ── Horizontal screen-wrap (walk off one edge, appear on the other) ─
    if (x < -W / 2)        x = width  + W / 2;
    if (x > width + W / 2) x = -W / 2;

    // ── Terminal velocity: cap fall speed so fast drops don't tunnel ────
    vy = constrain(vy, -20, 15);

    // onGround is cleared here every frame.
    // Game.update() calls checkPlatformCollision() afterwards;
    // that method re-sets onGround=true if the baker is still on a surface.
    onGround = false;
  }

  // AABB platform landing check.
  // Uses a proximity threshold rather than a strict "crossed the top" test
  // so the baker reliably stays on platforms that are themselves scrolling.
  // vy >= 0 guard prevents snapping when jumping upward through a platform.
  void checkPlatformCollision(Platform p) {
    float feetY = y + H / 2;

    boolean withinX   = (x + W / 2 > p.x) && (x - W / 2 < p.x + p.w);
    boolean nearTop   = (feetY >= p.y) && (feetY <= p.y + 18);
    boolean descending = (vy >= 0);

    if (withinX && nearTop && descending) {
      y        = p.y - H / 2; // snap feet to platform surface
      vy       = 0;
      onGround = true;
    }
  }

  // ─── LO2 — one of THE TWO SCALARS that drive every state transition ────
  // baker.getY() is read by Sky.update() to compute sky colour and trigger
  // disintegration, and by Ground.hasCrushed() to detect the crush death.
  // See Sky.pde for the explicit call-out comment on both scalars.
  float getY() {
    return y;
  }

  // Draws the baker sprite + rolling pin (rolling pin is purely cosmetic —
  // it has no collision logic or gameplay effect).
  void display() {
    pushMatrix();
    translate(x, y);

    noStroke();

    // ── Chef hat ─────────────────────────────────────────────────────────
    fill(255);
    rect(-9, -H / 2 - 16, 18, 12, 2); // brim
    rect(-6, -H / 2 - 28, 12, 14, 2); // tall crown

    // ── Head ─────────────────────────────────────────────────────────────
    fill(255, 215, 170);
    ellipse(0, -H / 2 + 4, 22, 22);

    // ── Eyes ─────────────────────────────────────────────────────────────
    fill(50);
    ellipse(-4, -H / 2 + 2, 4, 4);
    ellipse(4,  -H / 2 + 2, 4, 4);

    // ── Chef coat (body) ─────────────────────────────────────────────────
    fill(240, 240, 240);
    rect(-W / 2, -H / 2 + 14, W, 24, 3);

    // Coat buttons
    fill(180, 180, 180);
    ellipse(0, -H / 2 + 19, 4, 4);
    ellipse(0, -H / 2 + 27, 4, 4);

    // ── Trousers ─────────────────────────────────────────────────────────
    fill(60, 60, 160);
    rect(-12, H / 2 - 16, 10, 16, 2);
    rect(2,   H / 2 - 16, 10, 16, 2);

    // ── Rolling pin (right hand — visual prop only, no gameplay effect) ──
    // Held at an angle suggesting mid-roll.
    stroke(160, 100, 40);
    strokeWeight(3);
    line(12, -4, 30, 4);       // handle shaft
    strokeWeight(7);
    line(18, -1, 28, 3);       // cylinder body
    strokeWeight(2);
    fill(200, 140, 60);
    noStroke();
    ellipse(18, -1, 7, 7);    // left cap
    ellipse(28,  3, 7, 7);    // right cap
    noStroke();

    popMatrix();
  }
}
