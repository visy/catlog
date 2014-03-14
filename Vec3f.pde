class Vec3f {
  float x;
  float y;
  float p;  // Pressure
  int   c;  // Color

  Vec3f() {
    set(0, 0, 0);
    c = 0;
  }
  
  Vec3f(float ix, float iy, float ip) {
    set(ix, iy, ip);
    c = 0;
  }

  void set(float ix, float iy, float ip) {
    x = ix;
    y = iy;
    p = ip;
    c = 0;
  }

  void set(float ix, float iy, float ip, int ic) {
    x = ix;
    y = iy;
    p = ip;
    c = ic;
  }

}
