class SSScene extends PhysicsScene {
  int rockScale = 4;
  Player player;
  int FOREGROUND_LAYER = 1, PLAYER_LAYER = 0, BACKGROUND_LAYER = -1;
  Camera camera;
  
  RockGenerator rg;
  public SSScene() {
    
    
    
    rg = new RockGenerator(0, 0, width/rockScale, height/rockScale, 5, rockScale);
    
    
    addAABB(new AABB(1000, 800, 1200, 150, this));
    
    
    
    
    player = new Player(new PVector(900, -200), this);
    camera = new Camera(player);
    layers.add(PLAYER_LAYER, player);
    
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
  
  public void addAABB(AABB r) {
    layers.add(0, r);
    AABB scaled = new AABB(r.x / rockScale, r.y / rockScale, r.w / rockScale, r.h / rockScale, null);
    rg.updateTexture(scaled);
    r.sprite = generateResized(scaled.sprite, rockScale);
    //rg.images.add(r.sprite);
  }
  
  public void update(float s) {
    super.update(s);
    if (input.check(RESET)) sm.changeScene(new SSScene());
    if (input.check(SWITCHSCENE)) {
      println("SWITCH");
      sm.changeScene(new TestScene());
    }
    camera.checkPos(s);
  }
  
  
  @Override
  public void draw(float s, PGraphics pg) {
    pg.translate(-camera.currentPoint.x, -camera.currentPoint.y);
    super.draw(s, pg);
    
    //for (PImage img : rg.images) {
    //  pg.image(img, 0, 0);
    //}
    //if (rg.resized == null) {
    //  rg.generateResized();
    //}
    
    //player.draw(s, pg);
    pg.translate(camera.currentPoint.x, camera.currentPoint.y);
    
    //PImage newImage = rg.resized.get((int) camera.currentPoint.x, (int) camera.currentPoint.y, width, height);
    //pg.image(newImage, 0, 0, width, height);
    //pg.image(rocks, 0, 0, width, height, (int) camera.currentPoint.x, (int) camera.currentPoint.y, width, height);
  }
}
