// Ground.pde
// The ever-rising ground that creates constant time pressure.
// Single responsibility: tracking the ground's top edge, displaying it,
// and checking whether it has reached the baker.
// Does NOT know about platforms, sky, or disintegration.

class Ground {

  float groundY;   // Y-coordinate of the ground's top (leading) edge
  float riseSpeed; // pixels per frame the ground rises (groundY decreases)

  // ── Why constant speed? ───────────────────────────────────────────────
  // Rise speed is deliberately constant, not accelerating.
  // A constant rate keeps the pressure predictable and legible — the baker
  // can always judge how long they have left. Accelerating difficulty
  // (e.g. riseSpeed *= 1.0002 each frame) would be a reasonable extension
  // for a student iteration, but is excluded here so the reference shows
  // the simplest correct version first. (LO2 design note)
  // ─────────────────────────────────────────────────────────────────────

  Ground(float startY, float riseSpeed) {
    this.groundY  = startY;
    this.riseSpeed = riseSpeed;
  }

  // ─── LO2 — groundY is the SECOND of the two scalars that drive every ──
  // major state transition in this game. (The first is baker.getY().)
  // See Sky.pde for the full comment on both scalars.
  void update() {
    groundY -= riseSpeed; // ground surface moves upward each frame
  }

  void display() {
    noStroke();

    // Grass strip along the top edge
    fill(65, 175, 65);
    rect(0, groundY, width, 14);

    // Lighter grass highlight (tuft effect)
    fill(90, 210, 90);
    rect(0, groundY, width, 6);

    // Soil body beneath the grass
    fill(115, 75, 38);
    rect(0, groundY + 14, width, height - groundY - 14);

    // Pebble texture (deterministic so it doesn't flicker each frame)
    fill(90, 58, 28);
    for (int i = 0; i < 18; i++) {
      float px = (i * 47 + 13) % width;
      float py = groundY + 20 + (i * 31) % (max(1, height - groundY - 20));
      ellipse(px, py, 6, 4);
    }

    // Danger flash: red stroke on the leading edge when ground is within
    // 200 px of the vertical centre — warns the player visually.
    if (groundY < height * 0.65) {
      float alpha = map(groundY, height * 0.65, height * 0.25, 60, 220);
      float pulse = abs(sin(frameCount * 0.12));
      stroke(220, 30, 30, alpha * pulse);
      strokeWeight(4);
      line(0, groundY, width, groundY);
      noStroke();
    }
  }

  // Death condition 1 — Crushed.
  // Returns true when the ground's leading edge has reached the baker's feet.
  boolean hasCrushed(Baker b) {
    return groundY <= b.y + b.H / 2;
  }
}
