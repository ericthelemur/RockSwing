// Basic drawable interface
interface IDrawObject {
    void draw(float s, PGraphics pg);
}

// Object with update function and scene addition
abstract class UpdatingObject implements IDrawObject {
  Scene scene;
  public UpdatingObject(Scene scene) {
    this.scene = scene;
    if (scene != null) scene.addMoveable(this);
  }
  
  abstract void update(float s);
}

// Object with basic collision skeleton
abstract class CollisionObject extends UpdatingObject {
  boolean ignoreCollisions = false;
  public CollisionObject(Scene scene) {
    super(scene);
    if (scene instanceof PhysicsScene) ((PhysicsScene) scene).playerCollisionObjects.add(this);
  }
  
  boolean collide(CollisionObject other) {
    return collide(other, null, true);
  }
  
  boolean collide(CollisionObject other, PVector overlap) {
    return collide(other, overlap, true);
  }
  
  abstract boolean collide(CollisionObject other, PVector overlap, boolean selfCall);
  abstract PVector[] getCorners();
}


class CollisionTypeError extends Error {
  CollisionTypeError() {
    super("Collision between these types is not supported");
  }
  
  CollisionTypeError(String str) {
    super(str);
  }
  
  CollisionTypeError(CollisionObject o1, CollisionObject o2) {
    super("Collision between " + o1.getClass().getName() + " and " + o2.getClass().getName() + " is not supported");
  }
}

class Sprite implements IDrawObject {
  int x, y;
  PImage image;
  
  public Sprite(int x, int y, PImage image) {
    this.x = x;
    this.y = y;
    this.image = image;
  }
  
  public void draw(float s, PGraphics pg) {
    pg.image(image, x, y);
  }
}

class Marker implements IDrawObject {
  float x, y;
  
  public Marker(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  public void draw(float s, PGraphics pg) {
    println("Marker " + x + "," + y);
    pg.fill(#FF00FF);
    pg.noStroke();
    pg.circle(x, y, 3);
  }
}

float sign(float x) {
  if (x < 0) return -1;
  else if (x > 0) return 1;
  else /*x == 0*/ return 0;
}

float approach(float val, float target, float inc) {
  if (val < target) return min(val + inc, target);
  else return max(val - inc, target);
}

float clamp(float val, float minVal, float maxVal) {
  return max(min(val, maxVal), minVal);
}
