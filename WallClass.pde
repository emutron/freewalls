float maxForce = 1.0;

class Wall implements Comparable<Wall> {
  //this describes the current position
  PVector O;
  PVector U;
  PVector V;
  PVector W;

  //fields for rotation
  int Axis=0;
  float Angle=0;

  //fields for flocking
  PVector velocity=new PVector(0, 0, 30);
  PVector acceleration=new PVector(0, 0, 0);

  //fields for animations
  float maxSpeed = 0.1;
  float minSpeed = 0.05;

  protected UUID ID;

  boolean AlternerateWaiting = false;

  boolean isConnected = false;

  int Speed = 20;
  int Duration = Speed;
  int COUNT = 0;
  //for walking and climbing
  //sometimes we just wait.
  int isWaiting = 0;
  //when another one uses this wall for climbing
  //or another wall is fixed upon this on, true:
  boolean isFixed = false;
  boolean firstStep = false;
  //old positions
  ArrayList<Wall> oldPositions = new ArrayList<Wall>();
  int maxOldSize =10;
  ArrayList<Wall> futurePositions = new ArrayList<Wall>();
  //future positions
  //target
  PVector Target = new PVector(80+int(random(-10, 10))*20-200, 80+int(random(-10, 10))*20-200, 0);

  /**
   public Wall(Wall another)
   public Wall(PVector tempO, PVector tempU, PVector tempV)
   public Wall(WallCP CP)
   
   void setSpeed(float tSpeed)
   void setRandSpeed()
   void rotate(int tempAxis, float tempAngle)
   Wall rotate(Wall tempWall, int tempAxis, float tempAngle)
   void copyRotateSetOUV(int tempAxis, float tempAngle)
   void step(WallList others) 
   void setUV(WallCP tempCP)
   void setFuturePositions()
   void setValidFuturePositions(WallList others)
   void setValidFuturePositionsWithStatic(WallList others)
   void addOld()
   void randomWait()
   void setRandomNext()
   void update() 
   void setByVelocity()
   void setTargetNext()
   void roundValues()   
   void draw(boolean fullDraw) 
   void drawMoveCenter()
   void drawPast()
   void drawFuture()
   void translateWall(PVector translation)
   PVector[] getWallCP(Wall in)
   PVector[] getWallCP()
   
   public float distance()
   public PVector center()
   public PVector moveCenter()
   public int compareTo(Wall o) 
   @Override
   public int hashCode()
   @Override
   public boolean equals(Object obj) 
   boolean isOccupied(WallList others, Wall next)
   boolean isGrounded(WallList allOthers)
   boolean isOnGround()
   boolean isAxeConnected(Wall other, int Axe)
   boolean isSupported(WallList others)
   boolean isConnected(Wall other)
   WallList getConnected(WallList others)
   boolean[][] getConnectPoints(Wall other) 
   int[] getConnectionIndex(Wall other)
   int getConnectionCount(Wall other)
   PVector getVelocity()
   boolean isCurrentlyAWall()
   boolean isConnected(WallList others)
   boolean isOldPosition(Wall next)
   */
  public Wall(Wall another) {
    //copy constructor
    this.O = another.O.get();
    this.U = another.U.get();
    this.V = another.V.get();
    this.Angle = another.Angle *1.0;
    this.Axis  = int(another.Axis);
    this.Target = another.Target.get();
    this.Speed = another.Speed;
    this.Duration = another.Duration;
    this.ID = another.ID;
  }
  public Wall() {
  }

  public Wall(PVector tempO, PVector tempU, PVector tempV) {
    //basic constructor
    this.O = tempO.get();
    this.U = tempU.get();
    this.V = tempV.get();
    addOld(this);
    this.ID = UUID.randomUUID();
  }

  public Wall(WallCP CP) {
    this.O = CP.CP[0];
    this.U = PVector.sub(CP.CP[1], CP.CP[0]);
    this.V = PVector.sub(CP.CP[3], CP.CP[0]);
  }
  /**
   * Get the node ID 
   * @return the id
   */
  public UUID ID() {
    return ID;
  }

