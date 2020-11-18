// Basic projectile
class Projectile extends MovingObject {
  
  public Projectile(PVector pos, PVector vel, AABB collision, PVector AABBOffset, Scene scene) {
    super(pos, collision, AABBOffset, scene);
    this.vel = vel;
    
    this.collision.ignoreCollisions = false;
    this.stickToSurface = true;
  }
  
  // Create stationary
  public Projectile(PVector pos, PVector vel, Scene scene) {
    this(pos, vel, new AABB(0, 0, 10, 10, scene), new PVector(0, 0), scene);
  }
  
  public void move(float s) {}
  
  public void draw(float s, PGraphics pg) {
    collision.c = #0000FF;
    collision.draw(s, pg);
    //pg.rect(pos.x, pos.y, 200, 200);
  }
  
  public String toString() {
    return String.format("Projectile %s %s", pos, vel);
  }

}

// Grapple's projectile
enum GrappleState {Shoot, Grab}
class GrappleProjectile extends Projectile {
  
  GrappleState state = GrappleState.Shoot;
  Player player;
  GrappleRope rope;
  PImage sprite = loadImage("grapple.png");
  
  public GrappleProjectile(PVector pos, PVector vel, Player player, Scene scene) {
    super(pos, vel, scene);
    this.player = player;
  }
  
  public void update(float s) {
    super.update(s);  // Applies velocity
    // If stopped, start swinging
    if (state == GrappleState.Shoot && vel.x == 0 && vel.y == 0) {
      state = GrappleState.Grab;
      rope = new GrappleRope(this, player, scene);
    }
  }
  
  @Override
  public void draw(float s, PGraphics pg) {
    //super.draw(s, pg);
    pg.imageMode(CENTER);
    pg.image(sprite, pos.x, pos.y);
    switch (state) {
      case Shoot:   // Draw straight line
        pg.stroke(color(145, 110, 61));
        pg.strokeWeight(2);
        pg.noFill();
        pg.line(player.pos.x, player.pos.y, pos.x, pos.y);
        break;
      case Grab:   // Draw rope (could be multiple parts)
        rope.draw(s, pg);
    }
  }
}

// Grapple rope
class GrappleRope extends UpdatingObject {
  List<PVector> points = new ArrayList<PVector>();
  GrappleProjectile anchor;  // Root anchor
  Player player;
  PVector currentAnchor;  // Current end to swing off
  float length;
  boolean checking = true;
  boolean add = true;
  
  public GrappleRope(GrappleProjectile anchor, Player player, Scene scene) {
    super(scene);
    this.anchor = anchor;
    this.player = player;
    currentAnchor = anchor.pos;
    points.add(currentAnchor);
    length = PVector.sub(player.pos, anchor.pos).mag();
  }
  
  public void update(float s) {
    if (scene instanceof PhysicsScene) {
      PhysicsScene sc = (PhysicsScene) scene;
      // Removing old anchor
      if (points.size() > 1 && checking) {
        // Get tangent of the rope segment between last anchors
        PVector prevAnchor = points.get(points.size()-2);
        PVector dir = PVector.sub(currentAnchor, prevAnchor);
        PVector perp = new PVector(-dir.y, dir.x);
        
        
        // If has moved from one side of the other, detach anchor (has swung back)
        if ((perp.dot(PVector.sub(player.pos, currentAnchor)) > 0) != (perp.dot(PVector.sub(player.pPos, currentAnchor)) > 0)) {
          points.remove(points.size()-1);
          currentAnchor = prevAnchor;
          setLength(player.pos.dist(currentAnchor));
          add = false;
        }
      }
      if (checking == false) checking = true;  // checking allows for 1 frame skip when new rope is added
      
      if (add) {  // If adding points
      // New corners
      PVector candidate = null;
      PVector playerPrev = player.pPos, playerPos = player.pos;
      
      for (CollisionObject co : sc.playerCollisionObjects) {
        for (PVector corner : co.getCorners()) {  // Check all corners
          // https://gamedev.stackexchange.com/questions/558/implementing-a-wrapping-wire-like-the-worms-ninja-rope-in-a-2d-physics-engine
          PVector OA = PVector.sub(playerPos, currentAnchor);
          PVector OB = PVector.sub(playerPrev, currentAnchor);
          PVector OP = PVector.sub(corner, currentAnchor);
          
          float ap = OA.cross(OP).z;
          float pb = OP.cross(OB).z;
          float ab = OA.cross(OB).z;
          
          // Check for point in the sector swung by rope
          if (((ap < 0) == (pb < 0)) && ((pb < 0) == (ab < 0)) && OP.magSq() < length * length) {
            if (!points.contains(corner)) {
              if (candidate == null) candidate = corner;
              // If earlier, add this point instead
              else if (PVector.angleBetween(OB, OP) < PVector.angleBetween(OB, PVector.sub(candidate, currentAnchor))) {
                candidate = corner;  
                //sc.layers.add(3, new Marker(corner.x, corner.y));
              }
            }
          }
        }
      }
      // Add first point as anchor
      if (candidate != null) {
        points.add(candidate);
        currentAnchor = candidate;
        setLength(player.pos.dist(currentAnchor));
        checking = false;  // Skip frame of checking
        //sc.layers.add(3, new Marker(candidate.x, candidate.y));
      }
      
      } else add = true;
    }
  
  }
  
  // Set rope length, conserving ang momentum
  public void setLength(float l) {
    float oldLength = length;
    length = l;
    player.angVel *= oldLength / length;
    player.angVel = clamp(player.angVel, -2, 2);
  }
  
  public void draw(float s, PGraphics pg) {
    pg.stroke(color(145, 110, 61));
    pg.strokeWeight(2);
    pg.noFill();
    
    pg.beginShape();
    for (PVector p : points) {
      pg.vertex(p.x, p.y);
    }
    pg.vertex(player.pos.x, player.pos.y);
    pg.endShape();
    
    //PhysicsScene sc = (PhysicsScene) scene;
    //for (CollisionObject co : sc.playerCollisionObjects) {
    //  for (PVector corner : co.getCorners()) {
    //    pg.fill(#FF0000);
    //    pg.ellipseMode(RADIUS);
    //    pg.ellipse(corner.x, corner.y, 2, 2);
    //  }
    //}
  }
}
