/**
 * ControlP5 Controlframe
 * with controlP5 2.0 all java.awt dependencies have been removed
 * as a consequence the option to display controllers in a separate
 * window had to be removed as well. 
 * this example shows you how to create a java.awt.frame and use controlP5
 *
 * by Andreas Schlegel, 2012
 * www.sojamo.de/libraries/controlp5
 *
 */

import java.awt.Frame;
import java.awt.BorderLayout;
import controlP5.*;

private ControlP5 cp5;

ControlFrame cf;

int SepMult = 50;
int CohMult = 50;
int AliMult = 50;

ControlFrame addControlFrame(String theName, int theWidth, int theHeight) {
  Frame f = new Frame(theName);
  ControlFrame p = new ControlFrame(this, theWidth, theHeight);
  f.add(p);
  p.init();
  f.setTitle(theName);
  f.setSize(p.w, p.h);
  f.setLocation(100, 100);
  f.setResizable(false);
  f.setVisible(true);
  return p;
}


// the ControlFrame class extends PApplet, so we 
// are creating a new processing applet inside a
// new frame with a controlP5 object loaded
public class ControlFrame extends PApplet {

  int w, h;

  int abc = 100;

  public void setup() {
    size(w, h);
    frameRate(25);
    cp5 = new ControlP5(this);
    cp5.addSlider("Cohesion").plugTo(parent, "CohMult").setRange(0, 200).setPosition(10, 30);
    cp5.addSlider("Seperation").plugTo(parent, "SepMult").setRange(0, 200).setPosition(10, 60);
    cp5.addSlider("Alignment").plugTo(parent, "AliMult").setRange(0, 200).setPosition(10, 90);
    cp5.addSlider("maxForce").plugTo(parent, "maxForce").setRange(1, 20).setPosition(10, 120);
  }

  public void draw() {
    background(abc);
  }

  private ControlFrame() {
  }

  public ControlFrame(Object theParent, int theWidth, int theHeight) {
    parent = theParent;
    w = theWidth;
    h = theHeight;
  }


  public ControlP5 control() {
    return cp5;
  }


  ControlP5 cp5;

  Object parent;
}

