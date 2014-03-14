/**
 * based on 
 * Yellowtail by Golan Levin (www.flong.com) 
 * add. code by visy (vp79799@gmail.com)
*/

/*
  @pjs preload="bar1-1080.png";
       crisp="true";
*/

// demo stuff

import ddf.minim.*;
AudioPlayer player;
Minim minim;

PImage bar1_bg;

////// animator

//import codeanticode.tablet.*;
//Tablet tablet;

class Polygon {

  public int npoints;
  public int[] xpoints;
  public int[] ypoints;

   public Polygon()
   {
     // Leave room for growth.
     xpoints = new int[4];
     ypoints = new int[4];
   } 
  
   public Polygon(int[] xpoints, int[] ypoints, int npoints)
   {
      this.xpoints = new int[npoints];
      this.ypoints = new int[npoints];
      
      for (int i = 0; i < npoints; i++) {
        this.xpoints[i] = xpoints[i];
        this.ypoints[i] = ypoints[i];
      }
      
      this.npoints = npoints;
   }
   
   
}



float gestureRotation[];
Gesture gestureArray[];
final int nGestures = 36;  // Number of gestures
final int minMove = 3;     // Minimum travel for a new point
int currentGestureID;

Polygon tempP;
int tmpXp[];
int tmpYp[];
int animate = -1;
int record = -1;
int play = 1;
int zoom = -1;
int recordStartTime = 0;
int playStartTime = 0;
int recordTimer = 0;
int playTimer = 0;

int currentMotionEvent = 0;
int currentKey = 0;
int currentMouseX = 0;
int currentMouseY = 0;
int currentColor = 1;
boolean dumping = false;


class MotionEvent {
  int type; // 0 = keypressed, 1 = mousepressed, 2 = mousedragged
  int ex;
  int ey;
  int keycode;
  int timestamp;

  MotionEvent(int t, int x, int y, int kk, int ts) {
    type = t;
    ex = x;
    ey = y;
    keycode = kk;
    timestamp = ts;
  } 
 
  MotionEvent(int t, int x, int y, int ts) {
    type = t;
    ex = x;
    ey = y;
    timestamp = ts;
  } 
  MotionEvent(int t, int k, int ts) {
    type = t;
    keycode = k;
    timestamp = ts;
  } 
};

ArrayList<MotionEvent> motionEvents;

XML xml;

void setup() {
  minim = new Minim(this);
  player = minim.loadFile("music.mp3", 2048);

  // DEMO GFX
  bar1_bg = loadImage("bar1-1080.png");
  
  // WINDOW / SCREEN SETUP

  size(1920, 1080, P3D);
  background(255, 255, 255);
  noStroke();
  noSmooth();

  //tablet = new Tablet(this); 

  motionEvents = new ArrayList<MotionEvent>();
  motionEvents.clear();
/*
  xml = loadXML("motionevents.xml");
  XML[] events = xml.getChildren("MotionEvent");
  if (events.length > 0) {
    for (int i = 0; i < events.length; i++) {
      String cont = events[i].getContent();
      String[] content = cont.split(",");
      MotionEvent me = new MotionEvent(Integer.parseInt(content[0]),
                                       Integer.parseInt(content[1]),
                                       Integer.parseInt(content[2]),
                                       Integer.parseInt(content[3]),
                                       Integer.parseInt(content[4]));
                                       
      motionEvents.add(me);                                       
    }
  }

*/
  currentGestureID = -1;
  gestureArray = new Gesture[nGestures];
  gestureRotation = new float[nGestures];
  for (int i = 0; i < nGestures; i++) {
    gestureArray[i] = new Gesture(width, height);
    gestureRotation[i] = 0.0f;
  }
  clearGestures();
      fill(0,255,0);
      noStroke();
      ellipse(width-16,16,8,8);


  player.play();
}

void stop() {
  player.close();
  minim.stop();
  super.stop();
}

boolean cleared = false;

float bg_x;
float bg_y;

void drawBG() {
  tint(255,10);
  bg_x = cos(millis()*0.001)*width/256;
  bg_y = sin(millis()*0.001)*width/256;
  image(bar1_bg,bg_x,bg_y);
  tint(255,255);
}

int frame = 0;

