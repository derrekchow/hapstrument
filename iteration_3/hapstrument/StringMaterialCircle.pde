class StringMaterialCircle {
  
  boolean isInsideCircle = false;
  float strumDistance = 0.003;  // The distance the string bends before the end effector goes through it 
  
  float x = 0;
  float y = 0.04;
  float radius = 0.04;
  
  int thickness;                // How "thick" the string feels
  PShape wall;

  StringMaterialCircle (float _x, float _y, float _radius, int _thickness, float pixelsPerMeter, PVector deviceOrigin) {
    x = _x;
    y = _y;
    radius = _radius;
    thickness = _thickness;

    wall = create_wall(x, y, radius, pixelsPerMeter, deviceOrigin);  
    wall.setStroke(color(0));            
}
 
  PShape create_wall(float x, float y, float radius, float pixelsPerMeter, PVector deviceOrigin){ // Get rid of deviceOrigin if you want
    x = pixelsPerMeter * x;
    y = pixelsPerMeter * y;
    radius = pixelsPerMeter * radius;
    return createShape(ELLIPSE, deviceOrigin.x + x, deviceOrigin.y + y, 2*radius, 2*radius);
  }
  
}
