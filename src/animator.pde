/**
 * based on 
 * Yellowtail by Golan Levin (www.flong.com). 
*/

import java.awt.Polygon;
import java.util.Vector;

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

int playTimer = 0;

int currentMotionEvent = 0;
int currentKey = 0;
int currentMouseX = 0;
int currentMouseY = 0;
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

Vector motionEvents;

XML xml;

void setup() {
  size(1024, 768, P2D);
  background(255, 255, 255);
  noStroke();

  motionEvents = new Vector();
  motionEvents.clear();

  xml = loadXML("ss.xml");
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

  currentGestureID = -1;
  gestureArray = new Gesture[nGestures];
  for (int i = 0; i < nGestures; i++) {
    gestureArray[i] = new Gesture(width, height);
  }
  clearGestures();
}


boolean cleared = false;

void draw() {
  int startmillis = millis();
  
  
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
  
  if (play == 1 && currentMotionEvent == motionEvents.size()) {
    play = -1;
    currentMotionEvent = 0;
    playTimer = 0;
  }

  
//  background(255);
  if (cos(playTimer*0.01) > 0.5 && !cleared) { cleared=true; noStroke(); fill(255,255,255,32); rect(0,0,width,height); }
  if (cos(playTimer*0.01) < 0.5 && cleared) { cleared=false; }

  updateGeometry();
  noFill();
  for (int i = 0; i < nGestures; i++) {
    float br = 1.0f+cos(playTimer*0.001+i*0.01)*0.5f;
    stroke(112*br, 11, 149*br,100);
    renderGesture(gestureArray[i], width, height);
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

    
  
  if (play == 1 || record == 1) {
    playTimer+=delta;
  }
}

void mousePressed() {
  mousePressedHandler(mouseX, mouseY);
}

void mousePressedHandler(int mx, int my) {
  if (record == 1) {
    MotionEvent me = new MotionEvent(1,mx,my,playTimer);
    motionEvents.add(me);
  }
  currentGestureID = (currentGestureID+1) % nGestures;
  Gesture G = gestureArray[currentGestureID];
  G.clear();
  G.clearPolys();
  G.addPoint(mx, my);
}

void mouseDragged() {
  mouseDraggedHandler(mouseX, mouseY);
}

void mouseDraggedHandler(int mx, int my) {
    if (record == 1) {
    MotionEvent me = new MotionEvent(2,mx,my,playTimer);
    motionEvents.add(me);
  }

  if (currentGestureID >= 0) {
    Gesture G = gestureArray[currentGestureID];
    if (G.distToLast(mx, my) > minMove) {
      G.addPoint(mx, my);
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
      gestureArray[currentGestureID].thickness = min(96, th+1);
      gestureArray[currentGestureID].compile();
    }
  } else if (kk == '-') {
    if (currentGestureID >= 0) {
      float th = gestureArray[currentGestureID].thickness;
      gestureArray[currentGestureID].thickness = max(2, th-1);
      gestureArray[currentGestureID].compile();
    }
  } else if (kk == ' ') {
    background(255,255,255,32);
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
    }
    if (record == 1) {
        motionEvents.clear();
        clearGestures();
        background(255,255,255,255);
        currentMotionEvent = 0;
        animate = -1;
        play = -1;
        playTimer = 0;
    }
    return;
  } else if (kk == 'p') {
    record = -1;
    play=-play;
    playTimer = 0;
    if (play == 1) {
      currentMotionEvent = 0;
      animate = -1;
      clearGestures();
      background(255,255,255,255);
    }
    return;
  } else if (kk == 'd' && play == 1) {
    dumping = true;
  }

  if (record == 1) {
    MotionEvent me = new MotionEvent(0,kk,playTimer);
    motionEvents.add(me);
  }

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