  /**
   * Change the node id. <br>
   * Care should be taken to ensure the new ID number is unique
   * @param id the id to set
   */
  public void ID(UUID ID) {
    this.ID = ID;
  }


  void setSpeed(float tSpeed) {
    if (tSpeed<minSpeed) {
      tSpeed=minSpeed;
    } else if (tSpeed>maxSpeed) {
      tSpeed=maxSpeed;
    }
    this.Duration = int(1.0/tSpeed);
  }
  void setRandSpeed() {
    int newSpeed = this.Duration+int(round(random(-1, 1)));
    setSpeed(1/(float)newSpeed);
  }

  void rotate(int tempAxis, float tempAngle) {
    WallCP tempWallCP = new WallCP(this);
    tempWallCP.rotate(tempAxis, tempAngle);
    //a function for setting o,u,v from a WallCP is needed
    this.setUV(tempWallCP);
  }

  Wall rotate(Wall tempWall, int tempAxis, float tempAngle) {
    //only needed for a basic step - n*0,5*PI
    Wall wallOut = new Wall(tempWall);
    wallOut.rotate(tempAxis, tempAngle);
    wallOut.roundValues();
    wallOut.Axis = tempAxis;  
    wallOut.Angle= tempAngle;
    return wallOut;
  }
  void copyRotateSetOUV(int tempAxis, float tempAngle) {
    Wall copyRWall = new Wall(oldPositions.get(oldPositions.size()-1));
    copyRWall.rotate(tempAxis, tempAngle);
    this.O = copyRWall.O;
    this.U = copyRWall.U;
    this.V = copyRWall.V;
  }

  Wall getNextPosition() {
    Wall next = new Wall();
    if (Angle==0&&Axis==0) {
      next = new Wall(this);
    } else if (futurePositions.size()==1) {
      next = futurePositions.get(0);
    }
    return next;
  }



  void step(WallList Walls) {
    if (COUNT == 0) {
      roundValues();
      //put the old one into the collection
      addOld(this);
      if (AlternerateWaiting) {
        isWaiting=1;
        AlternerateWaiting = false;
      } else {
        AlternerateWaiting = true;
      }
      setFuturePositions();
      //what to do if speeds are different? there should not be a problem.
      //this.randomWait();
      setValidFuturePositionsWithStatic(Walls);
      //setByVelocity();
      //>>>>>>>>>>><speed setting>>>>>>>>>>>>>><
      Speed = Duration;

      //choose some
      //      if (pffff) {
      //        setTargetNext();
      //      } else {
      //        setRandomNext();
      //      }
      setByVelocity(Walls);
      Walls.resetNode(this);
      COUNT++;
      firstStep = true;
    }

    setRandSpeed();
    //update();
    if (Duration!=Speed) {
      int newCount=0;
      while (newCount/float (Duration)<COUNT/float(Speed)) {
        newCount++;
      }
      COUNT=newCount;
      Speed=Duration;
    }
    //this method is for animating a step between the last old position and
    if (isWaiting==0) {
      copyRotateSetOUV(Axis, Animation.SQUAREINVR(COUNT, Speed) * Angle);
    }
    COUNT++;
    if (COUNT==Speed+1) {
      COUNT=0;
      isWaiting=0;
    }
  }


  void setUV(WallCP tempCP) {
    this.O = tempCP.CP[0];
    this.U = PVector.sub(tempCP.CP[1], tempCP.CP[0]);
    this.V = PVector.sub(tempCP.CP[3], tempCP.CP[0]);
  }

  void setFuturePositions() {
    futurePositions.clear();
    Wall nextWall;
    //add a future position for...
    for (int i = 0; i<4; i++) {
      //...every axis i ...
      for (int j = 1; j<3; j++) {
        //and for 0.5 and -0.5 ( int(cos(j*PI))*0.5) )
        Wall next = this.rotate(this, i, cos(j*PI)*0.5);
        next.ID = this.ID;
        futurePositions.add(next);
      }
    }
    //add a last position with axis and angle zero, NOT ANYMORE
    Wall next = this.rotate(this, 0, 0);
    next.ID = this.ID;
    futurePositions.add(next);
  }

