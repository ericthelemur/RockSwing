// Allows for stack of scenes
class SceneManager implements IDrawObject {
  Stack<Scene> scenes = new Stack<Scene>();
  Scene scene;
  
  
  public SceneManager(Scene initial) {
    newScene(initial);
  }
  
  public void newScene(Scene newScene) {
    scenes.push(newScene);
    scene = newScene;
  }
  
  public Scene changeScene(Scene newScene) {
    Scene s = scenes.pop();
    scenes.push(newScene);
    scene = newScene;
    return s;
  }
  
  public Scene removeScene() {
    return scenes.pop();
  }
  
  public void draw(float s, PGraphics pg) {
    scene.draw(s, pg);
  }
  
  public void update(float s) {
    scene.update(s);
  }
}

// Stores general scene info
class Scene implements IDrawObject {
  DrawLayerManager layers = new DrawLayerManager();
  List<UpdatingObject> moveables = new ArrayList<UpdatingObject>();
  // Used to avoid concurrent modification
  List<UpdatingObject> moveablesToAdd = new ArrayList<UpdatingObject>();
  List<UpdatingObject> moveablesToRemove = new ArrayList<UpdatingObject>();
  InputManager input = new InputManager();
  boolean displayBelow = false;

  public void draw(float s, PGraphics pg) {
    layers.draw(s, pg);
  }
  
  public void update(float s) {
    for (UpdatingObject mo : moveables) {
      mo.update(s);
    }
    if (moveablesToAdd.size() > 0) {
      moveables.addAll(moveablesToAdd);
      moveablesToAdd.clear();
    }
    
    if (moveablesToRemove.size() > 0) {
      moveables.removeAll(moveablesToRemove);
      moveablesToRemove.clear();
    }
  }
  
  public void addMoveable(UpdatingObject m) {
    moveablesToAdd.add(m);
  }
  
  public void removeMoveable(UpdatingObject m) {
    moveablesToAdd.remove(m);
  }
}

// Has bonus list of player collidable objects
class PhysicsScene extends Scene {
  List<CollisionObject> playerCollisionObjects = new ArrayList<CollisionObject>();
}
