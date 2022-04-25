class StringModel extends Model {
  PVector vel;
  PVector newVel;
  PVector acc;  
  PluckMaterial material;
  boolean pluck = false;
  float tt = 0;
  float shakeX = 0;
  Range range;
  float pluckDist = 0.1;
  int strength = 70;
  float pluckVel;

  StringModel(Range _range) {
    super();
    material = new PluckMaterial(0, 1, 0);
    vel = new PVector(0, 0);
    newVel = new PVector(0, 0);
    acc = new PVector(0, 0);
    range = _range;
  }


  void set_data(float[] _angles, float[] _pos) {

    float x = map(_pos[0], range.minX, range.maxX, -1, 1);
    float y = map(_pos[1], range.minY, range.maxY, 0, 1);
    //float x = _pos[0]-0.5;
    //float y = _pos[1];

    newVel = new PVector(x, y).sub(posEE);
    acc = PVector.sub(newVel, vel);

    posEE.set(x, y);
    vel.set(newVel);

    float forceX = -(material.centerX - posEE.x)*strength;
    float v = vel.x*10000;
    println(v);
    message = new float[]{0};

    if (abs(posEE.x) < abs(pluckDist) && !pluck) {
      forceEE.set(forceX, 0);
      pluckVel = abs(v);
    } else if (pluck) {
      float delta = max(1 - (millis() - tt)/300, 0);
      shakeX = sin(millis()/2)*delta;
      forceEE.set(shakeX, 0);
      message = new float[]{delta*(0.2+pluckVel/5)};
    } else {
      forceEE.set(0, 0);
    }

    //if (abs(v) > 20 && posEE.x > pluckDist && tt == 0) {
    //  pluck = true;
    //  tt = millis();
    //}

    if (abs(posEE.x) < abs(pluckDist)) {
      pluck = false;
      tt = 0;
      if (pluckDist * posEE.x > 0) {
        pluck = true;
      }
    } else if (tt == 0 && abs(v) > 10) {
      pluck = true;
      tt = millis();
      pluckDist = (posEE.x > 0 ? 1 : -1)*abs(pluckDist);
    }

    //float volume = map(_pos[1], 0.021, 0.15, 1, -1);
    //float vibrato = map(_pos[0], -0.03, 0.03, -1, 1)*100;
    //forceEE.set(0, volume*20);
    //message = new float[]{volume, vibrato};
  }

  void draw_graphics() {

    if (pluck) {
      material.draw_graphics(new PVector(shakeX/10, posEE.y));
    } else {
      material.draw_graphics(posEE);
    }
    circle(posEE.x*width + width/2, posEE.y*height, 10);
  }
}
