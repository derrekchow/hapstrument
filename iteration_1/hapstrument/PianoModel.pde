public class PianoModel extends Model {
  
  /* Screen and world setup parameters */
  float             pixelsPerMeter                      = 4000.0;
  float             radsPerDegree                       = 0.01745;
  
  /* pantagraph link parameters in meters */
  float             l                                   = 0.07;
  float             L                                   = 0.09;
  
  /* end effector radius in meters */
  float             rEE                                 = 0.006;
  
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
  PShape wall;
  
  /* piano elements */
  StringMaterial[] strings = new StringMaterial[34];
  float pianoTop = 0.06;
  float pianoMid = 0.095;
  float pianoBottom = 0.12;
  String pitchLetter = "";
  float pitchMIDI = 60;
  float pitchFreq = 0;
  boolean continuousPitch = true; 
  
  /* piano info */
  String[] topRowLetters = {"C", "C#", "D", "Eb", "E", "F", "F#", "G", "G#", "A", "Bb", "B", "C", "C#", "D", "Eb", "E"};
  float topRowBounds[] = {-0.1, -0.087, -0.075, -0.065, -0.053, -0.04, -0.028, -0.016, -0.006, 0.006, 0.016, 0.028, 0.04, 0.053, 0.065, 0.075, 0.087, 0.1};
  String[] bottomRowLetters = {"C", "D", "E", "F", "G", "A", "B", "C", "D", "E"};
  float bottomRowBounds[] = {-0.1, -0.08, -0.06, -0.04, -0.02, 0, 0.02, 0.04, 0.06, 0.08, 0.1};
  float[] bottomRowMidi = {60, 62, 64, 65, 67, 69, 71, 72, 74, 76};
  
  /* end elements definition *********************************************************************************************/ 
  
  
  /* setup section *******************************************************************************************************/
  PianoModel(){
    
    /* visual elements setup */
    background(0);
    deviceOrigin.add(worldPixelWidth/2, 0);
    
    /* create pantagraph graphics */
    create_pantagraph();
    
    /* create string graphics */
    strings[0] = new StringMaterial(true, pianoTop, pianoBottom, -0.1, pixelsPerMeter, deviceOrigin);
    strings[1] = new StringMaterial(true, pianoMid, pianoBottom, -0.08, pixelsPerMeter, deviceOrigin);
    strings[2] = new StringMaterial(true, pianoMid, pianoBottom, -0.06, pixelsPerMeter, deviceOrigin);
    strings[3] = new StringMaterial(true, pianoTop, pianoBottom, -0.04, pixelsPerMeter, deviceOrigin);
    strings[4] = new StringMaterial(true, pianoMid, pianoBottom, -0.02, pixelsPerMeter, deviceOrigin);
    strings[5] = new StringMaterial(true, pianoMid, pianoBottom, 0, pixelsPerMeter, deviceOrigin);
    strings[6] = new StringMaterial(true, pianoMid, pianoBottom, 0.02, pixelsPerMeter, deviceOrigin);
    strings[7] = new StringMaterial(true, pianoTop, pianoBottom, 0.04, pixelsPerMeter, deviceOrigin);
    strings[8] = new StringMaterial(true, pianoMid, pianoBottom, 0.06, pixelsPerMeter, deviceOrigin);
    strings[9] = new StringMaterial(true, pianoMid, pianoBottom, 0.08, pixelsPerMeter, deviceOrigin);
    strings[10] = new StringMaterial(true, pianoTop, pianoBottom, 0.1, pixelsPerMeter, deviceOrigin);
    strings[11] = new StringMaterial(false, -0.1, 0.1, pianoTop, pixelsPerMeter, deviceOrigin);
    strings[12] = new StringMaterial(false, -0.1, 0.1, pianoBottom, pixelsPerMeter, deviceOrigin);
    
    strings[13] = new StringMaterial(true, pianoTop, pianoMid, -0.087, pixelsPerMeter, deviceOrigin);
    strings[14] = new StringMaterial(true, pianoTop, pianoMid, -0.075, pixelsPerMeter, deviceOrigin);
    strings[15] = new StringMaterial(true, pianoTop, pianoMid, -0.065, pixelsPerMeter, deviceOrigin);
    strings[16] = new StringMaterial(true, pianoTop, pianoMid, -0.053, pixelsPerMeter, deviceOrigin);
    strings[17] = new StringMaterial(false, -0.087, -0.075, pianoMid, pixelsPerMeter, deviceOrigin);
    strings[18] = new StringMaterial(false, -0.065, -0.053, pianoMid, pixelsPerMeter, deviceOrigin);
  
    strings[19] = new StringMaterial(true, pianoTop, pianoMid, -0.028, pixelsPerMeter, deviceOrigin);
    strings[20] = new StringMaterial(true, pianoTop, pianoMid, -0.016, pixelsPerMeter, deviceOrigin);
    strings[21] = new StringMaterial(true, pianoTop, pianoMid, -0.006, pixelsPerMeter, deviceOrigin);
    strings[22] = new StringMaterial(true, pianoTop, pianoMid, 0.006, pixelsPerMeter, deviceOrigin);
    strings[23] = new StringMaterial(true, pianoTop, pianoMid, 0.016, pixelsPerMeter, deviceOrigin);
    strings[24] = new StringMaterial(true, pianoTop, pianoMid, 0.028, pixelsPerMeter, deviceOrigin);
    strings[25] = new StringMaterial(false, -0.028, -0.016, pianoMid, pixelsPerMeter, deviceOrigin);
    strings[26] = new StringMaterial(false, -0.006, 0.006, pianoMid, pixelsPerMeter, deviceOrigin);
    strings[27] = new StringMaterial(false, 0.016, 0.028, pianoMid, pixelsPerMeter, deviceOrigin);
    
    strings[28] = new StringMaterial(true, pianoTop, pianoMid, 0.087, pixelsPerMeter, deviceOrigin);
    strings[29] = new StringMaterial(true, pianoTop, pianoMid, 0.075, pixelsPerMeter, deviceOrigin);
    strings[30] = new StringMaterial(true, pianoTop, pianoMid, 0.065, pixelsPerMeter, deviceOrigin);
    strings[31] = new StringMaterial(true, pianoTop, pianoMid, 0.053, pixelsPerMeter, deviceOrigin);
    strings[32] = new StringMaterial(false, 0.075, 0.087, pianoMid, pixelsPerMeter, deviceOrigin);
    strings[33] = new StringMaterial(false, 0.053, 0.065, pianoMid, pixelsPerMeter, deviceOrigin);
  }
  
  void draw_graphics(){
      background(255); 
      update_animation(angles.x*radsPerDegree, angles.y*radsPerDegree, posEE.x, posEE.y);
  }
  
  void set_data(float[] _angles, float[] _pos) {
    angles.set(_angles); 
    posEE.set(_pos);
    posEE.set(device_to_graphics(posEE)); 
    
    // Call function to calculate string force
    StringForce returnValue = calculateForce(strings, posEE);
    boolean justCrossedString = returnValue.justCrossedString;
    forceEE = returnValue.forceEE;
 
    forceEE.set(graphics_to_device(forceEE));

    
    // Calculate pitch
    if (justCrossedString) { // If just moved across a string
      if (posEE.y < pianoTop || posEE.y > pianoBottom) { // If above or below the keyboard
        continuousPitch = true;
      } else {
        continuousPitch = false;
        if (posEE.y > pianoTop && posEE.y < pianoMid) { // Black and white keys
          int i = 0;
          while (posEE.x > topRowBounds[i]) {i++;}
          pitchLetter = topRowLetters[i-1];
          pitchMIDI = 60 + i - 1;
        } else if (posEE.y > pianoMid && posEE.y < pianoBottom) { // Just white keys
          int i = 0;
          while (posEE.x > bottomRowBounds[i]) {i++;}
          pitchLetter = bottomRowLetters[i-1];
          pitchMIDI = bottomRowMidi[i-1];
        }
      }
    }
    if (continuousPitch) {
      pitchLetter = "";
      pitchMIDI = 60.4 + (posEE.x + 0.09)/0.18*15.3;
    }
    pitchFreq = pow(2,(pitchMIDI-69)/12) * 440; // Convert MIDI note number into frequency
    message = new float[]{pitchFreq};
  }
    
  /* helper functions section, place helper functions here ***************************************************************/
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
      shape(string.wall);
    }
    
    textSize(70);
    fill(1);
    text(pitchLetter, 750, 150);
    textSize(50);
    text("Midi:", 80, 100);
    text("Freq:", 80, 150);
    text((int)pitchMIDI, 220, 100);
    text((int)pitchFreq, 220, 150);
  
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
