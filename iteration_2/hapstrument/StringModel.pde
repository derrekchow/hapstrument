class StringModel extends Model {
  PVector vel;
  PVector newVel;
  PVector acc;  
  StringMaterial2 material;
  boolean t = false;
  float tt = 0;
  float shakeX = 0;
  Range range;

  StringModel(Range _range) {
    super();
    material = new StringMaterial2(0, 1, 0);
    vel = new PVector(0, 0);
    newVel = new PVector(0, 0);
    acc = new PVector(0, 0);
    range = _range;
  }


  void set_data(float[] _angles, float[] _pos) {
    
    float x = map(_pos[0], range.minX, range.maxX, -1, 1);
    float y = map(_pos[1], range.minY, range.maxY, 0, 1);
    
    newVel = new PVector(x, y).sub(posEE);
    acc = PVector.sub(newVel, vel);

    posEE.set(x, y);
    vel.set(newVel);

    float forceX = abs(material.centerX - posEE.x)*50;
    float v = vel.x*10000;
    
    message = new float[]{0};

    if (posEE.x > 0 && !t) {
      forceEE.set(forceX, 0);
    } else if (t) {
      float delta = max(2 - (millis() - tt)/150, 0);
      shakeX = sin(millis()/2)*delta;
      forceEE.set(shakeX, 0);
      message = new float[]{delta};
    } else {
      forceEE.set(0, 0);
    }

    if (v > 20 && posEE.x > 0.1 && tt == 0) {
      t = true;
      tt = millis();
    }

    if (posEE.x < 0) {
      t = false;
      tt = 0;
    }

    //float volume = map(_pos[1], 0.021, 0.15, 1, -1);
    //float vibrato = map(_pos[0], -0.03, 0.03, -1, 1)*100;
    //forceEE.set(0, volume*20);
    //message = new float[]{volume, vibrato};
  }

  void draw_graphics() {
    if (t) {
      material.draw(new PVector(shakeX/10, posEE.y));
    } else {
      material.draw(posEE);
    }
    //circle(posEE.x*width + width/2, posEE.y*height, 10);
  }
}
