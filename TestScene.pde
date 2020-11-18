int PROJECTILECREATE, PROJECTILEDESTROY, RESET, CROUCH, SWITCHSCENE;

class TestScene extends PhysicsScene {
  int rockScale = 4;
  RockGenerator rg;
  Player player;
  Camera camera;
  int FOREGROUND_LAYER = 1, PLAYER_LAYER = 0, BACKGROUND_LAYER = -1;
  
  public TestScene() {
    rg = new RockGenerator(0, 0, width/rockScale, height/rockScale, 5, rockScale);
    //layers.add(PLAYER_LAYER, new AABB(100, 100, 100, 200, this));
    //layers.add(BACKGROUND_LAYER, new AABB(#442222, 100, 100, 200, 100, false, this));
    // Add blocks
     addAABB(new AABB(1000, 800, 2000, 100, this));
     addAABB(new AABB(300, 800, 150, 300, this));
    
     addAABB(new AABB(900, 100, 100, 100, this));
     addAABB(new AABB(1500, 100, 100, 100, this));
    
    
     addAABB(new AABB(1000, 200, 100, 300, this));
     
     // Add walls
     float wallThickness = 30;
     addAABB(new AABB(width/2-wallThickness, 0, width+wallThickness*2, wallThickness*2, this));
     addAABB(new AABB(0, height/2-wallThickness, 2*wallThickness, height+2*wallThickness, this));
     addAABB(new AABB(width/2-wallThickness, height, width+wallThickness*2, wallThickness*2, this));
     addAABB(new AABB(width, height/2-wallThickness, 2*wallThickness, height+2*wallThickness, this));
     //addAABB(new AABB(-30, height/2, 30, height+30, this));
     //addAABB(new AABB(width/2, -30, 30, height + 60, this));
     //addAABB(new AABB(-30, height/2, width + 60, 30, this));
    
    player = new Player(new PVector(500, 500), this);
    camera = new Camera(player);
    layers.add(PLAYER_LAYER, player);
    
    // Register inputs
    input.register(new SingleKey('W', KeyMethod.HELD), UP);
    input.register(new SingleKey(UP, KeyMethod.HELD), UP);
    input.register(new SingleKey('A', KeyMethod.HELD), LEFT);
    input.register(new SingleKey(LEFT, KeyMethod.HELD), LEFT);
    input.register(new SingleKey('S', KeyMethod.HELD), DOWN);
    input.register(new SingleKey(DOWN, KeyMethod.HELD), DOWN);
    input.register(new SingleKey('D', KeyMethod.HELD), RIGHT);
    input.register(new SingleKey(RIGHT, KeyMethod.HELD), RIGHT);
    input.register(new SingleKey(SHIFT, KeyMethod.HELD), CROUCH);
    PROJECTILECREATE = input.register(new SingleKey(LMB, KeyMethod.PRESSED));
    PROJECTILEDESTROY = input.register(new SingleKey(LMB, KeyMethod.RELEASED));
    
    RESET = input.register(new SingleKey('R', KeyMethod.PRESSED));
    SWITCHSCENE = input.register(new SingleKey('Y', KeyMethod.PRESSED));
    
    
    input.register(new SingleKey(SHIFT, KeyMethod.HELD), CROUCH);
  }
  
  // Add and texture block
  public void addAABB(AABB r) {
    layers.add(0, r);
    AABB scaled = new AABB(r.x / rockScale, r.y / rockScale, r.w / rockScale, r.h / rockScale, null);
    rg.updateTexture(scaled);
    r.sprite = generateResized(scaled.sprite, rockScale);
    //rg.images.add(r.sprite);
  }
  
  public void draw(float s, PGraphics pg) {
    //println(camera.currentPoint);
    //pg.translate(-camera.currentPoint.x, -camera.currentPoint.y);
    super.draw(s, pg);
    //pg.translate(camera.currentPoint.x, camera.currentPoint.y);
  }
  
  public void update(float s) {
    super.update(s);
    
    camera.checkPos(s);
    if (input.check(RESET)) sm.changeScene(new TestScene());
    if (input.check(SWITCHSCENE)) {
      //println("SWITCH");
      sm.changeScene(new SSScene());
    }
  }
}