void draw() {
  frame++;
  //if (frame % 100 == 0) drawBG();
  drawBG();
  // animator
  
  int startmillis = millis();
  playTimer = millis()-playStartTime;
  recordTimer = millis()-recordStartTime;
  
  if (play == 1 && currentMotionEvent < motionEvents.size()) {
    MotionEvent me = (MotionEvent)motionEvents.get(currentMotionEvent);
    if (playTimer >= me.timestamp) {
      currentMotionEvent++;
      switch(me.type) {
        case 0:
          keyPressedHandler(me.keycode);
          break;        
        case 1:
          mousePressedHandler(me.ex, me.ey);
          break;        
        case 2:
          mouseDraggedHandler(me.ex, me.ey);
          break;        
      }
    } 
  }
  
  if (play == 1 && currentMotionEvent >= motionEvents.size()) {
    play = -1;
    currentMotionEvent = 0;
    playTimer = 0;
   // background(255,255,255,255);
  }

  
//  background(255);
//  if (cos(playTimer*0.01) > 0.5 && !cleared) { cleared=true; noStroke(); fill(255,255,255,32); rect(0,0,width,height); }
//  if (cos(playTimer*0.01) < 0.5 && cleared) { cleared=false; }

  updateGeometry();
  //noFill();

  noStroke();
  //stroke(128+cos(millis()*0.0001)*64,128+cos(millis()*0.00005)*64,128+sin(millis()*0.0001)*64,200);
  for (int i = 0; i < nGestures; i++) {
    pushMatrix();
    translate(bg_x,bg_y);
    //rotate(gestureRotation[i]*cos(i));
    //gestureRotation[i]+=0.01f*cos(millis()*0.001)*0.2;
    renderGesture(gestureArray[i], width, height);
    popMatrix();
  }

//  noFill();
//  for (int i = 0; i < nGestures; i++) {
//    stroke(0,0,0,255);
//    renderGesture(gestureArray[i], width, height);
//  }
  int endmillis = millis();

  int delta = endmillis-startmillis;
  
  if (dumping) { 
    delta = 100;
    saveFrame("dump-######.png");
  }

}

void showhelp() {
    return;
}

void mousePressed() {
  mousePressedHandler(mouseX, mouseY);
}

void mousePressedHandler(int mx, int my) {
  if (record == 1) {
    MotionEvent me = new MotionEvent(1,mx,my,recordTimer);
    motionEvents.add(me);
  }

  
  currentGestureID = (currentGestureID+1) % nGestures;
  gestureRotation[currentGestureID] = 0;
/*
  if (currentGestureID >= 0) {
    float th = gestureArray[currentGestureID].thickness;
    gestureArray[currentGestureID].thickness = 80*tablet.getPressure();
    gestureArray[currentGestureID].compile();
  }
*/
  Gesture G = gestureArray[currentGestureID];
  G.clear();
  G.clearPolys();
  G.addPoint(mx, my, currentColor);
}

void mouseDragged() {
  mouseDraggedHandler(mouseX, mouseY);
}

void mouseDraggedHandler(int mx, int my) {
    if (record == 1) {
    MotionEvent me = new MotionEvent(2,mx,my,recordTimer);
    motionEvents.add(me);
  }

  if (currentGestureID >= 0) {
    Gesture G = gestureArray[currentGestureID];
    if (G.distToLast(mx, my) > minMove) {
      G.addPoint(mx, my, currentColor);
      G.smooth();
      G.compile();
    }
  }

}

void keyPressed() {
  keyPressedHandler(key);
}

