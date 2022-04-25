import processing.serial.*;

class Range {
  float minX;
  float maxX;
  float minY;
  float maxY;

  Range(float _minX, float _maxX, float _minY, float _maxY) {
    minX = _minX;
    maxX = _maxX;
    minY = _minY;
    maxY = _maxY;
  }
}

class Haply {
  Board haplyBoard;
  Device haply;
  Mechanisms pantograph;
  Model model;
  byte haplyID = 5;
  int CW = 0;
  int CCW = 1;

  Haply(PApplet _this, int index, Model _model) {
    haplyBoard = new Board(_this, Serial.list()[index], 0);
    haply = new Device(haplyID, haplyBoard);
    pantograph = new Pantograph();
    model = _model;

    haply.set_mechanism(pantograph);
    haply.add_actuator(1, CCW, 2);
    haply.add_actuator(2, CW, 1);
    haply.add_encoder(1, CCW, 241, 10752, 2);
    haply.add_encoder(2, CW, -61, 10752, 1);
    haply.device_set_parameters();
  }

  void update() {
    if (haplyBoard.data_available()) {
      set_model();
    }

    send_force();
  }

  void set_model() {
      haply.device_read_data();
      
      float[] angles = haply.get_device_angles();
      float[] pos = haply.get_device_position(angles);

      model.set_data(angles, pos);
  }

  void draw_graphics() {
    model.draw_graphics();
  }

  float[] get_message() {
    return model.get_message();
  }

  private void send_force() {
    haply.set_device_torques(model.get_force().array());
    haply.device_write_torques();
  }
}
