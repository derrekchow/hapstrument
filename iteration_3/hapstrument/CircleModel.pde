import java.util.Arrays;

class CircleModel extends Model {
  
  //          Keys:  C  C# D  Eb E  F  F# G  G# A  Bb  B      // Scales
  int[] chromatic = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};   //   0
  int[] major     = {0, 0, 2, 2, 4, 5, 5, 7, 7, 9, 9,  11};   //   1
  int[] minor     = {0, 0, 2, 3, 3, 5, 5, 7, 8, 8, 8,  11};   //   2
  int[] blues     = {0, 0, 0, 3, 3, 5, 6, 7, 7, 7, 10, 10};   //   3
  int[] penta     = {0, 0, 2, 2, 4, 4, 4, 7, 7, 9, 9,  9};    //   4
  
  int initialKeyNum = 10; // C, C#, ...
  int initialScaleNum = 1; // chromatic, major, ...
  
  int[][] allScales = {chromatic, major, minor, blues, penta};

  String[] keys = {"C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B", "C", "C#", "D", "Eb", "E"};
  String[] scaleNames = {"Chromatic", "Major", "Minor", "Blues", "Pentatonic"};
  String[] scaleNamesShort = {"Chrom", "Major", "Minor", "Blues", "Penta"};
  String[] noteNames = {"C3", "C#3", "D3", "Eb3", "E3", "F3", "F#3", "G3", "G#3", "A4", "Bb4", "B4", "C4", "C#4", "D4", "Eb4", "E4", "F4", "F#4", "G4", "G#4", "A5", "Bb5", "B5"};

  int[] pitches = new int[24];
  String pitchLetter = "";
  float pitchMIDI = 60;
  float pitchFreq = 0;
  boolean continuousPitch = true; 
  
  PVector[] outerPoints = new PVector[24];
  PVector[] innerPoints = new PVector[24];
  
  int[][] slots = {{initialKeyNum, initialScaleNum}, {0, 0}, {1, 1}};
  int selectedSlot = 0;
  
  float circleCenterY = 0.085;
  float innerRadius = 0.040;
  float outerRadius = 0.060;

  StringMaterial[] strings = new StringMaterial[57];
  StringMaterialCircle[] circles = new StringMaterialCircle[3];
  
  int positionSize = 10;
  int positionCounter = 0;
  float[] xPositions = new float[positionSize];
  float[] yPositions = new float[positionSize];
  long startTime = 0;
  float maxPositive = 0;
  float maxNegative = 0;
  boolean isVibrato = false;
  float movementThreshold = 3;
  long timeThreshold = 200;
  
  boolean menuVisible = true;
  float menuX = 0.079;
  float menuY = 0.017;
  float menuRadius = 0.005;
  
  float[] magnetPosition = new float[24]; // not int because may include .5
  
  /* Screen and world setup parameters */
  float             pixelsPerMeter                      = 4000.0;
  float             radsPerDegree                       = 0.01745;
  
  /* pantagraph link parameters in meters */
  float             l                                   = 0.07;
  float             L                                   = 0.09;
  
  /* end effector radius in meters */
  float             rEE                                 = 0.003;
  
  /* generic data for a 2DOF device */
  /* joint space */
  PVector           angles                              = new PVector(0, 0);
  PVector           torques                             = new PVector(0, 0);
  
  /* device graphical position */
  PVector           deviceOrigin                        = new PVector(0, 0);
  
  /* World boundaries reference */
  final int         worldPixelWidth                     = 1000;
  final int         worldPixelHeight                    = 650;
  
  /* graphical elements */
  PShape pGraph, joint, endEffector;
  
  CircleModel() {

    /* visual elements setup */
    background(0);
    deviceOrigin.add(worldPixelWidth/2, 0);
    
    /* create pantagraph graphics */
    create_pantagraph();
    
    for (int i = 0; i < 24; i++) {
      int angle = 180 - i*15;
      innerPoints[i] = new PVector(innerRadius * sin(angle*PI/180), innerRadius * cos(angle*PI/180) + circleCenterY);
      outerPoints[i] = new PVector(outerRadius * sin(angle*PI/180), outerRadius * cos(angle*PI/180) + circleCenterY);
    }
    circles[0] = new StringMaterialCircle(0, circleCenterY, outerRadius, 800, pixelsPerMeter, deviceOrigin);
    circles[1] = new StringMaterialCircle(0, circleCenterY, innerRadius, 700, pixelsPerMeter, deviceOrigin);
    circles[2] = new StringMaterialCircle(menuX, menuY, menuRadius, 300, pixelsPerMeter, deviceOrigin);
    create_spokes();  
     
    // Left column lines
    for (int i = 0; i < 13; i++) {
      strings[24+i] = new StringMaterial(-0.1, 0.02 + i*0.0085, -0.08, 0.02 + i*0.0085, 350, pixelsPerMeter, deviceOrigin);
    }
    strings[37] = new StringMaterial(-0.08, 0.02, -0.08, 0.02 + 12*0.0085, 600, pixelsPerMeter, deviceOrigin);
    
    // Right column lines
    for (int i = 0; i < 10; i++) {
      strings[38+i] = new StringMaterial(0.08, 0.025 + i*0.01, 0.11, 0.025 + i*0.01, 450, pixelsPerMeter, deviceOrigin);
    }
    for (int i = 0; i < 9; i++) {
      if (i != 5)
        strings[48+i] = new StringMaterial(0.08, 0.025 + i*0.01, 0.08, 0.035 + i*0.01, 600, pixelsPerMeter, deviceOrigin);
    } 
  }
  
  void create_spokes() {
    int[] scale = allScales[getScale()];

    for (int i = 0; i < pitches.length; i++) {
      if (i < 12)
        pitches[i] = scale[i];    
      else
        pitches[i] = scale[i-12] + 12;    
    }
    int[] oldPitches = pitches.clone();
    for (int i = 0; i < pitches.length; i++) {    
      if (i - getKey() >= 0)
         pitches[i] = oldPitches[i - getKey()] + getKey();
      else {
         pitches[i] = oldPitches[i - getKey() + 12] + getKey() - 12;
      }
    }
    if (pitches [0] < 0) {
       pitches[0] = pitches[23];
    }
    if (pitches [1] < 0) {
       pitches[1] = pitches[23];
    }    

    for (int i = 0; i < 24; i++) {
      float centroid = 0; // notes away from center
      if (pitches[(i-2+24)%24] == pitches[i]) {centroid -= 0.5;}
      if (pitches[(i-1+24)%24] == pitches[i]) {centroid -= 0.5;}
      if (pitches[(i+1)%24] == pitches[i]) {centroid += 0.5;}
      if (pitches[(i+2)%24] == pitches[i]) {centroid += 0.5;}
      magnetPosition[i] = i + centroid;
    }
    
    for (int i = 0; i < 24; i++) {
      if ((i==0 && pitches[0] != pitches[23]) || i>0 && pitches[i] != pitches[i-1]) {
        strings[i] = new StringMaterial(innerPoints[i].x, innerPoints[i].y, outerPoints[i].x, outerPoints[i].y, 350, pixelsPerMeter, deviceOrigin);
      } else {
        strings[i] = null;
      }
    }
  }
  
  int getKey() {
    return slots[selectedSlot][0];
  }
  
  void setKey(int newKey) {
    slots[selectedSlot][0] = newKey;
  }
  
  int getScale() {
    return slots[selectedSlot][1];
  }
  
  void setScale(int newScale) {
    slots[selectedSlot][1] = newScale;
  }
  
  void draw_graphics(){
    background(255); 
    update_animation(angles.x*radsPerDegree, angles.y*radsPerDegree, posEE.x, posEE.y);
  }
  
  void set_data(float[] _angles, float[] _pos) { 
    angles.set(_angles); 
    posEE.set(_pos);
    posEE.set(device_to_graphics(posEE)); 

    StringForce returnValue = calculateForce(menuVisible ? strings : Arrays.copyOfRange(strings, 0, 24), circles, posEE);
    forceEE = returnValue.forceEE;
    
    xPositions[positionCounter] = posEE.x;
    yPositions[positionCounter] = posEE.y;
    positionCounter = (positionCounter+1)%positionSize;
    float xVeloc = (posEE.x - xPositions[positionCounter])*1000;
    float yVeloc = (posEE.y - yPositions[positionCounter])*1000;
    float veloc = sqrt(pow(xVeloc,2) + pow(yVeloc,2)) * ((xVeloc > 0) ? 1 : -1);
    
    if (returnValue.justCrossedString && sqrt(pow(posEE.x-menuX,2) + pow(posEE.y-menuY,2)) < menuRadius) {
      menuVisible = !menuVisible;
    } else if (menuVisible && posEE.x < -0.08) {
      int newKeyNum = floor((posEE.y - 0.02)/0.0085);
      if (returnValue.justCrossedString && newKeyNum >= 0 && newKeyNum < 12 && newKeyNum != getKey()) {
        setKey(newKeyNum);
        create_spokes();
      }
    } else if (menuVisible && posEE.x > 0.08) {
      int newScaleOrSlot = floor((posEE.y - 0.025)/0.01);
      if (returnValue.justCrossedString && newScaleOrSlot >= 0 && newScaleOrSlot < 5 && newScaleOrSlot != getScale()) {
        setScale(newScaleOrSlot);
        create_spokes();
      } else if (returnValue.justCrossedString && newScaleOrSlot >= 6 && newScaleOrSlot < 9 && newScaleOrSlot - 6 != selectedSlot) {
        selectedSlot = newScaleOrSlot - 6;
        create_spokes();
      }
      
    } else {
      // Calculate pitch
      float angle = atan2(-posEE.x, (posEE.y-circleCenterY))/PI*180 +180;
      int pos = min(floor((angle)/15),23); // Make sure it's never 24
      float distFromMiddle = sqrt(pow(posEE.y - circleCenterY,2) + pow(posEE.x, 2));
      if (returnValue.justCrossedString) { // If just moved across a string
        isVibrato = false;
        if (distFromMiddle > outerRadius) { // If outside the ring
          continuousPitch = true;
        } else if (distFromMiddle > innerRadius) { // If inside the ring, determine which segment
          continuousPitch = false;
          pitchLetter = noteNames[pitches[pos]];
          pitchMIDI = 60 + pitches[pos];
          startTime = System.currentTimeMillis();
          maxNegative = 0;
          maxPositive = 0;
        } else {
          continuousPitch = false;
        }
      } else if (distFromMiddle > innerRadius && distFromMiddle < outerRadius && !continuousPitch) { // If inside the ring, determine vibrato
        if (!isVibrato) {
          if (max(xVeloc,yVeloc) > maxPositive) { maxPositive = max(xVeloc,yVeloc); }
          if (min(xVeloc,yVeloc) < maxNegative) { maxNegative = min(xVeloc,yVeloc); }
          if (abs(maxPositive) > movementThreshold && abs(maxNegative) > movementThreshold && System.currentTimeMillis() - startTime > timeThreshold) {
            isVibrato = true;
          }
        }
        // Figure out magnetic force
        float centroidAngle = (magnetPosition[pos]*15+7.5)/180*PI;
        PVector centroid = new PVector((innerRadius+outerRadius)/2*sin(centroidAngle), -(innerRadius+outerRadius)/2*cos(centroidAngle) + circleCenterY);
        float angleToCentroid = atan2((posEE.x-centroid.x), (posEE.y-centroid.y)) + PI;
        float distanceToCentroid = sqrt(pow(posEE.x - centroid.x,2)+pow(posEE.y-centroid.y,2));
        float xComponent = 200 * distanceToCentroid * sin(angleToCentroid);
        float yComponent = 200 * distanceToCentroid * cos(angleToCentroid);    
        forceEE.add(new PVector(xComponent, yComponent));
        
      }
      if (continuousPitch) {
        pitchLetter = "";
        pitchMIDI = 59.5 + angle/360*24;
      }
      pitchFreq = pow(2,(pitchMIDI-69)/12) * 440 * (isVibrato ? 1+veloc/100 : 1); // Convert MIDI note number into frequency
      message = new float[]{pitchFreq};
    }
    
    forceEE.set(graphics_to_device(forceEE));
  }
  
  void create_pantagraph(){
    float rEEAni = pixelsPerMeter * rEE;   
    strokeWeight(4);
    endEffector = createShape(ELLIPSE, deviceOrigin.x, deviceOrigin.y, 2*rEEAni, 2*rEEAni);
    endEffector.setFill(color(200));
    
  }
  
  void update_animation(float th1, float th2, float xE, float yE){
    background(255);
    
    for (StringMaterialCircle circle : circles) {
      if (circle != null)
        shape(circle.wall);
    }
    for (int i = 0; i < strings.length; i++) {
      if (strings[i] != null && (i < 24 || menuVisible))
        shape(strings[i].wall);
    }
    
    fill(1);
    textSize(35);
    text("Scale: ", 40, 620);
    text(scaleNames[getScale()], 150, 620);    
    text("Key: ", 40, 570);
    text(keys[getKey()], 125, 570); 
    text("Freq:", 750, 620);
    text((int)pitchFreq, 850, 620);
    text(pitchLetter, 850, 570);
        
    textSize(20);
    text("M", 807,75);

    if (menuVisible) {
      for (int i = 0; i < 12; i++) {
        text(keys[i], 140, 105 + i*0.0085*pixelsPerMeter);
      }
      for (int i = 0; i < 5; i++) {
        text(scaleNamesShort[i], 830, 130 + i*0.01*pixelsPerMeter);
      }
      for (int i = 0; i < 3; i++) {
        if (slots[i][0] != -1 && slots[i][1] != -1) {
          text(keys[slots[i][0]], 830, 370 + i*0.01*pixelsPerMeter);
          text(scaleNamesShort[slots[i][1]], 860, 370 + i*0.01*pixelsPerMeter);
        }
      }
    }
    for (int i = 0; i < 24; i++) {
      if ((i==0 && pitches[0] != pitches[23]) || i>0 && pitches[i] != pitches[i-1]) {
        int angle = i*15+8;
        float meanRad = (innerRadius + outerRadius)/2;
        text(noteNames[i], 485 + meanRad*sin(angle*PI/180)*pixelsPerMeter, 4000*0.085 + 5 - meanRad*cos(angle*PI/180)*pixelsPerMeter);
      }
    }
      
    xE = pixelsPerMeter * xE;
    yE = pixelsPerMeter * yE;
    translate(xE, yE);
    shape(endEffector);
  }
  
  PVector device_to_graphics(PVector deviceFrame){
    return deviceFrame.set(-deviceFrame.x, deviceFrame.y);
  }
  
  PVector graphics_to_device(PVector graphicsFrame){
    return graphicsFrame.set(-graphicsFrame.x, graphicsFrame.y);
  }
  
}
