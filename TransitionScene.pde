
// Temporary loading screen while generating
class TransitionScene extends Scene {
    public TransitionScene() {
    }
    boolean load = false;
    
    public void draw(float s, PGraphics pg) {
    super.draw(s, pg);
    
    pg.fill(255);
    pg.textSize(50);
    pg.text("Loading", width/2, height/2);
  }
  
  public void update(float s) {
    super.update(s);
    if (load) {
      TestScene ts = new TestScene();
      sm.changeScene(ts);
    } else load = true;
  }
}
