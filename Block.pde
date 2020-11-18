/**
 * Collisidable
 */

class AABB extends CollisionObject {
  PImage sprite;
  float x, y, w, h;
  color c = color(random(255), random(255), random(255));
  
  // Main constructor
  public AABB(float x, float y, float w, float h, Scene scene) {
    super(scene);
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  // Most used constructor
  public AABB(float x, float y, float w, float h, boolean ignoreCollisions, Scene scene) {
    this(x, y, w, h, scene);
    this.ignoreCollisions = ignoreCollisions;
  }
  
 // Constructor also setting the debug colour
 public AABB(color c, float x, float y, float w, float h, boolean ignoreCollisions, Scene scene) {
    this(x, y, w, h, scene);
    this.c = c;
    this.ignoreCollisions = ignoreCollisions;
  }
  
  // Draws image
  public void draw(float ms, PGraphics pg) {
    if (debug) {
      pg.noStroke();
      pg.fill(c);
      pg.rectMode(CENTER);
      pg.rect(x, y, w, h);
    }
    if (sprite != null) {
      pg.imageMode(CENTER);
      pg.image(sprite, x, y);
    }
  }
  
  public void update(float ms) {}
  
  // Collision with other, if overlap is not null, the overlap x and y between these objects is calculated
  public boolean collide(CollisionObject other, PVector overlap, boolean selfCall) {
    if (other instanceof AABB) {  // If colliding with block
      return collideBlock((AABB) other, overlap);
    } else if (selfCall) {   // Checks both objects for collision between the types
      boolean r = other.collide(this, overlap, false);  // Call other, then reverse overlap
      if (overlap != null) {
        overlap.x = -overlap.x;
        overlap.y = -overlap.y;
      }
      return r;
    }
    throw new CollisionTypeError(other, this);  // If collision between objects is not implemented, throw error
  }
  
  // Colliding with another AABB
  public boolean collideBlock(AABB other, PVector overlap) {
    if (ignoreCollisions || other.ignoreCollisions) return false;  // If both are ignoring collisions: if both are static scenery
    if (!(minX() <= other.maxX() && maxX() >= other.minX() &&      // Overlap check
            minY() <= other.maxY() && maxY() >= other.minY()))
            return false;
            
    if (overlap != null) {    // Pass collision overlap out if overlap is not null
      overlap.x = sign(x - other.x) * ((w/2 + other.w/2) - abs(x - other.x));
      overlap.y = sign(y - other.y) * ((h/2 + other.h/2) - abs(y - other.y));
    }
    return true;
  }
  
  // List of corners for swinging
  public PVector[] getCorners() {
    return new PVector[] {
      new PVector(x - w/2, y - h/2),
      new PVector(x - w/2, y + h/2),
      new PVector(x + w/2, y - h/2),
      new PVector(x + w/2, y + h/2)
    };
  }
  
  // Checks if point inside
  public boolean contains(PVector p) {
    return (x-w/2 < p.x && p.x < x+w/2 && y-h/2 < p.y && p.y < y+h/2);
  }
  
  public float minX() {
    return x - w/2;
  }
  
  public float maxX() {
    return x + w/2;
  }
  
  public float minY() {
    return y - h/2;
  }
  
  public float maxY() {
    return y + h/2;
  }
  
  public String toString() {
    return String.format("AABB (%.3f, %.3f, %.3f, %.3f)", x, y, w, h);
  }
}
