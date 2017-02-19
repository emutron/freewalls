class WallCP {
  private PVector[] CP = new PVector[4];


  public WallCP(PVector[] tempCP) {
    //this constructor for retrieving only cornerpoints
    for (int i = 0; i<4; i++) {
      this.CP[i] = tempCP[i].get();
    }
  }  
  public WallCP(Wall tempWall) {
    //this constructor for retrieving a wall
    PVector O = tempWall.O.get();
    PVector U = tempWall.U.get();
    PVector V = tempWall.V.get();
    PVector[] tempCP = {
      O, PVector.add(O, U), PVector.add(PVector.add(O, U), V), PVector.add(O, V)
      };
      this.CP = tempCP;
  }

  public WallCP(WallCP another) {
    //copy method
    for (int i = 0; i<4; i++) {
      this.CP[i] = another.CP[i].get();
    }
  }
  public WallCP(PVector O, PVector U, PVector V) {
    PVector[] tempCP = {
      O.get(), PVector.add(O, U), PVector.add(PVector.add(O, U), V), PVector.add(O, V)
      };
      this.CP = tempCP;
  }

  void translateCP(PVector transVector) {
    PVector[] out = new PVector[4];
    for (int i = 0; i<4; i++) {
      out[i] = PVector.add(this.CP[i].get(), transVector);
    }
    this.CP = out;
  }


  void rotate(int taxis, float tangle) {
    this.rotatePVectorArray(taxis);
    PVector t = this.CP[0].get();
    this.translateCP(PVector.mult(t, -1));
    //find out which axis of the base the axis is parallel to
    Matrix rotMatrix = new Matrix();
    PVector X = new PVector(1, 0, 0);
    PVector Y = new PVector(0, 1, 0);
    PVector Z = new PVector(0, 0, 1);
    //choose the right axis
    if (X.cross(this.CP[1]).mag()==0) {
      rotMatrix.RotMatX(tangle);
    } else if (Y.cross(this.CP[1]).mag()==0) {
      rotMatrix.RotMatY(tangle);
    } else if (Z.cross(this.CP[1]).mag()==0) {
      rotMatrix.RotMatZ(tangle);
    }
    //rotate the 4th element of the rotated index list
    this.CP[3] = rotMatrix.VectorMatrixMult(this.CP[3]);
    this.CP[2] = PVector.add(this.CP[3], this.CP[1]);
    //move back from origin
    this.translateCP(t);
    this.rotatePVectorArray(-taxis);
  }//end of rotate


  PVector[] rotatePVectorArray(PVector[] PVectorArrayIn, int index) {
    index*=-1;
    PVector[] PVectorArrayOut = new PVector[PVectorArrayIn.length];
    for (int i = index; i<index+PVectorArrayIn.length; i++) {
      PVectorArrayOut[i-index] = PVectorArrayIn[((i%PVectorArrayIn.length)+PVectorArrayIn.length)%PVectorArrayIn.length].get();
    }
    return PVectorArrayOut;
  }
  void rotatePVectorArray(int index) {
    this.CP = this.rotatePVectorArray(this.CP, index);
  }


  PVector[] roundValues(PVector[] Points) {
    PVector[] out = new PVector[Points.length];
    for (int i = 0; i<4; i++) {
      PVector I = new PVector(0, 0, 0);
      I.x = round(Points[i].get().x);
      I.y = round(Points[i].get().y);
      I.z = round(Points[i].get().z);
      out[i] = I;
    }
    return out;
  }

  void roundValues() {
    this.CP = this.roundValues(this.CP);
  }
  void draw() {
    beginShape();
    //noStroke();
    for (int i = 0; i<4; i++) {
      vertex(this.CP[i].x, this.CP[i].y, this.CP[i].z);
    }
    vertex(this.CP[0].x, this.CP[0].y, this.CP[0].z);
    endShape();
  }
}

