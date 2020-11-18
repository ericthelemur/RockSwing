import java.util.List;
import java.util.LinkedList;
import java.util.TreeMap;
import java.util.BitSet;
import java.util.Stack;
import java.util.ConcurrentModificationException;

float lastMillis = 0;

SceneManager sm;
boolean debug = false;

void setup() {
  size(1920, 1080);
  frameRate(60);
  Scene s = new MenuScene();
  sm = new SceneManager(s);
}

void draw() {
    background(0);
    // Calculate frame time
    float t = millis();
    float ms = (t = millis()) - lastMillis;
    lastMillis = t;
    float s = ms / 1e3;
    
    sm.update(s);
    
    sm.draw(ms, this.g);
    
    InputManager.listener.reset();
}


static int LMB = 4, MMB = 5, RMB = 6;
// Forwards events to handler
void keyPressed() {
  InputManager.listener.keyPressed(keyCode);
}

void keyReleased() {
  InputManager.listener.keyReleased(keyCode);
}

void mousePressed() {
  InputManager.listener.keyPressed(toMB(mouseButton));
}

void mouseReleased() {
  InputManager.listener.keyReleased(toMB(mouseButton));
}

int toMB(int mbc) {
  if (mbc == LEFT) return LMB;
  if (mbc == CENTER) return MMB;
  if (mbc == RIGHT) return RMB;
  return -1;
}
