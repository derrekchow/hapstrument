import java.util.ArrayList;

public class BowModel extends Model {

  float             pixelsPerCentimeter                 = 40.0;

  PVector           angles                              = new PVector(0, 0);
  PVector           torques                             = new PVector(0, 0);

  /* task space */
  PVector           posEELast                           = new PVector(-0.01, -0.01);

  /* World boundaries */
  FWorld            world;
  float             worldWidth                          = 25.0;  
  float             worldHeight                         = worldWidth*650/1000; 

  float             edgeTopLeftX                        = 0.0; 
  float             edgeTopLeftY                        = 0.0; 
  float             edgeBottomRightX                    = worldWidth; 
  float             edgeBottomRightY                    = worldHeight;

  float             gravityAcceleration                 = 0; //cm/s2
  /* Initialization of virtual tool */
  HVirtualCoupling  s;

  FBox              l1;


  FLine             L1;
  float             K                        = 5; /* Stiffness */




  long              t0 = System.nanoTime();
  ArrayList<Float> pos_x = new ArrayList<Float>();
  ArrayList<Float> pos_y = new ArrayList<Float>();
  ArrayList<Float> time = new ArrayList<Float>();
  ArrayList<Float> Vel_x = new ArrayList<Float>();
  ArrayList<Float> Acc_x = new ArrayList<Float>();
  //ArrayList<Float> Vel_y = new ArrayList<>();
  int i = 1;
  int k = 1;
  //float Vel_x;
  float Vel_y;




  BowModel(PApplet _this) {
    hAPI_Fisica.init(_this); 
    hAPI_Fisica.setScale(pixelsPerCentimeter); 
    world               = new FWorld();





    L1 = new FLine(worldWidth/2, 0, worldWidth/2, worldHeight);
    world.add(L1);

    l1                  = new FBox(worldWidth, worldHeight);
    l1.setPosition(worldWidth/2, worldHeight/2);
    l1.setFill(150, 150, 255, 80);
    l1.setDensity(100);
    l1.setSensor(true);
    l1.setNoStroke();
    l1.setStatic(true);
    l1.setName("TopRight");
    //l1.setDamping(600);
    //world.add(l1);

    /* Setup the Virtual Coupling Contact Rendering Technique */

    s                   = new HVirtualCoupling((0.5)); 
    s.h_avatar.setDensity(4); 
    s.h_avatar.setFill(255, 0, 0); 
    s.h_avatar.setSensor(true);

    s.init(world, edgeTopLeftX+worldWidth/2, edgeTopLeftY+2); 

    /* World conditions setup */
    world.setGravity((0.0), gravityAcceleration); //1000 cm/(s^2)
    world.setEdges((edgeTopLeftX), (edgeTopLeftY), (edgeBottomRightX), (edgeBottomRightY)); 
    world.setEdgesRestitution(.4);
    world.setEdgesFriction(0.5);

    time.add(t0 / 1e9);
    Vel_x.add(s.getAvatarVelocityX());
    Acc_x.add(0.0);

    world.draw();
  }

  void draw_graphics() {
    background(255);
    world.draw();
  }


  void set_data(float[] _angles, float[] _pos) {
    angles.set(_angles);
    posEE.set(_pos[0], _pos[1]).mult(200);

    s.setToolPosition(edgeTopLeftX+worldWidth/2-(posEE).x, edgeTopLeftY+(posEE).y-7); 
    s.updateCouplingForce();


    forceEE.set(-s.getVirtualCouplingForceX(), s.getVirtualCouplingForceY());
    forceEE.div(100000); //dynes to newtons





    /* Layer codes */

    //print("posEE.x = ", ((posEE.x) * (-1)), "\n");
    //print("posEE.y = ", ((posEE.y) * (-1) + 15), "\n");
    //print("------------------------\n");

    //pos_x.add((posEE.x) * (-1));
    //pos_y.add((posEE.y) * (-1) + 15);
    //time.add((System.nanoTime() - t0)/1e9);

    //if (i > 0 && i%15==0){
    //  Vel_x = ((pos_x.get(i) - pos_x.get(i-1)) / (time.get(i) - time.get(i-1)));
    //  Vel_y = ((pos_y.get(i) - pos_y.get(i-1)) / (time.get(i) - time.get(i-1)));
    //  //k += 1;
    //  //print("dt = ", time.get(i) - time.get(i-1), "\n");

    //}

    //forceEE.x = (abs((posEE.y) * (-1) + 15) * Vel_x)/70;

    //if (i == 1){
    //  Vel_x.add(((pos_x.get(i) - pos_x.get(i-1)) / (time.get(i) - time.get(i-1))));
    //}
    //else if (i > 1 && ((pos_x.get(i) - pos_x.get(i-1)) / (time.get(i) - time.get(i-1))) - Vel_x.get(i-1) > 1){
    //  Vel_x.add(Vel_x.get(i-1) + 0.5);
    //}

    //else if(i > 1 && ((pos_x.get(i) - pos_x.get(i-1)) / (time.get(i) - time.get(i-1))) - Vel_x.get(i-1) < -1){
    //  Vel_x.add(Vel_x.get(i-1) - 0.5);
    //  }

    //print(s.getAvatarVelocityX());
    //print("\n");

    //if (i%10==0){
    //  Vel_x.add(s.getAvatarVelocityX());
    //  time.add((System.nanoTime() - t0)/1e9);
    //  Acc_x.add((Vel_x.get(k) - Vel_x.get(k-1)) / (time.get(k) - time.get(k-1)));

    //  k += 1;
    //  print(time.get(k) - time.get(k-1), '\n');
    //}

    if (s.getAvatarVelocityX() * Vel_x.get(i-1) < 0) {
      Vel_x.add(0.0);
    } else {
      Vel_x.add(s.getAvatarVelocityX());
    }



    //Vel_x.add(s.getAvatarVelocityX());
    time.add((System.nanoTime() - t0)/1e9);
    //Acc_x.add((Vel_x.get(i) - Vel_x.get(i-1)) / (time.get(i) - time.get(i-1)));
    //print(time.get(i) - time.get(i-1), "\n");
    //forceEE.x = s.getAvatarVelocityX() / (15) + (0.1) * posEE.x;
    forceEE.x = Vel_x.get(i) / 10;
    //forceEE.x = 7.5 / (Vel_x.get(i)+5);
    //float sigma = Vel_x.get(i-1);
    //float mu = 0.0;
    //forceEE.x = 10/(sigma * sqrt(2*3.14)) * exp(-(s.getToolPositionX() -12.5 -12.5) * (s.getToolPositionX() -12.5 -12.5)/ (2 * sigma * sigma));

    //+ (-1/10) * posEE.x;
    //s.setVirtualCouplingDamping(500);
    print("posEE.x = ", s.getToolPositionX(), "\n---------------\n");
    print("posEE.y = ", s.getToolPositionY(), "\n---------------\n");
    print("forceEE.x = ", forceEE.x, "\n-----------------\n");
    //k += 1;
    i += 1;
    
    //message = new float[]{}



    forceEE.div(3);

    world.step(1.0f/1000.0f);
  }
}
