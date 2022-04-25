public class Model { 
  protected PVector posEE;             
  protected PVector forceEE;
  protected float[] message = {};
  
  Model () {
    posEE = new PVector(0, 0);
    forceEE = new PVector(0, 0);
  }
  
  public PVector get_force() { return forceEE; }
  public float[] get_message() { return message; }

  public void set_data(float[] angles, float[] pos) { posEE.set(pos); }
  public void draw_graphics() {}
  
}