  void setValidFuturePositions(WallList others) {
    //after setFuturePosisions!!
    ArrayList<Wall> futPos = new ArrayList<Wall>();
    for (Wall w : futurePositions) {

      if (others.MyMap.isInMap(w)&&!this.isColliding(others, w)&&isWaiting==0&&!isOldPosition(w)) { 

        futPos.add(w);
      }

      futurePositions = futPos;
    }
  }

  void setValidFuturePositionsWithStatic(WallList others) {
    //after setFuturePosisions!!
    ArrayList<Wall> futPos = new ArrayList<Wall>();
    WallList near = others.getNearOthers(this, false);
    for (Wall w : futurePositions) {
      if (near.MyMap.isInMap(w)&&!this.isColliding(near, w)&&isWaiting==0&&!isOldPosition(w)) { 
        //if (w.isOnGround()||w.isSupported(others)||w.distance()==0) {
        futPos.add(w);
        //}
      }

      futurePositions = futPos;
    }
  }  
  void setValidFuturePositions3(WallList others) {
    //after setFuturePosisions!!
    ArrayList<Wall> futPos = new ArrayList<Wall>();
    WallList near = others.getNearOthers(this, false);
    for (Wall w : futurePositions) {
      if (near.MyMap.isInMap(w)&&!this.isColliding(near, w)&&isWaiting==0&&!isOldPosition(w)) { 
        if (isGrounded(others, w)||w.distance()==0) {
          futPos.add(w);
        }
      }

      futurePositions = futPos;
    }
  }

  void addOld(Wall oldWall) {
    oldPositions.add(new Wall(oldWall));
    if (oldPositions.size()>maxOldSize) {
      oldPositions.remove(0);
    }
  }

  void randomWait() {
    if (random(1)>0.9&&this.isWaiting==0) {
      this.isWaiting+=11;
    }
    this.isWaiting--;
    if (this.isWaiting<0) {
      this.isWaiting=0;
    }
  }
  void setRandomNext() {
    Wall next = new Wall();
    this.Angle=0;
    this.Axis=0;
    if (futurePositions.size()>0) {
      next = futurePositions.get(int(random(futurePositions.size())));
      this.Angle=next.Angle;
      this.Axis=next.Axis;
    }
    futurePositions.clear();
    futurePositions.add(next);
  }

  void setTargetNext() {
    Wall next = new Wall();
    this.Angle=0;
    this.Axis=0;
    if (futurePositions.size()>0&&distance()>0) {
      Collections.sort(futurePositions);
      next = futurePositions.get(0);
      this.Angle=next.Angle;
      this.Axis=next.Axis;
    }
    futurePositions.clear();
    futurePositions.add(next);
  }

  void setByVelocity(WallList others) {
    flock(others);
    PVector Target = update();
    //sets the next position to the Direction, for Flocking
    Wall next = new Wall();
    this.Angle=0;
    this.Axis=0;
    if (futurePositions.size()>0&&distance()>0) {
      for (Wall w : futurePositions) {
        w.Target = Target;
      }
      Collections.sort(futurePositions);
      next = futurePositions.get(0);
      this.Angle=next.Angle;
      this.Axis=next.Axis;
      //redirect the wall to get the current direction
      //float dirMag = this.velocity.mag();
      //if (dirMag<3) {
      //  dirMag=3;
      //}
      //velocity = PVector.sub(next.center(), center());
      //velocity.setMag(dirMag);
    }
    futurePositions.clear();
    futurePositions.add(next);
  }

  void roundValues() {
    WallCP tempWallCP = new WallCP(this);
    tempWallCP.roundValues();
    //a function for setting o,u,v from a WallCP is needed
    this.setUV(tempWallCP);
  }


  void draw(boolean fullDraw) {
    WallType wD = new WallType(this.O, this.U, this.V);
    if (fullDraw) {
      wD.draw(sWall);
    } else {
      wD.easyDraw(this);
    }

    //WallCP tempWallCP = new WallCP(this);
    //tempWallCP.draw();
  }

