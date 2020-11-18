class RockGenerator {
  int x, y, w, h, scale;
  float r;
  PImage rock, resized;
  
  // List of poisson points
  List<PVector> points = new ArrayList<PVector>();
  
  public RockGenerator(int x, int y, int w, int h, float r, int scale) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.r = r;
    this.scale = scale;
    rock = new PImage(w, h, ARGB);
    points = poisson(30);
  }
  
  // Generate the rock centre points for the whole screen
  public List<PVector> poisson(int k) {
    PVector initial = new PVector(x + random(w), y + random(h));
    
    List<PVector> active = new ArrayList<PVector>();
    
    // Grid to speed up collision checks
    //float size = rad / sqrt(2);
    //PVector[][] sampleGrid = new PVector[(int) ((float) w/size) + 1][(int) ((float) h/size) + 1];
    
    
    active.add(initial);
    points.add(initial);
    //sampleGrid[(int) ((initial.x)/size)][(int) ((initial.y)/size)] = initial;
    
    // while still points to process
    main: while (!active.isEmpty()) {
      int ind = (int) random(active.size());
      PVector picked = active.get(ind);  // Pick random
        //println(picked);
      
      outer : for (int i = 0; i < k; i++) {  // Try to place randomly k times in rad r to 2r from point
        PVector candidate = pickNext(picked, r);
        // If outside
        if (candidate.x < x || candidate.x > x+w || candidate.y < y || candidate.y > y+h) continue outer;
        
        //for (float a = max(0, candidate.x - rad); a < min(x + w, candidate.x + rad); a += size) {
        //  for (float b = max(0, candidate.y - rad); b < min(y + h, candidate.y + rad); b += size) {
        //    PVector other = sampleGrid[(int) (a/size)][(int) (b/size)] = initial;
        //    if (PVector.sub(candidate, other).magSq() < rad * rad) 
        //      continue outer;
        //  }
        //}
        // Check against other points
        for (PVector other : points) {
          if (PVector.sub(candidate, other).magSq() < r * r) 
            continue outer;
        }
        
        active.add(candidate);
        points.add(candidate);
        //sampleGrid[(int) ((initial.x)/size)][(int) ((initial.y)/size)] = initial;
        continue main;
      }
      active.remove(ind);
    }
    
    return points;
  }
  
  //ArrayList<PImage> images = new ArrayList<PImage>();
  
  public void updateTexture(AABB area) {
    println("Generating " + area);
    float rockRad = r * 1.7;
    // Creates image of area to render
    PImage areaSpr = new PImage((int) ceil(area.w + rockRad*2), (int) ceil(area.h + rockRad*2), ARGB);
    //PVector imageOrigin = new PVector(area.x - area.w/2 - rockRad, area.y - area.h/2 - rockRad);
    
    // Light angle
    PVector light = PVector.fromAngle(-PI/5);
    
    float shrink = 0;
    AABB centreArea = new AABB(area.x + shrink, area.y + shrink, area.w - 2*shrink, area.h - 2*shrink, null);
    
    // For each px, generate
    areaSpr.loadPixels();
    for (int x = (int) (area.x - area.w/2 - rockRad); x < (int) (area.x + area.w/2 + rockRad); x++) {
      for (int y = (int) (area.y - area.h/2 - rockRad); y < (int) (area.y + area.h/2 + rockRad); y++) {
        
        PVector v = new PVector(x, y);
        int closestInd = 0;
        float distSq = distSq(v, points.get(0));
        
        // Find closest rock centre, should be done with voranoi or simular
        for (int i = 0; i < points.size(); i++) {
          float newDist = distSq(v, points.get(i));
          if (newDist < distSq) {
            closestInd = i;
            distSq = newDist;
          }
        }
        
        //If within radius of rock, fill with rock, otherwise dirt/grass
        PVector centre = points.get(closestInd);
        if (centreArea.contains(centre)) {
          float cDist = centre.dist(v) + 2*noise(v.x, v.y);
          color c;
          // Fill with random dirt/grass colour
          if (cDist > r)c = lerpColor(color(60, 37, 25), color(19, 52, 16), noise(v.x/6, v.y/6, 23424));
          else {
            // Calculate grey from dist to centre and light angle
            float val = (1-(cDist / rockRad) + light.dot(PVector.sub(centre, v))/r)/2 - noise(v.x/4, v.y/4, 1432432);
            val = 64 + (val)*128;
            c = color(val, val, val);
          }
          try {  // Set px
          areaSpr.pixels[int(y - (area.y - area.h/2 - rockRad)) * areaSpr.width + int(x - (area.x - area.w/2 - rockRad))] = c;
          } catch (ArrayIndexOutOfBoundsException e) {
            println("ERROR", x, y);
          }
          //println(int(y - (area.y - area.h/2 - rockRad)), (x - (area.x - area.w/2 - rockRad)));
        }
        //} else if (area.contains(v) && area.contains(new PVector(v.x + 20*(noise(v.x/5, v.y/5, 1312321)-0.5)*2, v.y + 20*(noise(v.x/5, v.y/5, 768678)-0.5)*2))){
        //  float val = noise(v.x/4, v.y/4, 23423424);
        //  val = 64 + (val)*128;
        //    rock.pixels[y * w + x] = color(val, val, val);
        //}
      }
    }
    areaSpr.updatePixels();
    
    //for (int x = 0; x < areaSpr.width; x++)
    //  for (int y = 0; y < areaSpr.height; y++) 
    //    print(areaSpr.get(x, y), "   ");
    
    area.sprite = areaSpr;
    //images.add(areaSpr);
}
  
  
  
  
  
  public float distSq(PVector p1, PVector p2) {
    return PVector.sub(p1, p2).magSq();
  } 
  
  // Picks point within R and 2R of centre uniformly
  PVector pickNext(PVector centre, float R) {
    float rad = sqrt(1 + random(3)) * R;
    float angle = random(TWO_PI);
    return new PVector(centre.x + rad * cos(angle), centre.y + rad * sin(angle));
  }
}

