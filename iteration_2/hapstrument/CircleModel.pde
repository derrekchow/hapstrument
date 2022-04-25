class CircleModel extends Model {
  
  //          Keys:  C  C# D  Eb E  F  F# G  G# A  Bb  B      // Scales
  int[] chromatic = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};   //   0
  int[] major     = {0, 0, 2, 2, 4, 5, 5, 7, 7, 9, 9, 11};    //   1
  int[] minor     = {0, 0, 2, 3, 3, 5, 5, 7, 8, 8, 8, 11};    //   2
  int[] blues     = {0, 0, 0, 3, 3, 5, 6, 7, 7, 7, 10, 10};   //   3
  int[] whole     = {0, 0, 2, 2, 4, 4, 6, 6, 8, 8, 10, 10};   //   4
  
  int keyNum = 10; // C, C#, ...
  int scaleNum = 0; // chromatic, major, ...
  
  int[][] allScales = {chromatic, major, minor, blues, whole};
  int[] scale = allScales[scaleNum];

  String[] keys = {"C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B", "C", "C#", "D", "Eb", "E"};
  String[] scaleNames = {"Chromatic", "Major", "Minor", "Blues", "Whole Tone"};
  String[] noteNames = {"C3", "C#3", "D3", "Eb3", "E3", "F3", "F#3", "G3", "G#3", "A4", "Bb4", "B4", "C4", "C#4", "D4", "Eb4", "E4", "F4", "F#4", "G4", "G#4", "A5", "Bb5", "B5"};

  int[] pitches = new int[24];
  String pitchLetter = "";
  float pitchMIDI = 60;
  float pitchFreq = 0;
  boolean continuousPitch = true; 
  
  /* Screen and world setup parameters */
  float             pixelsPerMeter                      = 4000.0;
  float             radsPerDegree                       = 0.01745;
  
  /* pantagraph link parameters in meters */
  float             l                                   = 0.07;
  float             L                                   = 0.09;
  
  /* end effector radius in meters */
  float             rEE                                 = 0.004;
  
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
  
  float circleCenterY = 0.085;
  float innerRadius = 0.045;
  float outerRadius = 0.065;

  StringMaterial[] strings = new StringMaterial[72];

  CircleModel() {

    /* visual elements setup */
    background(0);
    deviceOrigin.add(worldPixelWidth/2, 0);
    
    /* create pantagraph graphics */
    create_pantagraph();

    for (int i = 0; i < pitches.length; i++) {
      if (i < 12)
        pitches[i] = scale[i];    
      else
        pitches[i] = scale[i-12] + 12;    
    }
    int[] oldPitches = pitches.clone();
    for (int i = 0; i < pitches.length; i++) {    
      if (i - keyNum >= 0)
         pitches[i] = oldPitches[i - keyNum] + keyNum;
      else {
         pitches[i] = oldPitches[i - keyNum + 12] + keyNum - 12;
      }
    }
    if (pitches [0] < 0) {
       pitches[0] = pitches[23];
    }
    PVector[] outerPoints = new PVector[24];
    PVector[] innerPoints = new PVector[24];
    for (int i = 0; i < 24; i++) {
      int angle = 180 - i*15;
      innerPoints[i] = new PVector(innerRadius * sin(angle*PI/180), innerRadius * cos(angle*PI/180) + circleCenterY);
      outerPoints[i] = new PVector(outerRadius * sin(angle*PI/180), outerRadius * cos(angle*PI/180) + circleCenterY);
    }
    
    for (int i = 0; i < 24; i++) {
      if ((i==0 && pitches[0] != pitches[23]) || i>0 && pitches[i] != pitches[i-1]) {
        strings[i*3] = new StringMaterial(innerPoints[i].x, innerPoints[i].y, outerPoints[i].x, outerPoints[i].y, 350, pixelsPerMeter, deviceOrigin);
      }
      strings[i*3+1] = new StringMaterial(innerPoints[i].x, innerPoints[i].y, innerPoints[(i+1)%24].x, innerPoints[(i+1)%24].y, 700, pixelsPerMeter, deviceOrigin);
      strings[i*3+2] = new StringMaterial(outerPoints[i].x, outerPoints[i].y, outerPoints[(i+1)%24].x, outerPoints[(i+1)%24].y, 700, pixelsPerMeter, deviceOrigin);
    }
  }
  
  void draw_graphics(){
    background(255); 
    update_animation(angles.x*radsPerDegree, angles.y*radsPerDegree, posEE.x, posEE.y);
  }
  
  void set_data(float[] _angles, float[] _pos) { 
    angles.set(_angles); 
    posEE.set(_pos);
    posEE.set(device_to_graphics(posEE)); 

    StringForce returnValue = calculateForce(strings, posEE);
    forceEE = returnValue.forceEE;
    forceEE.set(graphics_to_device(forceEE));
    
    // Calculate pitch
    float angle = atan2(-posEE.x, (posEE.y-circleCenterY))/PI*180 +180;
    if (returnValue.justCrossedString) { // If just moved across a string
      float distFromMiddle = sqrt(pow(posEE.y - circleCenterY,2) + pow(posEE.x, 2));
      if (distFromMiddle > outerRadius) { // If outside the ring
        continuousPitch = true;
      } else if (distFromMiddle > innerRadius) { // If inside the ring
        continuousPitch = false;
        int pos = min(floor((angle)/15),23); // Make sure it's never 24
        pitchLetter = noteNames[pos];
        pitchMIDI = 60 + pitches[pos];
      } else {
        continuousPitch = false;
      }
    }
    if (continuousPitch) {
      pitchLetter = "";
      pitchMIDI = 59.5 + angle/360*24;
    }
    pitchFreq = pow(2,(pitchMIDI-69)/12) * 440; // Convert MIDI note number into frequency
    message = new float[]{pitchFreq};
  }
  
  void create_pantagraph(){
    float lAni = pixelsPerMeter * l;
    float LAni = pixelsPerMeter * L;
    float rEEAni = pixelsPerMeter * rEE;
    
    pGraph = createShape();
    pGraph.beginShape();
    pGraph.fill(255);
    pGraph.stroke(0);
    pGraph.strokeWeight(2);
    
    pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
    pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
    pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
    pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
    pGraph.endShape(CLOSE);
    
    joint = createShape(ELLIPSE, deviceOrigin.x, deviceOrigin.y, rEEAni, rEEAni);
    joint.setStroke(color(0));
    
    endEffector = createShape(ELLIPSE, deviceOrigin.x, deviceOrigin.y, 2*rEEAni, 2*rEEAni);
    endEffector.setStroke(color(0));
    strokeWeight(5);
    
  }
  
  void update_animation(float th1, float th2, float xE, float yE){
    background(255);
    
    float lAni = pixelsPerMeter * l;
    float LAni = pixelsPerMeter * L;
    
    xE = pixelsPerMeter * xE;
    yE = pixelsPerMeter * yE;
    
    th1 = 3.14 - th1;
    th2 = 3.14 - th2;
    
    pGraph.setVertex(1, deviceOrigin.x + lAni*cos(th1), deviceOrigin.y + lAni*sin(th1));
    pGraph.setVertex(3, deviceOrigin.x + lAni*cos(th2), deviceOrigin.y + lAni*sin(th2));
    pGraph.setVertex(2, deviceOrigin.x + xE, deviceOrigin.y + yE);
    
    shape(pGraph);
    shape(joint);
    for (StringMaterial string : strings) {
      if (string != null)
        shape(string.wall);
    }
    
    fill(1);
    textSize(40);
    text("Scale: ", 40, 70);
    text(scaleNames[scaleNum], 160, 70);    
    text("Key: ", 40, 150);
    text(keys[keyNum], 130, 150);
    
    text("Midi:", 750, 70);
    text((int)pitchMIDI, 850, 70);
    text("Freq:", 750, 150);
    text((int)pitchFreq, 850, 150);
    text(pitchLetter, 850, 250);
    
    textSize(20);
    text(".", 500, 4000*0.085); 

    for (int i = 0; i < 24; i++) {
      if ((i==0 && pitches[0] != pitches[23]) || i>0 && pitches[i] != pitches[i-1]) {
        int angle = i*15+8;
        float meanRad = (innerRadius + outerRadius)/2;
        text(noteNames[i], 485 + meanRad*sin(angle*PI/180)*pixelsPerMeter, 4000*0.085 + 5 - meanRad*cos(angle*PI/180)*pixelsPerMeter);
      }
    }
  
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
