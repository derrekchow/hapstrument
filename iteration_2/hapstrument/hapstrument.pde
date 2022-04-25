import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
import org.puredata.processing.PureData;
import oscP5.*;
import netP5.*;

long baseFrameRate = 120;

PureData pd;
OscP5 oscP5;
NetAddress pdLocation;
Haply leftHaply;
Haply rightHaply;

boolean OSC = true;

void setup() {
  println(Serial.list());
  //leftHaply = new Haply(this, 3, new BowModel(this));
  rightHaply = new Haply(this, 3, new StringModel(new Range(0.095, -0.095, 0.022, 0.149)));

  size(1000, 650);
  frameRate(baseFrameRate);

  if (OSC) {
    oscP5 = new OscP5(this, 8003);
    pdLocation = new NetAddress("127.0.0.1", 8002);
  } else {
    pd = new PureData(this, 44100, 0, 2);
    pd.openPatch("sound.pd");
    pd.start();
  }

  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS); // runs repeatedly at 1kHz
}

void draw() {
  //if (leftHaply != null) leftHaply.draw_graphics();
  if (rightHaply != null) rightHaply.draw_graphics();
}

void addMessage(OscBundle bundle, float[] content, String addr) {
  OscMessage message = new OscMessage(addr);
  message.add(content);
  bundle.add(message);
}

void sendPd() {
  pd.sendList("leftHaply", leftHaply.get_message());
  pd.sendList("rightHaply", rightHaply.get_message());
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
    
    if (OSC) {
      sendOsc();
    } else {
      sendPd();
    }
  }
}