// Upscales img
static public PImage generateResized(PImage source, int scale) {
  PImage dest = new PImage(source.width * scale, source.height * scale, ARGB);
  dest.loadPixels();
  source.loadPixels();
  for (int x = 0; x < dest.width; x++)
    for (int y = 0; y < dest.height; y++)
      dest.pixels[y * dest.width + x] = source.pixels[y / scale * (dest.width / scale) + x / scale];
  dest.updatePixels();
  return dest;
}












//class SpriteSheet {
//  PImage[] images = new PImage[32];
//  int width, height;
  
//  public SpriteSheet(String name, int w, int h) {
//    PImage main = loadImage(name + ".png");
//    this.width = w;
//    this.height = h;
    
//    int c = 0;
//    for (int j = 0; j < main.height; j += w) {
//      for (int i = 0; i < main.width; i += h) {
//        if (c >= images.length) break;
//        images[c++] = main.get(i, j, w, h);
//      }
//    }
    
//  }
  
//  public PImage render(int[][] map) {
//    PImage result = new PImage(width * map.length, height * map[0].length, ARGB);
    
//    for (int x = 0; x < map.length; x++) {
//      for (int y = 0; y < map[0].length; y++) {
//        PImage img = getImage(x, y, map);
//        if (img != null)
//          result.set(x*width, y*height, img);
//      }
//    }
    
    
//    return result;
//  }
  
//  public boolean get(int x, int y, int[][] map) {
//    if (x < 0 || x >= map.length || y < 0 || y >= map[0].length) return true;
//    return map[x][y] == 1;
//  }
  
  
//  public PImage getImage(int x, int y, int[][] map) {
//    boolean up = get(x, y-1, map), right = get(x+1, y, map), down = get(x, y+1, map), left = get(x-1, y, map), current = get(x, y, map);
    
//    if (current) {
//      int ind = toInt(up) * 1 + toInt(right) * 2 + toInt(down) * 4 + toInt(left) * 8;
//      if (ind == 3 && get(x+1, y-1, map)) ind = 16; // TL corner
//      else if (ind == 9 && get(x-1, y-1, map)) ind = 17; // TR corner
      
//      return images[ind];
//    }
    
//    return null;
//  }
  
//  public int toInt(boolean b) {
//    return b ? 1 : 0;
//  }

//}