void keyPressedHandler(int kk) {
  if (kk == '+' || kk == '=') {
    if (currentGestureID >= 0) {
      float th = gestureArray[currentGestureID].thickness;
      gestureArray[currentGestureID].thickness = min(96, th+4);
      gestureArray[currentGestureID].compile();
    }
  } else if (kk == '-') {
    if (currentGestureID >= 0) {
      float th = gestureArray[currentGestureID].thickness;
      gestureArray[currentGestureID].thickness = max(2, th-4);
      gestureArray[currentGestureID].compile();
    }
  } else if (kk == ' ') {
    background(255,255,255,32);
    showhelp();

    if (play == 1 && record == -1) {
      
      fill(0,255,0);
      noStroke();
      ellipse(width-16,16,8,8);

    }

    if (record == 1 && play == -1) {
      fill(255,0,0);
      noStroke();
      ellipse(width-16,16,8,8);
    }
  } else if (kk == 's') {
    clearGestures();
  } else if (kk == 'x') {
    if (motionEvents.size() == 0) return;
    // export animation to xml
    for (int i = 0; i < motionEvents.size(); i++) {
      MotionEvent me = (MotionEvent)motionEvents.get(i);
      XML newchild = xml.addChild("MotionEvent");
      String str = "" + me.type + "," + me.ex + "," + me.ey + "," + me.keycode + "," + me.timestamp; 
      newchild.setContent(str);      
    }
    saveXML(xml, "scratch.xml");
    return;
  } else if (kk == 'a') {
    animate=-animate;
  } else if (kk == 'r') {
    record=-record;
    if (record == -1) {
      currentMotionEvent = 0;
      animate = -1;
      play = -1;
      playTimer = 0;
      background(255,255,255,255);
      showhelp();
    }
    if (record == 1) {
        recordStartTime = millis();
        motionEvents.clear();
        clearGestures();
        background(255,255,255,255);
        fill(255,0,0);
        noStroke();
        ellipse(width-16,16,8,8);
        currentMotionEvent = 0;
        animate = -1;
        play = -1;
        playTimer = 0;
        return;

    }
  } else if (kk == 'z') {
    zoom = -zoom;
  } else if (kk == 'p') {
    record = -1;
    play=-play;
    playTimer = 0;
    if (play == 1) {
      currentMotionEvent = 0;
      animate = -1;
      clearGestures();
      background(255,255,255,255);
      fill(0,255,0);
      noStroke();
      ellipse(width-16,16,8,8);
      playStartTime = millis();
    } else {
      fill(255,255,255);
      noStroke();
      ellipse(width-16,16,10,10);
    }
    return;
  } else if (kk == 'd' && play == 1) {
    dumping = true;
  } else if (kk >= '1' || kk <= '9') {
    currentColor = kk-48;
  } else if (kk == 'v') {
    currentColor = -1;
  }
  if (record == 1) {
    MotionEvent me = new MotionEvent(0,kk,recordTimer);
    motionEvents.add(me);
  }

}

boolean sketchFullScreen() {
  return true;
}

void renderGesture(Gesture gesture, int w, int h) {
  if (gesture.exists) {
    if (gesture.nPolys > 0) {
      Polygon polygons[] = gesture.polygons;
      int crosses[] = gesture.crosses;

      int xpts[];
      int ypts[];
      Polygon p;
      int cr;
      int myColor = gesture.colors[0];
    
      float a = 150;
    
//      if (play == 1) myColor = currentColor;
      if (myColor == 0) fill(0,148,118,a);
      else if (myColor == 1) fill(75,183,255,a);
      else if (myColor == 2) fill(0,17,204,a);
      else if (myColor == 3) fill(217,181,158,a);
      else if (myColor == 4) fill(181,255,96,a);
      else if (myColor == 5) fill(170,0,153,a);
      else if (myColor == 6) fill(30,252,252,a);
      else if (myColor == 7) fill(249,246,37,a);
      else if (myColor == 8) fill(249,37,51,a);
      else if (myColor == 9) fill(255,255,255,a);
      else if (myColor == -1) fill(255,255,255,a);
      else fill(0,0,0,a);

      beginShape(QUADS);
      int gnp = gesture.nPolys;
      for (int i=0; i<gnp; i++) {

        p = polygons[i];
        xpts = p.xpoints;
        ypts = p.ypoints;

        vertex(xpts[0], ypts[0]);
        vertex(xpts[1], ypts[1]);
        vertex(xpts[2], ypts[2]);
        vertex(xpts[3], ypts[3]);

        if ((cr = crosses[i]) > 0) {
          if ((cr & 3)>0) {
            vertex(xpts[0]+w, ypts[0]);
            vertex(xpts[1]+w, ypts[1]);
            vertex(xpts[2]+w, ypts[2]);
            vertex(xpts[3]+w, ypts[3]);

            vertex(xpts[0]-w, ypts[0]);
            vertex(xpts[1]-w, ypts[1]);
            vertex(xpts[2]-w, ypts[2]);
            vertex(xpts[3]-w, ypts[3]);
          }
          if ((cr & 12)>0) {
            vertex(xpts[0], ypts[0]+h);
            vertex(xpts[1], ypts[1]+h);
            vertex(xpts[2], ypts[2]+h);
            vertex(xpts[3], ypts[3]+h);

            vertex(xpts[0], ypts[0]-h);
            vertex(xpts[1], ypts[1]-h);
            vertex(xpts[2], ypts[2]-h);
            vertex(xpts[3], ypts[3]-h);
          }

          // I have knowingly retained the small flaw of not
          // completely dealing with the corner conditions
          // (the case in which both of the above are true).
        }
      }
      endShape();
    }
  }
}

void updateGeometry() {
  Gesture J;
  for (int g=0; g<nGestures; g++) {
    if ((J=gestureArray[g]).exists) {
      if (g!=currentGestureID) {
        if (animate == 1) advanceGesture(J);
      } else if (!mousePressed) {
        if (animate == 1) advanceGesture(J);
      }
    }
  }
}

