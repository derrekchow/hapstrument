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


  Range range;

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
  float average_Vel_x;

  BowModel(PApplet _this, Range _range) {
    super();
    range = _range;
    
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
    circle(posEE.x*width + width/2, posEE.y*height, 10);
    world.draw();
  }


  void set_data(float[] _angles, float[] _pos) {
    
    //float x = map(_pos[0], 0, 1, 0.095, -0.095);
    //float y = map(_pos[1], 0, 1, 0.022, 0.149);
    float x = map(_pos[0], range.minX, range.maxX, -1, 1);
    float y = map(_pos[1], range.minY, range.maxY, 0, 1);
    //float x = _pos[0];
    //float y = _pos[1];
    
    angles.set(_angles);
    posEE.set(x, y);

    s.setToolPosition(edgeTopLeftX+worldWidth/2-(posEE).x, edgeTopLeftY+(posEE).y-7); 
    s.updateCouplingForce();


    forceEE.set(-s.getVirtualCouplingForceX(), s.getVirtualCouplingForceY());
    forceEE.div(100000); //dynes to newtons


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
    //forceEE.x = Vel_x.get(i) * 2;
    
    if(posEE.x > 0){
      forceEE.x = 4.5 / (pow(Vel_x.get(i), 2) + 1);
    
    }
    else{
      forceEE.x = -4.5 / (pow(Vel_x.get(i), 2) + 1);
    
    }
    
    i += 1;
    forceEE.div(2);
    world.step(1.0f/1000.0f);
    
    average_Vel_x = 0;
    for (int j = max(i-100, 0); j < i; j++) {
      average_Vel_x += Vel_x.get(j)/100;
    }
    message = new float[]{abs(average_Vel_x*0.3)};

  }
}