  void drawMoveCenter() {
    pushMatrix();
    pushStyle();
    noStroke();
    fill(100, 20, 168, 60);
    PVector t = this.moveCenter();
    translate(t.x, t.y, t.z);
    sphere(5);

    popStyle();
    popMatrix();
  }

  void drawPast() {
    pushStyle();
    fill(0, 150, 0, 40);
    for (Wall w : oldPositions) {
      w.draw(false);
    }
    popStyle();
  }

  void drawFuture() {
    pushStyle();
    fill(150, 0, 0, 82);
    stroke(100, 100, 100, 100);
    for (Wall w : this.futurePositions) {
      w.draw(false);
    }
    popStyle();
  }
  //methods for flocking
  PVector update() {
    velocity.add(acceleration);
    //if (Float.isNaN(velocity.x)) {
    // velocity = new PVector(0, 0, 0);
    //}
    velocity.limit(1.0/minSpeed);
    if (velocity.mag()<1.0/maxSpeed) {
      velocity.setMag(1.0/maxSpeed);
    }
    acceleration.mult(0);
    setSpeed(1.0/velocity.mag());
    return PVector.add(center(), velocity);
  }
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  void flock(WallList others) {
    //The three flocking rules
    PVector sep = seperate(others);
    PVector ali = align(others);
    PVector coh = cohesion(others);

    //Arbitrary weights for these forces (Try different ones!)
    sep.mult(float(SepMult)/100.0);
    ali.mult(float(AliMult)/100.0);
    coh.mult(float(CohMult)/100.0);

    //Applying all the forces
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }  
  PVector cohesion (WallList others) {
    float neighbordist = 80;
    PVector sum = new PVector(0, 0, 0);
    int count = 0;
    for (Wall w : others.getAllNodes ()) {
      float d = PVector.dist(center(), w.center());
      if ((w!=this) && (d < neighbordist)) {
        //Adding up all the others’ locations
        sum.add(w.center());
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      //Here we make use of the seek() function we wrote in Example 6.8. The target we seek is the average location of our neighbors.
      return seek(sum);
    } else {
      return new PVector(0, 0, 0);
    }
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, center());
    desired.normalize();
    desired.mult(1.0/minSpeed);
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    return steer;
  }

