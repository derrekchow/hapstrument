import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);

long baseFrameRate = 120;

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pdLocation;
Haply leftHaply;
Haply rightHaply;

void setup() {
  println(Serial.list());
  //leftHaply = new Haply(this, 3, new Range(0.082, -0.096, 0.022, 0.146), new PianoModel());
  rightHaply = new Haply(this, 3, new Range(0.095, -0.095, 0.022, 0.149), new StringModel());

  size(1000, 650);
  frameRate(baseFrameRate);

  oscP5 = new OscP5(this, 8003);
  pdLocation = new NetAddress("127.0.0.1", 8002);

  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS); // runs repeatedly at 1kHz
}

void draw() {
  if (leftHaply != null)leftHaply.draw_graphics();
  if (rightHaply != null) rightHaply.draw_graphics();
}

void addMessage(OscBundle bundle, float[] content, String addr) {
  OscMessage message = new OscMessage(addr);
  message.add(content);
  bundle.add(message);
}

void sendOsc() {
  OscBundle bundle = new OscBundle();
  if (leftHaply != null) addMessage(bundle, leftHaply.get_message(), "/leftHaply");
  if (rightHaply != null) addMessage(bundle, rightHaply.get_message(), "/rightHaply");
  oscP5.send(bundle, pdLocation);
}

void oscEvent(OscMessage msg) {  
  println(msg);
}

class SimulationThread implements Runnable {

  public void run() {
    if (leftHaply != null) leftHaply.update();
    if (rightHaply != null) rightHaply.update();
    //sendOsc();
  }
}
