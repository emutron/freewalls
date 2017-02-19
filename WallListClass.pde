import java.util.Collections;

class WallList extends Graph {
  float nextWalls = 0;

  public Map MyMap = new Map();
  WallList() {
  }

  WallList(ArrayList<Wall> WallArray, boolean addEdges) {
    for (Wall w : WallArray) {
      addNode(w, addEdges);
    }
  }


  void add(Wall addWall, boolean addNewEdge) {
    addNode(addWall, addNewEdge);
  }

  void remove(int i) {

    // boolean r = removeNode(removeWall.ID());
  }
  void shuffle() {
    //Collections.shuffle(this.Walls);
  }
  public int size() {
    return nodes.size();
  }

  WallList getNearOthers(Wall wall, boolean before) {
    //a funktion, that gets the WallList, the index and sets only the near walls
    //of interest - in a certain radius
    WallList out = new WallList();
    out.MyMap=this.MyMap;
    for (Wall otherWall : nodes.values () ) {
      if (otherWall==wall && before) {
        //stops before the wall is taken into the arraylist
        break;
      }
      if (otherWall!=wall) {
        if (PVector.dist(otherWall.center(), wall.center())<wall.U.mag()*1.5) {
          out.add(otherWall, false);
        }
      }
    }
    return out;
  }
  WallList getOthers(Wall wall) {
    //a funktion, that gets the WallList, the index and sets only the near walls
    //of interest - in a certain radius
    WallList out = new WallList();
    out.MyMap=this.MyMap;
    for (Wall otherWall : nodes.values () ) {
      if (otherWall!=wall) {
        out.add(otherWall, false);
      }
    }
    return out;
  }

  void run() {
    int c = 0;
    for (Wall w : getAllNodes ()) {
      //others are a copy of this.Walls
      w.step(this);
      //setSubGraphs();
      c++;
    }
  }

  void drawMe(boolean fullDraw) {
    int c = 0;
    //MyMap.display();
    if (!drawGraph) {
      for (Wall w : nodes.values ()) {
        pushStyle();
        if (w.isWaiting>0) {
          fill(250, 200, 200);
        }
        if (w.isFixed) {
          fill(0, 200, 0);
        }
        if (w.distance()==0) {
          fill(200, 200, 255);
        }

        w.draw(fullDraw);
        popStyle();
        c++;
      }
    } else {
      draw();
    }
  }
  void drawMe() {
    for (Wall w : nodes.values ()) {
      WallCP CP = new WallCP(w);
      CP.draw();
    }
  }

  void drawMoveCenter() {
    for (Wall w : nodes.values ()) {
      w.drawMoveCenter();
    }
  }

  void drawPast() {
    for (Wall w : nodes.values ()) {
      w.drawPast();
    }
  }
  //this section is for the general Wall List - Boolean functions!
  //boolean isMyGroupGrounded
  
}