void advanceGesture(Gesture gesture) {
  // Move a Gesture one step
  if (gesture.exists) { // check
    int nPts = gesture.nPoints;
    int nPts1 = nPts-1;
    Vec3f path[];
    float jx = gesture.jumpDx;
    float jy = gesture.jumpDy;

    if (nPts > 0) {
      path = gesture.path;
      for (int i = nPts1; i > 0; i--) {
        path[i].x = path[i-1].x;
        path[i].y = path[i-1].y;
      }
      path[0].x = path[nPts1].x - jx;
      path[0].y = path[nPts1].y - jy;
      gesture.compile();
    }
  }
}

void clearGestures() {
  for (int i = 0; i < nGestures; i++) {
    gestureArray[i].clear();
  }
}
class Gesture {

  float  damp = 5.0;
  float  dampInv = 1.0 / damp;
  float  damp1 = damp - 1;

  int w;
  int h;
  int capacity;
  int c;

  Vec3f path[];
  int crosses[];
  Polygon polygons[];
  int colors[];
  int nPoints;
  int nPolys;

  float jumpDx, jumpDy;
  boolean exists;
  float INIT_TH = 14;
  float thickness = INIT_TH;

  Gesture(int mw, int mh) {
    w = mw;
    h = mh;
    capacity = 600;
    path = new Vec3f[capacity];
    polygons = new Polygon[capacity];
    colors = new int[capacity];    
    crosses  = new int[capacity];
    for (int i=0;i<capacity;i++) {
      polygons[i] = new Polygon();
      polygons[i].npoints = 4;
      path[i] = new Vec3f();
      crosses[i] = 0;
      colors[i] = 0;
    }
    nPoints = 0;
    nPolys = 0;

    exists = false;
    jumpDx = 0;
    jumpDy = 0;
  }

  void clear() {
    nPoints = 0;
    exists = false;
    thickness = INIT_TH;
  }

  void clearPolys() {
    nPolys = 0;
  }

  void addPoint(float x, float y, int color1) {

    if (nPoints >= capacity) {
      // there are all sorts of possible solutions here,
      // but for abject simplicity, I don't do anything.
    } 
    else {
      float v = distToLast(x, y);
      float p = getPressureFromVelocity(v)*1.1;
      colors[nPoints] = color1;
      path[nPoints++].set(x,y,p,color1);
      if (nPoints > 1) {
        exists = true;
        jumpDx = path[nPoints-1].x - path[0].x;
        jumpDy = path[nPoints-1].y - path[0].y;
      }
    }

  }

  float getPressureFromVelocity(float v) {
    final float scale = 18;
    final float minP = 0.02;
    final float oldP = (nPoints > 0) ? path[nPoints-1].p : 0;
    return ((minP + max(0, 1.0 - v/scale)) + (damp1*oldP))*dampInv;
  }

  void setPressures() {
    // pressures vary from 0...1
    float pressure;
    Vec3f tmp;
    float t = 0;
    float u = 1.0 / (nPoints - 1)*TWO_PI;
    for (int i = 0; i < nPoints; i++) {
      pressure = sqrt((1.0 - cos(t))*0.5);
      path[i].p = pressure;
      t += u;
    }
  }

  float distToLast(float ix, float iy) {
    if (nPoints > 0) {
      Vec3f v = path[nPoints-1];
      float dx = v.x - ix;
      float dy = v.y - iy;
      return mag(dx, dy);
    } 
    else {
      return 30;
    }
  }

