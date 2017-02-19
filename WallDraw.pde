class WallType {
  float size;
  PVector O;
  PVector U;
  PVector V;
  PVector W;
  float[][][] simpleWall = {
    {
      {
        0.05, 0.05, 0
      }
      , {
        0.95, 0.05, 0
      }
      , {
        0.95, 0.95, 0
      }
      , {
        0.05, 0.95, 0
      }
      , {
        0.05, 0.05, 0
      }
    }
  }
  ;

  WallType(PVector tO, PVector tU, PVector tV) {
    this.size = tU.mag();

    this.O = tO.get();
    this.U = tU.get();
    this.V = tV.get();
    this.U.normalize();
    this.V.normalize();
    this.W = this.U.cross(this.V);
  }

  PVector changeBase(PVector p) {
    PVector newPx = PVector.mult(this.U, p.x);
    PVector newPy = PVector.mult(this.V, p.y);
    PVector newPz = PVector.mult(this.W, p.z);
    PVector newP = PVector.add(newPx, PVector.add(newPy, newPz));
    //newP.mult(this.size);
    return PVector.add(O, newP);
  }

  PVector changeBase(float[] p) {
    PVector in = new PVector(0, 0, 0);
    in.set(p);
    return changeBase(in);
  }

  void draw(PShape Geo) {
    pushStyle();
    noStroke();
    for (int j = 0; j<Geo.getChildCount (); j++) {
      beginShape();
      PShape face = Geo.getChild(j); 
      for (int i = 0; i<face.getVertexCount (); i++) {
        PVector cp = new PVector(0, 0, 0);
        cp.set(face.getVertex(i));

        //hardcoded, because obj is setting a new origin
        // cp.add(new PVector(0.1, 0.1, -0.075/2.0));
        cp = this.changeBase(cp);

        vertex(cp.x, cp.y, cp.z);
      }
      endShape();
    }
    popStyle();
  }
  void easyDraw(Wall dWall) {
    WallCP CP = new WallCP(dWall);
    CP.draw();   
  }
}

