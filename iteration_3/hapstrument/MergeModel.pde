class MergeModel extends Model {
  Model modelA, modelB;
  Range range;
  float lerpY = 0;
  float sigmoidY = 0;
  float visualY = 0;
  

  MergeModel(Model _modelA, Model _modelB, Range _range) {
    super();
    modelA = _modelA;
    modelB = _modelB;
    range = _range;
  }

  void set_data(float[] _angles, float[] _pos) {
    //lerpY = _pos[1]/0.153; // expects 0 to 1
    lerpY = map(_pos[1], range.minY, range.maxY, 0, 1);
    sigmoidY = 1/ (1+exp(-20 * (lerpY-0.5)));
    visualY = _pos[1]*20  - 1;
    
    modelA.set_data(_angles, _pos);
    modelB.set_data(_angles, _pos);
    
    forceEE = PVector.lerp(modelA.get_force(), modelB.get_force(), sigmoidY);
    //print("forceEE", forceEE, "\n");
    
    float[] messageA = modelA.get_message();
    float[] messageB = modelB.get_message();
    message = new float[]{messageA[0]*(1-sigmoidY) + messageB[0]*sigmoidY};
  }

  void draw_graphics() {
    circle(posEE.x*width + width/2, posEE.y*height, 10);
    fill(255, 255*(1-visualY));
    rect(0, 0, width, height);
    modelA.draw_graphics();
    
    fill(255, 255*visualY);
    rect(0, 0, width, height);
    modelB.draw_graphics();
    
  }
}
