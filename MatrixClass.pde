/**
 function matrix-vector-product(A,x,m,n)
 y = zeroes(m)                      // Ergebnisvektor y mit Nullen initialisieren
 for i = 1 to m                     // Schleife über die Zeilen von A
 for j = 1 to n                   // Schleife über die Elemente von x
 y(i) = y(i) + A(i,j) * x(j)    // Bildung der Produktsumme
 end
 end
 return y
 */
static class Matrix {

  float[] data = {
    1, 0, 0, 
    0, 1, 0, 
    0, 0, 1
  };

  Matrix() {
  }
  Matrix(float[] tempdata) {
    this.data = tempdata;
  }



  PVector VectorMatrixMult(PVector VectorIn, float[] Matrix) {
    float[] X = VectorIn.get().array();
    float[] Y = {
      0, 0, 0
    };
    //iterate through each row of the matrix
    for (int k = 0; k < 3; k++) {
      for (int j = 0; j<3; j++) {
        Y[k] += Matrix[k*3+j]*X[j];
      }
    }
    PVector VectorOut = new PVector(Y[0], Y[1], Y[2]);
    return VectorOut;
  }

  PVector VectorMatrixMult(PVector VectorIn) {
    return this.VectorMatrixMult(VectorIn, this.data);
  }

  void ZeroMatr() {
    float[] out = {
      1, 0, 0, 
      0, 1, 0, 
      0, 0, 1
    };
    this.data = out;
  }

  void RotMatX(float a) {
    float[] out = {
      1, 0, 0, 
      0, cos(PI*a), -sin(PI*a), 
      0, sin(PI*a), cos(PI*a)
      };
      this.data = out;
  }
  void RotMatY(float a) {
    float[] out = {
      cos(PI*a), 0, sin(PI*a), 
      0, 1, 0, 
      -sin(PI*a), 0, cos(PI*a)
      };
      this.data = out;
  }
  void RotMatZ(float a) {
    float[] out = {
      cos(PI*a), -sin(PI*a), 0, 
      sin(PI*a), cos(PI*a), 0, 
      0, 0, 1
    };
    this.data = out;
  }

  static PVector center(PVector[] points) {
    return PVector.add(points[0], PVector.mult(PVector.sub(points[2], points[0]), 0.5));
  }

  static PVector BoundingCenter(PVector[] pointList) {
    PVector[] pl = new PVector[pointList.length];
    for (int i = 0; i<pointList.length; i++) {
      pl[i]=pointList[i].get();
    }
    PVector center= new PVector(0, 0, 0);
    float[][] MinMax = new float[3][pointList.length];
    for (int j = 0; j<3; j++) {
      for (int k = 0; k<pointList.length; k++) {
        MinMax[j][k] = pointList[k].array()[j];
      }
    }
    PVector min = new PVector(min(MinMax[0]), min(MinMax[1]), min(MinMax[2]));
    PVector max = new PVector(max(MinMax[0]), max(MinMax[1]), max(MinMax[2]));
    center = PVector.add(min, PVector.mult(PVector.sub(max, min), 0.5));
    return center;
  }
}

