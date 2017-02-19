import peasy.test.*;
import peasy.org.apache.commons.math.*;
import org.apache.commons.lang3.builder.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;
import java.util.UUID;
import java.util.LinkedHashSet;

int overAllCount = 0;
PShape sWall;
PeasyCam cam;
PVector Mouse;
WallList WallSystem = new WallList();

boolean lights = false;
boolean testConnect = false;
boolean fullDraw = false;
boolean pffff = true;
boolean letFloat = false;
int duration = 20;
boolean drawGraph = false;
XML tempXML; 
boolean showConnected = false;
int     showWallConn  = 0;

void setup() {
  tempXML = loadXML("map.xml");
  Mouse = new PVector(0, 0, 0);
  size(1000, 1000, P3D);
  cp5 = new ControlP5(this);

  // by calling function addControlFrame() a
  // new frame is created and an instance of class
  // ControlFrame is instanziated.
  cf = addControlFrame("extra", 200, 200);
  sWall = loadShape("test.obj");
  cam = new PeasyCam(this, 0, 0, 100, 600);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2000);
  for (int i = 0; i<30; i++) {
    for (int j = 0; j<30; j++) {
      Wall w = new Wall(new PVector(90+j*3, 90+i*3, 0), new PVector(3, 0, 0), new PVector(0, 3, 0));
      w.Target = PVector.add(w.center(), new PVector(0, 0, 230));
      //w.setSpeed(random(0.05,0.11));
      WallSystem.add(w, true);
    }
    //WallSystem.setSubGraphs();
    WallSystem.MyMap = new Map(tempXML);
  }
  frameRate(30);
  //wall2.translate(new PVector(300,300,0));
}


void draw() {
  if (mousePressed == true) {
    Mouse = new PVector((float)mouseX-500, (float)mouseY-500, 0.0);
    Mouse.mult(1/500.0);
    Mouse.limit(0.005);
  }

  //WallSystem.shuffle();
  if (lights) {
    lights();
  }
  background(150);
  // w.draw();
  WallSystem.run();
  if (keyPressed) {
    if (key=='h') {
      WallSystem.drawPast();
    }
  }
  // WallSystem.drawMoveCenter();
  WallSystem.drawMe(fullDraw);

  if (frameCount%30==0) {
    println(frameRate);
    //println(WallSystem.nextWalls);
    println("Anzahl der Waende "+WallSystem.size()+" und als Nodes "+WallSystem.nodes.size() + ". Dazu sind "+ WallSystem.EdgeCount() + " Edges vorhanden.");
  }
  Mouse = new PVector(0, 0, 0);
  
  PVector c = WallSystem.getAllNodes().get(50).center();
  PVector d = WallSystem.getAllNodes().get(50).velocity;

  line(0,0,0,c.x,c.y,c.z);
  line(0,0,0,d.x,d.y,d.z);
}

void dur(int i) {
  duration+=i;
  if (duration<2) {
    duration=2;
  }
}
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {

      dur(1);
      println(duration);
    } else if (keyCode == DOWN) {
      dur(-1);
      println(duration);
    } else if (keyCode == LEFT) {
      showWallConn--;
      if (showWallConn<-1) {
        showWallConn=WallSystem.size()-1;
      }
      println(duration);
    } else if (keyCode == RIGHT) {
      showWallConn++;
      if (showWallConn==WallSystem.size()-1) {
        showWallConn=0;
      }
    }
  } else if (key == 'o') {
    pffff = true;
  } else if (key == 'l') {
    pffff = false;
  } else if (key=='c'&&!testConnect) {
    testConnect = true;
  } else if (key=='c'&&testConnect) {
    testConnect = false;
  } else if (key=='s'&&!lights) {
    lights=true;
  } else if (key=='s'&&lights) {
    lights=false;
  } else if (key=='a') {
    WallSystem.add(new Wall(new PVector(0, 0, 0), new PVector(3, 0, 0), new PVector(0, 3, 0)), true);
  } else if (key=='d') {
    WallSystem.remove(WallSystem.size()-1);
  } else if (key=='q'&&!showConnected) {
    showConnected=true;
    println("Wir zeigen ihnen hiermit alle Waende, die mit Wand "+str(showWallConn)+" verbunden sind");
  } else if (key=='q'&&showConnected) {
    showConnected=false;
  } else if (key=='g'&&!drawGraph) {
    drawGraph=true;
  } else if (key=='g'&&drawGraph) {
    drawGraph=false;
  }
}

