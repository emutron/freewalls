import javax.swing.*;
import java.awt.Polygon;
import java.awt.Component;

class Map {
  bound3D bounds;
  Polygon2D[] buildings;

  Map() {
    bounds = new bound3D(new PVector(-500, -500, 0), new PVector(500, 500, 10));
  }
  Map(XML buildings) {
    this.buildings = build(buildings);
    bounds = new bound3D(new PVector(-2000, -2000, 0), new PVector(2000, 2000, 800));
  }

  boolean isInMap(PVector in) {
    return bounds.isInBounds(in);
  }
  boolean isInMap(Wall in) {
    return isInMap(in.center());
  }
  void draw() {
    PVector s = bounds.start;
    PVector e = bounds.end;
    pushMatrix();
    translate(0, 0, -5);
    pushStyle();
    fill(100);
    beginShape();
    vertex(s.x, s.y, s.z);
    vertex(e.x, s.y, s.z);
    vertex(e.x, e.y, s.z);
    vertex(s.x, e.y, s.z);
    vertex(s.x, s.y, s.z);
    endShape();
    popStyle();
    popMatrix();
  }

  private Polygon2D[] build(XML TempLoad) {
    if (TempLoad.getChildCount() > 0) {
      //identification as polygon XML element
      if ( TempLoad.getChild(1).hasAttribute("kind") ) {   //replaced getStringAttribute("kind").equals by hasAttribute
        if (TempLoad.getChild(1).getString("kind").equals("Polygons")) {
          XML[] TempLL = TempLoad.getChildren();
          Polygon2D[] ret = new Polygon2D[TempLL.length-2];
          XML[] PPOINTS;

          for (int i = 1; i < TempLL.length; i++) {    //ausnahme hinzufuegen. code nur ausfuehren, wenn das child ein "polygon" ist!!
            if (TempLL[i].getName().equals("Poly")) {
              PPOINTS = TempLL[i].getChildren();

              int pf = 1;
              float[] x = new float[PPOINTS.length/2];
              float[] y = new float[PPOINTS.length/2];

              for (int ip = 0; ip < PPOINTS.length; ip++ ) {

                if (PPOINTS[ip].getName().equals("P")) {
                  int index = (ip - 1)/2;
                  x[index] = (float) PPOINTS[ip].getFloat("X");
                  y[index] = (float) PPOINTS[ip].getFloat("Y");
                }
              }
              ret[i-1] = (Polygon2D) new Polygon2D(x, y, x.length);
            }
          }
          ArrayList removed;
          removed = new ArrayList();
          for (int i = ret.length-1; i >= 0; i--) {
            if (ret[i] != null) {
              removed.add(ret[i]);
            }
          }


          Polygon2D[] out = new Polygon2D[removed.size()];
          for (int i = removed.size ()-1; i >= 0; i--) {
            Polygon2D po = (Polygon2D) removed.get(i);
            out[i] = po;
          }
          //Polygon[] ba = removed.toArray(new Polygon[0]);
          return out;
        }
      }
    }
    return new Polygon2D[0];
  }

  public void display() { 
    pushStyle();
    fill(0);
    stroke(0);
    for (int i = 0; i < buildings.length; i++) {
      beginShape(); 
      for (int ip = 0; ip < buildings[i].npoints; ip++) {
        vertex(buildings[i].xpoints[ip], buildings[i].ypoints[ip]);
      }
      endShape(CLOSE);
    }
    popStyle();
  }
}


class bound3D {
  PVector start;
  PVector end;

  bound3D(PVector newStart, PVector newEnd) {
    start=newStart;
    end=newEnd;
  }
  boolean isInBounds(PVector in) {
    boolean x = in.x <= end.x &&  in.x >= start.x;
    boolean y = in.y <= end.y &&  in.y >= start.y;
    boolean z = in.z <= end.z &&  in.z >= start.z;
    return x&&y&&z;
  }
}

