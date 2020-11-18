// UNFINISHED
// Made graphics incredibly laggy

class Camera {
  public Player player;
  public PVector currentPoint = new PVector();
  
  public Camera(Player player) {
    this.player = player;
    //currentPoint = new PVector(player.pos.x - width/2, player.pos.y - height/2);
  }
  
  public void checkPos(float s) {
    //PVector onScreen = PVector.sub(player.pos, new PVector(width, height));
    
    currentPoint = new PVector(player.pos.x - width/2, player.pos.y - height/2);
    //if (onScreen.x < width/3) {
    //  currentPoint.x -= player.pPos.x - player.pos.x;
    //} else if (onScreen.x > 2*width/3) {
    //  currentPoint.x -= player.pPos.x - player.pos.x;
    //}
    
    //if (onScreen.y < height/4) {
    //  currentPoint.y -= player.pPos.y - player.pos.y;
    //} else if (onScreen.y > 3*height/4) {
    //  currentPoint.y -= player.pPos.y - player.pos.y;
    //}
  }
}