  PVector align(WallList others) {
    float maxDist = 80;
    PVector sum = new PVector(0, 0, 0);
    int count = 0;
    for (Wall w : others.getAllNodes ()) {
      if (w != this && PVector.dist(center(), w.center())<maxDist) {
        sum.add(w.velocity);
        count++;
      }
    }
    if (count>0) {
      sum.div(float(count));
      sum.normalize();
      sum.mult(1.0/minSpeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxForce);
      return steer;
    } else {
      return new PVector(0, 0, 0);
    }
  }
  PVector seperate(WallList others) {
    float maxDist = 80;
    PVector sum = new PVector(0, 0, 0);
    int count = 0;
    for (Wall w : others.getAllNodes ()) {
      float d = PVector.dist(center(), w.center());
      if (w != this && d<maxDist&&d>0) {
        PVector diff = PVector.sub(center(), w.center());
        diff.normalize();
        diff.div(d);
        sum.add(diff);
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      sum.normalize();
      sum.mult(1.0/minSpeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxForce);
      return steer;
    } else {
      return new PVector(0, 0, 0);
    }
  }
  //PVector seek(PVector target){}


  void translateWall(PVector translation) {
    this.O = PVector.add(this.O, translation);
  }
  PVector[] getWallCP(Wall in) {
    WallCP CP = new WallCP(in);
    return CP.CP;
  }
  PVector[] getWallCP() {
    WallCP CP = new WallCP(this);
    return CP.CP;
  }
  public float distance() {
    PVector center = PVector.add(this.O, PVector.mult(PVector.add(this.U, this.V), 0.5));
    //get the distance to the target
    return center.dist(this.Target);
  }

  public PVector center() {
    return PVector.add(this.O, PVector.mult(PVector.add(this.U, this.V), 0.5));
  } 
  public PVector moveCenter() {

    //only works after setting the first step

    WallCP Pos1 = new WallCP(oldPositions.get(oldPositions.size()-1));

    WallCP Pos2 = new WallCP(this.rotate(oldPositions.get(oldPositions.size()-1), this.Axis, this.Angle));
    Pos1.roundValues();
    Pos2.roundValues();
    PVector[] allPoints = new PVector[8];
    for (int i = 0; i<4; i++) {
      allPoints[i*2]  = Pos1.CP[i];
      allPoints[i*2+1]= Pos2.CP[i];
    }

    return Matrix.BoundingCenter(allPoints);
  }

  public int compareTo(Wall o) {
    if (this.distance() > o.distance())
      return 1; 
    else if (this.distance() < o.distance())
      return -1; 
    return 0;
  }
  //to make sets with Wall class objects we need to implement hashcode and equals
  @Override
    public int hashCode() {
    return new HashCodeBuilder(17, 31). // two randomly chosen prime numbers
    // if deriving: appendSuper(super.hashCode()).
    append(ID).
      toHashCode();
  }
  @Override
    public boolean equals(Object obj) {
    if (!(obj instanceof Wall))
      return false;
    if (obj == this)
      return true;

    Wall rhs = (Wall) obj;
    return new EqualsBuilder().
      // if deriving: appendSuper(super.equals(obj)).
    append(ID, rhs.ID).
      isEquals();
  }
  //find wrong positions

    boolean isColliding(WallList others, Wall next) {
    boolean out = false;
    if (this.firstStep) {    
      Wall myFuture = new Wall(this);
      myFuture.oldPositions = this.oldPositions;
      myFuture.Axis = next.Axis;
      myFuture.Angle = next.Angle;
      if (others.size()>0) {
        for (Wall oWall : others.getAllNodes ()) {      
          out = PVector.dist(myFuture.moveCenter(), oWall.moveCenter())==0;
          if (out) {
            break;
          }
        }
      }
    }

    return out;
  }


  boolean isOccupied(WallList others, Wall next) {
    boolean out = false;
    int c = 0;
    if (this.firstStep) {    
      Wall myFuture = new Wall(this);
      myFuture.oldPositions = this.oldPositions;
      myFuture.Axis = next.Axis;
      myFuture.Angle = next.Angle;
      if (others.size()>0) {
        for (Wall oWall : others.getAllNodes ()) {      
          if (PVector.dist(myFuture.center(), oWall.center())==0) {
            c++;
          };
          if (c>1) {
            out = true;
            break;
          }
        }
      }
    }
    return out;
  }
  /**
   *look if there is a connection over other walls to the ground
   
   * @param node
   */
  boolean isGrounded(WallList allOthers, Wall next) {
    Graph myBoys = allOthers.getGroup(this.ID);
    next.ID = this.ID;
    myBoys.resetNode(next);
    return myBoys.isGrounded();
  }

  boolean isInBounds() {
    return true;
  }

  boolean isOnGround() {
    boolean out = true;
    //at least two cornerpoints are grounded 
    int countZeroZ = 4;
    PVector[] CP = this.getWallCP();
    for (int i = 0; i<4; i++) {
      if (CP[i].z>0) {
        countZeroZ--;
      }
    }
    out = countZeroZ>1;
    if (letFloat) {
      out = true;
    }
    return out;
  }
  boolean isAxeConnected(Wall other) {
    int[] conIndex = getConnectionIndex(other);

    int Ax1 = (int)Axis;
    int Ax2;
    if (Axis==3) {
      Ax2 = 0;
    } else {
      Ax2 = Axis+1;
    }/**
     if (conIndex[Ax1]==1||conIndex[Ax2]==1) {
     println(str(conIndex));
     println(str(Ax1)+"    "+str(Ax2));
     println(conIndex[Ax1]==1||conIndex[Ax2]==1);
     }*/
    return (conIndex[Ax1]==1||conIndex[Ax2]==1)&&other.isWaiting>0&&other.ID!=ID;
  }

  boolean isSupported(WallList others) {
    boolean supported = false;
    for (Wall w : others.getAllNodes ()) {
      supported=isAxeConnected(w);
      if (supported&&w.ID!=ID) {
        break;
      }
    }
    boolean isCeiling = !isCurrentlyAWall()&&center().z>0;
    //walls that are wall are also allowed to get higher
    boolean isWall = isCurrentlyAWall();

    return supported;
  }
  WallList getConnected(WallList others) {
    WallList connected = new WallList();
    for (Wall w : others.getAllNodes ()) {
      if (isConnected(w)&&w.ID!=ID) {
        connected.add(w, false);
      }
    }
    return connected;
  }  
  boolean isConnected(Wall other) {
    boolean connected = false;
    PVector[] CP = getWallCP();
    PVector[] otherCP = other.getWallCP();
    int c = 0;
    for (int j = 0; j<CP.length; j++) {
      for (int k = 0; k<otherCP.length; k++) { 
        if (PVector.dist(otherCP[j], CP[k]) == 0) {
          c++;
        }
        connected = c>0;
        if (connected) {
          break;
        }
      }
      if (connected) {
        break;
      }
    }
    if (other.ID == ID) {
      connected=false;
    }
    return connected;
  }
  PVector getW() {
    return this.U.cross(this.V);
  }


  boolean[][] getConnectPoints(Wall other) {
    //returns a matrix as a mapping of points connected together
    boolean[][] connectPoints = new boolean[4][4];
    PVector[] thisWallCP = getWallCP();
    PVector[] otherWallCP= other.getWallCP();
    for (int i = 1; i<4; i++) {
      for (int j = 1; j<4; j++) {
        connectPoints[i][j] = thisWallCP[i].dist(otherWallCP[j])==0;
      }
    }
    return connectPoints;
  }
  int[] getConnectionIndex(Wall other) {
    int[] Indices = {
      0, 0, 0, 0
    };
    boolean[][] ConnectPoints = getConnectPoints(other);

    for (int i = 1; i<4; i++) {
      for (int j = 1; j<4; j++) {
        if (ConnectPoints[i][j]) {
          Indices[i]=1;
          break;
        }
      }
    }
    return Indices;
  }

  int getConnectionCount(Wall other) {
    int c = 0;
    PVector[] thisWallCP = getWallCP();
    PVector[] otherWallCP= other.getWallCP();
    for (int i = 1; i<4; i++) {
      for (int j = 1; j<4; j++) {
        if (thisWallCP[i].dist(otherWallCP[j])==0) {
          c++;
        }
      }
    }
    return c;
  }


  boolean isCurrentlyAWall() {
    //if w is a multiple of the z vektor, this is currently not a wall
    return this.getW().cross(new PVector(0, 0, 1)).mag()!=0;
  }

  boolean isConnected(WallList others) {
    boolean connected = false;
    //there are at least two points connected to the next position
    for (Wall w : others.getAllNodes ()) {
      if (w.ID!=ID) {
        connected = isConnected(w);
        if (connected) {
          break;
        }
      }
    }
    //take all walls that are near next wall, if they are fixed or waiting
    //it doesn't make sense to take the future positions of the walls before!
    return connected;
  }
  //velocity, acceleration
  PVector getVelocity() {
    Wall Pos1 = oldPositions.get(oldPositions.size()-1);
    Wall Pos2 = this.rotate(oldPositions.get(oldPositions.size()-1), this.Axis, this.Angle);
    return PVector.div(PVector.sub(Pos2.center(), Pos1.center()), this.Speed);
  } 



  boolean isOldPosition(Wall next) {
    boolean out = false;
    if (PVector.dist(next.center(), Target)!=0) {
      for (int i =0; i<oldPositions.size (); i++) {
        Wall old = oldPositions.get(i);
        out = PVector.dist(old.center(), next.center())==0;
        if (out) {
          break;
        }
      }
    }
    return out;
  }


  //end of velocity, acceleration
  //end of WallClass
}

