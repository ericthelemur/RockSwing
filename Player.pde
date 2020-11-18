

enum CharacterState {Walk, Swing}

class Player extends MovingObject {
  // Player constants
  float gravity = 25;
  float terminalVel = 100000;
  float friction = 0.2;
  float airResistance = 0.01;
  float coyoteTime = 0.1;
  float timeFromEdge = 0;
  PImage sprite = loadImage("player.png");
  
  CharacterState state = CharacterState.Walk;
  float walkSpeed = 350;
  float jumpHeight = 200;
  float jumpSpeed;
  
  GrappleProjectile grappleProj = null;
  GrappleRope rope = null;
  float angVel = 0;
  
  
  public Player(PVector pos, AABB collision, PVector AABBOffset, float walkSpeed, float jumpHeight, Scene scene) {
    super(pos, collision, AABBOffset, scene);
    this.walkSpeed = walkSpeed;
    this.jumpHeight = jumpHeight;
    this.jumpSpeed = sqrt(2 * gravity * jumpHeight); // Calculate jumpSpeed from maxheight using suvat
    this.collision.ignoreCollisions = false;
  }
  
  
  public Player(PVector pos, Scene scene) {
    this(pos, new AABB(0, 0, 30, 87, scene), new PVector(0, 0), 350, 250, scene);
  }
  
  public void update(float s) {
    super.update(s);
    if (state == CharacterState.Swing) {  // If swinging and anchor changed (dist to anchor changed)
      float d = pos.dist(rope.currentAnchor);    // ... change rope length and speed
      if (d != rope.length) {
        rope.setLength(d);
      }
    
    }
    
    // Reset coyte time
    if (wasOnGround && !onGround) timeFromEdge = 0;
    
    // Grapple create
    if (scene.input.check(PROJECTILECREATE)) {
      PVector d = new PVector(mouseX - pos.x, mouseY - pos.y);
      d.setMag(3000);
      grappleProj = new GrappleProjectile(pos, d, this, scene);
      scene.layers.add(0, grappleProj);
    }
    // Grapple destroy
    if (scene.input.check(PROJECTILEDESTROY) && grappleProj != null) {
      scene.layers.remove(0, grappleProj);
      scene.removeMoveable(grappleProj);
      grappleProj = null;
      rope = null;
    }
  }
  
  public void move(float s) {
    switch (state) {  // State machine for movement
      case Walk:
        standard(s);
        break;
        
      case Swing:
        swing(s);
        break;
    }
    
  }  
  
  // Standard (non-swinging) movement
  public void standard(float s) {
    // Increase coyote time
    if (!onGround) timeFromEdge += s;
    
    // 
    if (timeFromEdge < coyoteTime) {
      if (vel.y < 0)  // If jumping, make coyote time impossible
        timeFromEdge = coyoteTime + 1;
      else if (scene.input.check(UP)) // Coyote time jump
        vel.y -= jumpSpeed * 10;
    }
    
    // X movement
    int dx = scene.input.checkI(RIGHT) - scene.input.checkI(LEFT);
    vel.x += walkSpeed * dx;
    
    // Friction
    if (dx == 0 && onGround) {
      vel.x *= (1-friction);
      if (abs(vel.x) < 0.1) vel.x = 0;
    }
    vel.x = clamp(vel.x, -walkSpeed, walkSpeed);
    
    // Y movement
    if (!onGround) {
      vel.y += gravity;
    } else {
      if (scene.input.check(UP))
        vel.y -= jumpSpeed * 10;
    }
    
    // If grapple has grabbed, switch to swinging
    if (grappleProj != null && grappleProj.state == GrappleState.Grab && pos.y > grappleProj.pos.y) {
      state = CharacterState.Swing;
      rope = grappleProj.rope;
      rope.length = PVector.sub(pos, grappleProj.pos).mag();
      
      angVel = toAngVel(vel, rope.currentAnchor, rope.length, s, pos);
    }
  }
  
  // Rope swinging
  public void swing(float s) {
    if (grappleProj == null) {  // If grapple doesn't exist any more, return to walk, with a bit of a boost
      state = CharacterState.Walk;
      vel.x *= 1.2;
      return;
    }
    
    // X (swing left/right) input, only allow if below anchor
    PVector ropeOffset = PVector.sub(pos, rope.currentAnchor);
    int dx = scene.input.checkI(RIGHT) - scene.input.checkI(LEFT);
    if (ropeOffset.y > 0) angVel -= 50 * dx * sin(ropeOffset.heading()) / rope.length;
    
    // Y (up/down rope) input
    int dy = scene.input.checkI(DOWN) - scene.input.checkI(UP);
    //if (dy != 0) rope.setLength(rope.length + dy * 10);
    
    // Apply gravity and bonus restoring force
    angVel += 0.15 * cos(ropeOffset.heading()) * (gravity + 0.1 * angVel * angVel) * s; 
    if (collX || collY) angVel *= (1-friction);  // If colliding atm, slow down (friction)
    
    // Calculate new xy vel from swing
    PVector newVel = toVel(angVel, rope.currentAnchor, rope.length, s, pos);
    if (newVel != null) vel = newVel;
    
    // If moving up/down, move in normal to swing dir
    if (dy != 0) {
      PVector n = new PVector(ropeOffset.x, ropeOffset.y);
      n.normalize();
      println(n, vel);
      vel.add(PVector.mult(n, dy*500));
      println(vel);
    }
  } 
  
  
  public void draw(float s, PGraphics pg) {
    pg.imageMode(CENTER);
    pg.image(sprite, pos.x, pos.y);
    
    if (debug) {  // Debug draw
      pg.noStroke();
      pg.fill(#0000FF);
      pg.rectMode(CENTER);
      rect(pos.x, pos.y, collision.w, collision.h);
      
      fill(255);
      textAlign(LEFT, TOP);
      pg.text("" + (s) + " " + state.toString() + " " + pos + "  " + vel + "  " + acc, 0, 0);
      if (grappleProj != null) 
        pg.text(grappleProj.state.toString(), 0, 15);
    }
  }
}

// Converts ang vel to xy vel
public PVector toVel(float angVel, PVector anchor, float length, float s, PVector oldPos) {
  PVector offset = PVector.sub(oldPos, anchor);
  float newAngle = (offset.heading()) + angVel * s;
    
  angVel *= 0.98;
  PVector newOffset = PVector.mult(PVector.fromAngle(newAngle), length);
  
  PVector newPos = PVector.add(anchor, newOffset);
  
  if (s != 0)
    return PVector.div(PVector.sub(newPos, oldPos), s);
  return null;
}

// Converts xy vel to ang vel
public float toAngVel(PVector vel, PVector anchor, float length, float s, PVector oldPos) {
  PVector v = PVector.add(PVector.mult(vel, s), PVector.add(oldPos, anchor));
  v.div(length);
  float newAngle = atan2(v.x, v.y);
  
  float ropeAngle = PVector.sub(oldPos, anchor).heading();
  return newAngle - ropeAngle;
}
