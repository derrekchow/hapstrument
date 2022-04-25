class StringMaterial {
  
  boolean aboveString = true;   // On which side of the string is the end effector
  float strumDistance = 0.003;  // The distance the string bends before the end effector goes through it 
  
  float x1 = -0.1;
  float y1 = -0.1;
  float x2 = 0.1;
  float y2 = 0.1;
  
  int thickness;                // How "thick" the string feels
  PShape wall;
  
  StringMaterial (float _x1, float _y1, float _x2, float _y2, int _thickness, float pixelsPerMeter, PVector deviceOrigin) {
    thickness = _thickness;
    if (_y2 > _y1 || (_y1 == _y2 && _x1 < _x2)) {
      x1 = _x1;
      y1 = _y1;
      x2 = _x2;
      y2 = _y2;
    } else {
      x1 = _x2;
      y1 = _y2;
      x2 = _x1;
      y2 = _y1;
    }
    wall = create_wall(x1, y1, x2, y2, pixelsPerMeter, deviceOrigin);
    wall.setStroke(color(0));  
  }
  
  PShape create_wall(float x1, float y1, float x2, float y2, float pixelsPerMeter, PVector deviceOrigin){ // Get rid of deviceOrigin if you want
    x1 = pixelsPerMeter * x1;
    y1 = pixelsPerMeter * y1;
    x2 = pixelsPerMeter * x2;
    y2 = pixelsPerMeter * y2;
    
    return createShape(LINE, deviceOrigin.x + x1, deviceOrigin.y + y1, deviceOrigin.x + x2, deviceOrigin.y + y2);
  }
 
}

static class StringForce {
  boolean justCrossedString;
  PVector forceEE;
  
  StringForce(boolean _justCrossedString, PVector _forceEE) {
    justCrossedString = _justCrossedString;
    forceEE = _forceEE;
  }
  
}

static boolean getIsInsideString(PVector posEE, StringMaterial string) {
    float dotprod1 = (posEE.x-string.x1)*(string.x2-string.x1) + (posEE.y-string.y1)*(string.y2-string.y1);
    float dotprod2 = (posEE.x-string.x2)*(string.x2-string.x1) + (posEE.y-string.y2)*(string.y2-string.y1);
    boolean isInsideString = min(dotprod1, dotprod2) <= 0.0000 && max(dotprod1, dotprod2) >= -0.0000; // Linear algebra woooo
    return isInsideString;
}

static StringForce calculateForce(StringMaterial[] strings, StringMaterialCircle[] circles, PVector posEE) {

  boolean justCrossedString = false;
        
  // Calculate if we just went through a string
  label: {
    for (StringMaterial string : strings) {
      if (string == null)
        continue;
  
      float distanceAboveString = ((string.x2-string.x1)*(string.y1-posEE.y) - (string.x1-posEE.x)*(string.y2-string.y1))/sqrt(pow(string.x2-string.x1,2)+pow(string.y2-string.y1,2));
      boolean isInsideString = getIsInsideString(posEE, string);
  
      if (string.aboveString && distanceAboveString < -string.strumDistance) {
        string.aboveString = false;
        if (isInsideString) {
          justCrossedString = true;
          break label;
        }
      } else if (!string.aboveString && distanceAboveString > string.strumDistance) {
        string.aboveString = true;
        if (isInsideString) {
          justCrossedString = true;
          break label;
        }      
      }
    }
    for (StringMaterialCircle circle: circles) {
      if (circle == null)
        continue;
      
      float distanceOutsideCircle = sqrt(pow(posEE.x - circle.x,2)+pow(posEE.y-circle.y,2)) - circle.radius;
      if (circle.isInsideCircle && distanceOutsideCircle > circle.strumDistance) {
        circle.isInsideCircle = false;
        justCrossedString = true;
        break label;
      } else if (!circle.isInsideCircle && distanceOutsideCircle < -circle.strumDistance) {
        circle.isInsideCircle = true;
        justCrossedString = true;
        break label;
      }
    }
  }
  
  PVector fWall = new PVector(0, 0);
  
  // Calculate forces
  for (StringMaterial string : strings) {
    
    if (string == null)
      continue;
    
    float distanceAboveString = ((string.x2-string.x1)*(string.y1-posEE.y) - (string.x1-posEE.x)*(string.y2-string.y1))/sqrt(pow(string.x2-string.x1,2)+pow(string.y2-string.y1,2));
    boolean isInsideString = getIsInsideString(posEE, string);
    
    // If we just crossed a boundary, stop bending all strings, to get rid of bug
    if (justCrossedString) {
      string.aboveString = distanceAboveString > 0;
    }
      
    // For generating force
    float force = 0;
    float thickness = string.thickness * (1+(0.28 - string.y1 - string.y2)*3); // Vary thickness based on y value
    if(string.aboveString && distanceAboveString < string.strumDistance && isInsideString){
      force = abs((string.strumDistance - distanceAboveString) * thickness); 
    }
    else if (!string.aboveString && distanceAboveString > -string.strumDistance && isInsideString) {
      force = abs((distanceAboveString + string.strumDistance) * thickness);  
    }
    
    if (string.y1 == string.y2) {
      if (string.aboveString) {
        force = -force;
      }
      fWall.add(new PVector(0, force));
    } else {
      if (!string.aboveString) {
        force = -force;
      }
      float slope = -1/((string.y2-string.y1)/(string.x2-string.x1));     
      float xComponent = force*1/sqrt(1+pow(slope,2));
      float yComponent = force*slope/sqrt(1+pow(slope,2));
      fWall.add(new PVector(xComponent, yComponent));
    }
  }

  for (StringMaterialCircle circle : circles) {
    
    if (circle == null)
      continue;
    
    float distanceOutsideCircle = sqrt(pow(posEE.x - circle.x,2)+pow(posEE.y-circle.y,2)) - circle.radius;
    
    // If we just crossed a boundary, stop bending all strings, to get rid of bug
    if (justCrossedString) {
      circle.isInsideCircle = distanceOutsideCircle < 0;
    }
    
    // For generating force
    float force = 0;
    float thickness = circle.thickness * (1+(0.14 - posEE.y)*3); // Vary thickness based on y value
    if(circle.isInsideCircle && distanceOutsideCircle > -circle.strumDistance){
      force = abs((circle.strumDistance + distanceOutsideCircle) * thickness); 
    }
    else if (!circle.isInsideCircle && distanceOutsideCircle < circle.strumDistance) {
      force = -abs((circle.strumDistance - distanceOutsideCircle) * thickness);  
    }
    
    float angle = atan2((posEE.x-circle.x), (posEE.y-circle.y)) + PI;
    float xComponent = force * sin(angle);
    float yComponent = force * cos(angle);    
    fWall.add(new PVector(xComponent, yComponent));
  }
 
  return new StringForce(justCrossedString, (fWall.copy())
  );
}
