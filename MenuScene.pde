
// Main menu scene

int CONTINUE;
class MenuScene extends Scene {
    public MenuScene() {
      CONTINUE = input.register(new SingleKey(' ', KeyMethod.PRESSED));  // Transision if space pressed
      //CONTINUE = input.register(new SingleKey(LMB,  KeyMethod.PRESSED));
    }
    
    public void draw(float s, PGraphics pg) {
    super.draw(s, pg);
    
    // Draw menu
    pg.fill(255);
    pg.textSize(50);
    pg.textAlign(CENTER, CENTER);
    pg.text("ROCK GAME", width/2, height * 0.25);
    
    pg.textSize(20);
    pg.text("A tech demo made by Owen Connors for Warwick Game Design Society's Welcome Game Jam, October 2020", width/2, height * 0.75);
    pg.text("PRESS SPACE TO START >>", width/2, height * 0.8);
  }
  
  public void update(float s) {
    super.update(s);
    
    // If continue input transition
    if (input.check(CONTINUE)) sm.changeScene(new TransitionScene());
  }
}