  void compile() {
    // compute the polygons from the path of Vec3f's
    if (exists) {
      clearPolys();

      Vec3f p0, p1, p2;
      float radius0, radius1;
      float ax, bx, cx, dx;
      float ay, by, cy, dy;
      int   axi, bxi, cxi, dxi, axip, axid;
      int   ayi, byi, cyi, dyi, ayip, ayid;
      float p1x, p1y;
      float dx01, dy01, hp01, si01, co01;
      float dx02, dy02, hp02, si02, co02;
      float dx13, dy13, hp13, si13, co13;
      float taper = 1.0;

      int  nPathPoints = nPoints - 1;
      int  lastPolyIndex = nPathPoints - 1;
      float npm1finv =  1.0 / max(1, nPathPoints - 1);

      // handle the first point
      p0 = path[0];
      p1 = path[1];
      radius0 = p0.p * thickness;
      dx01 = p1.x - p0.x;
      dy01 = p1.y - p0.y;
      hp01 = sqrt(dx01*dx01 + dy01*dy01);
      if (hp01 == 0) {
        hp02 = 0.0001;
      }
      co01 = radius0 * dx01 / hp01;
      si01 = radius0 * dy01 / hp01;
      ax = p0.x - si01; 
      ay = p0.y + co01;
      bx = p0.x + si01; 
      by = p0.y - co01;

      int xpts[];
      int ypts[];

      int LC = 20;
      int RC = w-LC;
      int TC = 20;
      int BC = h-TC;
      float mint = 0.618;
      float tapow = 0.4;

      // handle the middle points
      int i = 1;
      Polygon apoly;
      for (i = 1; i < nPathPoints; i++) {
        taper = pow((lastPolyIndex-i)*npm1finv,tapow);

        p0 = path[i-1];
        p1 = path[i  ];
        p2 = path[i+1];
        p1x = p1.x;
        p1y = p1.y;
        radius1 = Math.max(mint,taper*p1.p*thickness);

        // assumes all segments are roughly the same length...
        dx02 = p2.x - p0.x;
        dy02 = p2.y - p0.y;
        hp02 = (float) Math.sqrt(dx02*dx02 + dy02*dy02);
        if (hp02 != 0) {
          hp02 = radius1/hp02;
        }
        co02 = dx02 * hp02;
        si02 = dy02 * hp02;

        // translate the integer coordinates to the viewing rectangle
        axi = axip = (int)ax;
        ayi = ayip = (int)ay;
        axi=(axi<0)?(w-((-axi)%w)):axi%w;
        axid = axi-axip;
        ayi=(ayi<0)?(h-((-ayi)%h)):ayi%h;
        ayid = ayi-ayip;

        // set the vertices of the polygon
        apoly = polygons[nPolys++];
        xpts = apoly.xpoints;
        ypts = apoly.ypoints;
        xpts[0] = axi = axid + axip;
        xpts[1] = bxi = axid + (int) bx;
        xpts[2] = cxi = axid + (int)(cx = p1x + si02);
        xpts[3] = dxi = axid + (int)(dx = p1x - si02);
        ypts[0] = ayi = ayid + ayip;
        ypts[1] = byi = ayid + (int) by;
        ypts[2] = cyi = ayid + (int)(cy = p1y - co02);
        ypts[3] = dyi = ayid + (int)(dy = p1y + co02);

        // keep a record of where we cross the edge of the screen
        crosses[i] = 0;
        if ((axi<=LC)||(bxi<=LC)||(cxi<=LC)||(dxi<=LC)) { 
          crosses[i]|=1; 
        }
        if ((axi>=RC)||(bxi>=RC)||(cxi>=RC)||(dxi>=RC)) { 
          crosses[i]|=2; 
        }
        if ((ayi<=TC)||(byi<=TC)||(cyi<=TC)||(dyi<=TC)) { 
          crosses[i]|=4; 
        }
        if ((ayi>=BC)||(byi>=BC)||(cyi>=BC)||(dyi>=BC)) { 
          crosses[i]|=8; 
        }

        //swap data for next time
        ax = dx; 
        ay = dy;
        bx = cx; 
        by = cy;
      }

      // handle the last point
      p2 = path[nPathPoints];
      apoly = polygons[nPolys++];
      xpts = apoly.xpoints;
      ypts = apoly.ypoints;

      xpts[0] = (int)ax;
      xpts[1] = (int)bx;
      xpts[2] = (int)(p2.x);
      xpts[3] = (int)(p2.x);

      ypts[0] = (int)ay;
      ypts[1] = (int)by;
      ypts[2] = (int)(p2.y);
      ypts[3] = (int)(p2.y);

    }
  }

  void smooth() {
    // average neighboring points

    final float weight = 18;
    final float scale  = 1.0 / (weight + 2);
    int nPointsMinusTwo = nPoints - 2;
    Vec3f lower, upper, center;

    for (int i = 1; i < nPointsMinusTwo; i++) {
      lower = path[i-1];
      center = path[i];
      upper = path[i+1];

      center.x = (lower.x + weight*center.x + upper.x)*scale;
      center.y = (lower.y + weight*center.y + upper.y)*scale;
    }
  }
}

class Vec3f {
  float x;
  float y;
  float p;  // Pressure
  int   c;  // Color

  Vec3f() {
    set(0, 0, 0);
    c = 0;
  }
  
  Vec3f(float ix, float iy, float ip) {
    set(ix, iy, ip);
    c = 0;
  }

  void set(float ix, float iy, float ip) {
    x = ix;
    y = iy;
    p = ip;
    c = 0;
  }

  void set(float ix, float iy, float ip, int ic) {
    x = ix;
    y = iy;
    p = ip;
    c = ic;
  }

}
