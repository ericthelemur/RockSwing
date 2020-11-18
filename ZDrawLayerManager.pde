// Manages layers for objects

class DrawLayerManager {
  TreeMap<Float, DrawLayer> layers = new TreeMap<Float, DrawLayer>();
  // Map of layers with names, e.g. player layer
  HashMap<String, Float> namedLayers = new HashMap<String, Float>();
  
  // Add obj at depth
  public boolean add(float depth, IDrawObject obj) {
    DrawLayer dl = layers.get(depth);
    
    if (dl == null) {  // Create new layer if it doesn't already exist
      layers.put(depth, new DrawLayer(depth, obj));
      return true;
    } else {
      dl.add(obj);
      return false;
    }
  }
  
  // Name layer
  public boolean registerLayer(String layer, float depth) {
    boolean r = !namedLayers.containsKey(layer);
    namedLayers.put(layer, depth);
    return r;
  }
  
  // Add to named layer
  public boolean add(String layer, IDrawObject obj) {
    Float depth = namedLayers.get(layer);
    if (depth == null) return false;
    
    DrawLayer dl = layers.get(depth);
    
    if (dl == null)
      layers.put(depth, new DrawLayer(depth, obj));
    else
      dl.add(obj);
    return true;
  }
  
  // Remove object
  public boolean remove(IDrawObject obj) {
    for (DrawLayer dl : layers.values()) {
      if (dl.remove(obj)) return true;
    }
    return false;
  }
  
  // Remove object from layer
  public boolean remove(float depth, IDrawObject obj) {
    DrawLayer dl = layers.get(depth);
    
    if (dl == null)
      return false;
      
    return dl.remove(obj);
  }
  
  public void draw(float s, PGraphics pg) {
    for (IDrawObject obj : layers.values()) {
      obj.draw(s, pg);
    }
  }
  
  public List<IDrawObject> getObjects(float depth) {
    DrawLayer dl = layers.get(depth);
    
    if (dl == null)
      return null;
     
    return dl.getObjects();
  }
  
}

// Layer
class DrawLayer implements IDrawObject {
  float depth = 0;
  List<IDrawObject> objs = new LinkedList<IDrawObject>();
  boolean cacheLayer = false;
  PGraphics cachePG = null;
  
  public DrawLayer(float depth, IDrawObject... objs) {
    this.depth = depth;
    for (IDrawObject obj : objs) {
      this.objs.add(obj);
    }
  }
  
  public boolean add(IDrawObject obj) {
    return objs.add(obj);
  }
  
  public boolean remove(IDrawObject obj) {
    return objs.remove(obj);
  }
  
  // Draw all layers, if cachePG, draw once to image, then redraw that
  public void draw(float s, PGraphics pg) {
    if (cacheLayer) {
      if (cachePG == null) {
        cachePG = createGraphics(width, height);
        for (IDrawObject obj : objs)
          obj.draw(s, cachePG);
      }
      pg.image(cachePG, 0, 0);
      
    } else {
      for (IDrawObject obj : objs)
        obj.draw(s, pg);
    }
  }
  
  public boolean clearCached() {
    cachePG = null;
    return cacheLayer;
  }
  
  public List<IDrawObject> getObjects() {
    return objs;
  }
}
