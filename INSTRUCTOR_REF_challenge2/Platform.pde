// Platform.pde
// A single baguette-shaped horizontal platform.
// Single responsibility: position, scrolling, visual, off-screen detection.
// Does NOT know about the baker, sky, ground, or game state.

class Platform {

  float x, y; // top-left corner of the platform surface
  float w;    // width in pixels

  // Visual depth of the baguette loaf
  final float H = 14;

  // ── Platform spacing rationale ────────────────────────────────────────
  // Baker jump height ≈ v² / (2g) = 12² / (2 × 0.5) = 144 px.
  // Game.pde spawns platforms with a vertical gap of 80–110 px,
  // safely within that arc. Horizontal placement is random across the
  // full canvas width; because the baker can run and jump simultaneously,
  // the combined arc always covers any horizontal gap between platforms.
  // Minimum platform width is 70 px — enough to land on from any angle.

  Platform(float x, float y, float w) {
    this.x = x;
    this.y = y;
    this.w = w;
  }

  // Moves the platform downward each frame to create the scrolling illusion.
  // scrollSpeed is supplied by Game so this class stays decoupled from
  // the global scroll constant.
  void update(float scrollSpeed) {
    y += scrollSpeed;
  }

  void display() {
    noStroke();

    // Drop shadow
    fill(0, 0, 0, 35);
    ellipse(x + w / 2, y + H + 5, w * 0.85, 8);

    // Main baguette body — warm golden colour
    fill(205, 155, 55);
    rect(x, y, w, H, H / 2);

    // Top crust highlight
    fill(240, 195, 80);
    rect(x + 5, y + 2, w - 10, 5, 3);

    // Score cuts (diagonal slashes typical on a baguette)
    stroke(165, 115, 35);
    strokeWeight(1.5);
    int cuts = max(1, int(w / 28));
    for (int i = 1; i <= cuts; i++) {
      float cx = x + (w / (cuts + 1)) * i;
      line(cx - 4, y + 3, cx + 4, y + H - 3);
    }
    noStroke();
  }

  // Returns true once the platform has scrolled entirely below the canvas.
  // Game.update() uses this to despawn old platforms and keep the list lean.
  boolean isOffScreen() {
    return y > height + 20;
  }
}
