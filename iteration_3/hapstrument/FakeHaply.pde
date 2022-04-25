class FakeHaply extends Haply {

  FakeHaply(Model _model) {
    super(_model);
  }

  void update() {
    float[] angles = {0, 0};
    float[] pos = {(float)mouseX/width, (float)mouseY/height};
    
    model.set_data(angles, pos);
  }

  void draw_graphics() {
    model.draw_graphics();
  }

  float[] get_message() {
    return model.get_message();
  }
}
