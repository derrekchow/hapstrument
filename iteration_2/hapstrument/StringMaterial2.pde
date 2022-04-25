class StringMaterial2 {
  float topY, bottomY, centerX;
  
  StringMaterial2(float _topY, float _bottomY, float _centerX) {
    topY = _topY;
    bottomY = _bottomY;
    centerX = _centerX;
  }
  
  //boolean getForce(float acc, float vel, float ) {
  //  if (acc > ) {
  //    return 0;
  //  }
    
  //  return false;
    
  //}
  
  //void pluck() {
  //  pos.set(centerX, pos.y);
  //}
  
  void draw(PVector posEE) {
    background(255);
    noFill();
    stroke(0);
    strokeWeight(5);
    
    float cx = map(centerX, -1, 1, 0, width);
    float px = map(posEE.x, -1, 1, 0, width);
    
    beginShape();
    curveVertex(cx, topY*height);
    curveVertex(cx, topY*height);
    if (posEE.x > 0) {
      curveVertex(px, posEE.y*height);
    }
    curveVertex(cx, bottomY*height);
    curveVertex(cx, bottomY*height);
    endShape(); 
  }
}
