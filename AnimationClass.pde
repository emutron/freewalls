static class Animation {

  Animation () {
  }

  static float LINEAR(int count, int duration) {

    return count/float(duration);
  }
  static float SQUAR(int count, int duration) {
    return sq(count/float(duration));
  }

  static float SQUAREINVR(int count, int duration) {
    return -sq(count/(float)duration-1)+1;
  }
}

