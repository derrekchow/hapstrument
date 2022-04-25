class PluckMaterial {
  float topY, bottomY, centerX;

  PluckMaterial(float _topY, float _bottomY, float _centerX) {
    topY = _topY;
    bottomY = _bottomY;
    centerX = _centerX;
  }

  void draw_graphics(PVector posEE) {
    noFill();
    stroke(0);
    strokeWeight(5);

    float cx = map(centerX, -1, 1, 0, width);
    float px = map(posEE.x, -1, 1, 0, width);

    beginShape();
    curveVertex(cx, topY*height);
    curveVertex(cx, topY*height);
    if (posEE.x != 0) {
      curveVertex(px, posEE.y*height);
    }
    curveVertex(cx, bottomY*height);
    curveVertex(cx, bottomY*height);
    endShape();
  }
}
