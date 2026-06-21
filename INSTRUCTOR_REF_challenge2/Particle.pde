// Particle.pde
// A single fragment expelled during the disintegration sequence.
// Single responsibility: independent motion, alpha fade, expiry detection.
// Instances are owned and managed by Sky via an ArrayList<Particle>.

class Particle {

  float x, y;
  float vx, vy;
  float lifespan; // 0–255; used directly as the alpha channel
  color col;
  float sz; // diameter of the particle disc

  Particle(float x, float y, float vx, float vy, color col) {
    this.x        = x;
    this.y        = y;
    this.vx       = vx;
    this.vy       = vy;
    this.col      = col;
    this.lifespan = 255;
    this.sz       = random(4, 14);
  }

  void update() {
    x  += vx;
    y  += vy;
    vy += 0.18;  // gentle downward gravity on fragments
    vx *= 0.978; // slight air resistance slows horizontal drift
    lifespan -= 3.2;
  }

  void display() {
    noStroke();
    fill(red(col), green(col), blue(col), lifespan);
    ellipse(x, y, sz, sz);
  }

  // Sky.update() removes this particle from the ArrayList when isDead() is true.
  boolean isDead() {
    return lifespan <= 0;
  }
}
