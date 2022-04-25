class StringMaterialPiano {
  
  boolean aboveString = true;   // On which side of the string is the end effector
  float strumDistance = 0.005;  // The distance the string bends before the end effector goes through it 
  boolean isVertical = false;   // Whether the string is vertical or horizontal
  float lowEnd = -0.2;          // The low bound of the string, lengthwise
  float highEnd = 0.2;          // The high bound of the string, lengthwise
  int thickness = 400;          // How "thick" the string feels
  float location;               // The location of the string, widthwise
  PShape wall;
  
  StringMaterialPiano (boolean _isVertical, float _lowEnd, float _highEnd, float _location) {
    isVertical = _isVertical;
    lowEnd = _lowEnd;
    highEnd = _highEnd;
    location = _location;
    if (isVertical)
        wall = createShape(LINE, location, lowEnd, location, highEnd);
    else
        wall = createShape(LINE, lowEnd, location, highEnd, location);
    wall.setStroke(color(0));  }
 
  // Overloaded constructor so that both coordinate systems can work
  StringMaterialPiano (boolean _isVertical, float _lowEnd, float _highEnd, float _location, float pixelsPerMeter, PVector deviceOrigin) {
    isVertical = _isVertical;
    lowEnd = _lowEnd;
    highEnd = _highEnd;
    location = _location;
    if (isVertical)
        wall = create_wall(location, lowEnd, location, highEnd, pixelsPerMeter, deviceOrigin);
    else
        wall = create_wall(lowEnd, location, highEnd, location, pixelsPerMeter, deviceOrigin);
    wall.setStroke(color(0));
  }
  
  PShape create_wall(float x1, float y1, float x2, float y2, float pixelsPerMeter, PVector deviceOrigin){
    x1 = pixelsPerMeter * x1;
    y1 = pixelsPerMeter * y1;
    x2 = pixelsPerMeter * x2;
    y2 = pixelsPerMeter * y2;
    
    return createShape(LINE, deviceOrigin.x + x1, deviceOrigin.y + y1, deviceOrigin.x + x2, deviceOrigin.y+y2);
  }
  
}

static class StringForcePiano {
  boolean justCrossedString;
  PVector forceEE;
  
  StringForcePiano(boolean _justCrossedString, PVector _forceEE) {
    justCrossedString = _justCrossedString;
    forceEE = _forceEE;
  }
  
}

static StringForcePiano calculateForce(StringMaterialPiano[] strings, PVector posEE) {

  boolean justCrossedString = false;
        
  // Calculate if we just went through a string
  label: for (StringMaterialPiano string : strings) {
    
    float mainPos = string.isVertical ? posEE.x : posEE.y;
    float lateralPos = string.isVertical ? posEE.y : posEE.x;
    
    // For switching between above and below string
    if (string.aboveString && mainPos > string.location + string.strumDistance/2) {
      string.aboveString = false;
      if (lateralPos > (string.lowEnd-0.01) && lateralPos < (string.highEnd+0.01)) { 
        // Adding the 0.01 makes it more reliable when switching from white to black notes
        justCrossedString = true; 
        break label;
      }
    } else if (!string.aboveString && mainPos < string.location - string.strumDistance/2) {
      string.aboveString = true;
      if (lateralPos > (string.lowEnd-0.01) && lateralPos < (string.highEnd+0.01)) { 
        justCrossedString = true;
        break label;
      }        
    } 
  }
  
  PVector fWall = new PVector(0, 0);
  
  // Calculate forces
  for (StringMaterialPiano string : strings) {
    float mainPos = string.isVertical ? posEE.x : posEE.y;
    float lateralPos = string.isVertical ? posEE.y : posEE.x;
    
    // If we just crossed a boundary, stop bending all strings, to get rid of bug
    if (justCrossedString) {
      string.aboveString = mainPos < string.location;
    }
      
    // For generating force
    float force = 0;
    if(string.aboveString && mainPos > string.location - string.strumDistance && lateralPos > string.lowEnd && lateralPos < string.highEnd){
      force = (mainPos - string.location + string.strumDistance) * string.thickness;  
    }
    else if (!string.aboveString && mainPos < string.location + string.strumDistance && lateralPos > string.lowEnd && lateralPos < string.highEnd) {
      force = (string.location + string.strumDistance - mainPos) * -string.thickness;  
    }
    fWall = fWall.add(new PVector(string.isVertical ? force : 0, string.isVertical ? 0 : force));
  }

  return new StringForcePiano(justCrossedString, (fWall.copy()).mult(-1));
}
