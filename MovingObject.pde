// Class for a moving collision object

abstract class MovingObject extends UpdatingObject {
  PVector pos, pPos = new PVector();
  PVector vel = new PVector();
  PVector acc = new PVector();
  
  //float multiCheckThreshholdChange = 50;
  
  AABB collision;
  PVector AABBOffset; 
  
  boolean onGround, wasOnGround;
  boolean stickToSurface = false;
  boolean collX = false, collY = false;
  
  public MovingObject(PVector pos, AABB collision, PVector AABBOffset, Scene scene) {
    super(scene);
    this.pos = new PVector(pos.x, pos.y);
    this.AABBOffset = AABBOffset;
    this.collision = new AABB(pos.x + AABBOffset.x, pos.y + AABBOffset.y, collision.w, collision.h, true, scene);
    
    if (scene instanceof PhysicsScene) {
      PhysicsScene sc = (PhysicsScene) scene;
      sc.playerCollisionObjects.remove(this.collision);
    }
  }
  
  
  public MovingObject(PVector pos, Scene scene) {
    this(pos, new AABB(0, 0, 50, 75, scene), new PVector(0, 0), scene);
  }
  
  public void update(float s) {
    // Update previous values
    wasOnGround = onGround;
    
    pPos.x = pos.x;
    pPos.y = pos.y;
    
    // Move
    move(s);
    
    // Apply acc
    vel.x += acc.x * s;
    vel.y += acc.y * s;
    
    // Commented code here is to deal with objects travelling fast enough, multiple checks are needed, bu unneeded
    PVector frameVel = PVector.mult(vel, s);
    
    //if (frameVel.mag() < multiCheckThreshholdChange) {
      // Apply vel
      pos.add(frameVel);
      collision.x = pos.x + AABBOffset.x;
      collision.y = pos.y + AABBOffset.y;
      
      collisionHandling();
      
    //} else {
      
    //  PVector stepVel = new PVector(frameVel.x, frameVel.y);
    //  stepVel.setMag(multiCheckThreshholdChange);
      
    //  PVector sumVel = new PVector();
      
    //  while (sumVel.magSq() < vel.magSq()) {
    //    sumVel.add(stepVel);
    //    if (sumVel.magSq() > vel.magSq()) {
    //      pos.x += (vel.x - sumVel.x) * s;
    //      pos.y += (vel.y - sumVel.y) * s;
    //      collision.x = pos.x + AABBOffset.x;
    //      collision.y = pos.y + AABBOffset.y;
    //      collisionHandling();
    //      break;
    //    }
        
    //    pos.x += stepVel.x * s;
    //    pos.y += stepVel.y * s;
    //    collision.x = pos.x + AABBOffset.x;
    //    collision.y = pos.y + AABBOffset.y;
        
    //    collisionHandling();
        
    //    if (vel.x == 0 && vel.y == 0) {
    //      break;
    //    }
    //  }
      
    //  pos.x += (vel.x - sumVel.x) * s;
    //  pos.y += (vel.y - sumVel.y) * s;
    //  collision.x = pos.x + AABBOffset.x;
    //  collision.y = pos.y + AABBOffset.y;
    //  collisionHandling();
      
    //}
    
    // update collision box
    collision.x = pos.x + AABBOffset.x;
    collision.y = pos.y + AABBOffset.y;
    
  }
  
  abstract void move(float s);
  
  public void collisionHandling() {
    if (scene instanceof PhysicsScene) {  // Only apply on a scene with physics objects
      PhysicsScene sc = (PhysicsScene) scene;
      onGround = false;
      collX = false;
      collY = false;
      
      // Check against all scenery
      for (CollisionObject co : sc.playerCollisionObjects) {
        if (!(co instanceof AABB)) throw new CollisionTypeError();
        AABB other = (AABB) co;
        if (collision == other) continue;  // Can't collide with self
        
        // Check collision
        PVector overlap = new PVector();
        if (collision.collideBlock(other, overlap)) {
          
          // If just touching on x, but will collide, limit x vel
          if (overlap.x == 0) {
            if (other.x > collision.x) {
              vel.x = min(vel.x, 0);
            }
            else {
              vel.x = max(vel.x, 0);
            }
            collX = true;
            continue;
          }
          
          // If just touching on x, but will collide, limit y vel
          if (overlap.y == 0) {
            if (other.y > collision.y) {
              vel.y = min(vel.y, 0);
              onGround = vel.y == 0;
            }
            else {
              vel.y = max(vel.y, 0);
            }
            collY = true;
            //vel.y = 0;
            
            continue;
          }
          
          // Check for collision last frame
          boolean overlappedPrevX = abs(pPos.x - other.x) < (other.w + collision.w)/2;
          boolean overlappedPrevY = abs(pPos.y - other.y) < (other.h + collision.h)/2;
          
          
          // If there was a y overlap and no x overlap last frame, this must be a collision on the x axis,
          //     or if a diagonal collision, with more overlap in x
          if ((!overlappedPrevX && overlappedPrevY) || (!overlappedPrevX && !overlappedPrevY && abs(overlap.x) >= abs(overlap.y))) {
            collX = true;
            // Resolve x
            pos.x += overlap.x;
            // if sticking (grapple hook)
            if (stickToSurface) {
              // Move to be in contact, then stop
              float p = overlap.x / vel.x;
              pos.y += vel.y * p;
              
              vel.x = 0;
              vel.y = 0;
            } else {
              // Otherwise, limit x vel on correct side
              if (overlap.x < 0) {
                vel.x = min(vel.x, 0);
              } else {
                vel.x = max(vel.x, 0);
              }
            }
            
          } else {  // Resolve y
            collY = true;
            pos.y += overlap.y;
            // if sticking (grapple hook)
            if (stickToSurface) {
              // Move to be in contact, then stop
              float p = overlap.y / vel.y;
              pos.x += vel.x * p;
              
              vel.x = 0;
              vel.y = 0;
            } else {
              // Otherwise, limit x vel on correct side
              if (vel.y != 0) {
                if (overlap.y < 0) {
                  vel.y = min(vel.y, 0);
                  // on ground if no y velocity
                  onGround = vel.y == 0;
                }
                else {
                  vel.y = max(vel.y, 0);
                }
              }
            }
          }
          
        }
      }
    }
    
    collision.x = pos.x + AABBOffset.x;
    collision.y = pos.y + AABBOffset.y;
  }
  
  
  public void draw(float s, PGraphics pg) {
    collision.c = #FF00FF;
    collision.draw(s, pg);
  }
  
  public String toString() {
    return String.format("MovingObject %s %s", pos, vel);
  }
}
