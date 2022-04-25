public class BumpyModel extends Model {

  float             pixelsPerCentimeter                 = 40.0;

  PVector           angles                              = new PVector(0, 0);
  PVector           torques                             = new PVector(0, 0);

  /* task space */
  PVector           posEELast                           = new PVector(-0.01, -0.01);

  /* World boundaries */
  FWorld            world;
  float             worldWidth                          = 25.0;  
  float             worldHeight                         = 10.0; 

  float             edgeTopLeftX                        = 0.0; 
  float             edgeTopLeftY                        = 0.0; 
  float             edgeBottomRightX                    = worldWidth; 
  float             edgeBottomRightY                    = worldHeight;

  float             gravityAcceleration                 = 0; //cm/s2
  /* Initialization of virtual tool */
  HVirtualCoupling  s;

  FBox              l1;
  FBox              l2;
  FBox              l3;
  FBox              l4;


  float             K                        = 5; /* Stiffness */



  BumpyModel(PApplet _this) {
    hAPI_Fisica.init(_this); 
    hAPI_Fisica.setScale(pixelsPerCentimeter); 
    world               = new FWorld();


    /* Set TopRight */
    l1                  = new FBox(worldWidth/2, worldHeight * 3/4);
    l1.setPosition(worldWidth/4 + worldWidth/2, worldHeight * 3/8);
    l1.setFill(150, 150, 255, 80);
    l1.setDensity(100);
    l1.setSensor(true);
    l1.setNoStroke();
    l1.setStatic(true);
    l1.setName("TopRight");
    world.add(l1);

    /* Set TopLeft */
    l2                  = new FBox(worldWidth/2, worldHeight * 3/4);
    l2.setPosition(worldWidth/4, worldHeight * 3/8);
    l2.setFill(150, 150, 255, 80);
    l2.setDensity(100);
    l2.setSensor(true);
    l2.setNoStroke();
    l2.setStatic(true);
    l2.setName("TopLeft");
    world.add(l2);

    /* Set BottomLeft */
    l3                  = new FBox(worldWidth/2, worldHeight/4);
    l3.setPosition(worldWidth/4, worldHeight*7/8);
    l3.setFill(0, 0, 0, 50);
    l3.setDensity(100);
    l3.setSensor(true);
    l3.setNoStroke();
    l3.setStatic(true);
    l3.setName("BottomLeft");
    world.add(l3);

    /* Set BottomRight */
    l4                  = new FBox(worldWidth/2, worldHeight/4);
    l4.setPosition(worldWidth/4 + worldWidth/2, worldHeight*7/8);
    l4.setFill(0, 0, 0, 50);
    l4.setDensity(100);
    l4.setSensor(true);
    l4.setNoStroke();
    l4.setStatic(true);
    l4.setName("BottomRight");
    world.add(l4);  

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
    if (s.h_avatar.isTouchingBody(l1)) {


      print("posEE.y=", (posEE.y - 14.5) * (-1), "\n");
      print("posEE.x=", (posEE.x - worldWidth/2) * (-1), "\n");
      print("-------------------------\n");

      forceEE.y = K * ((posEE.y - 14.5) * (-1));
      forceEE.x = (posEE.x - worldWidth/2) * random(-1, 1);
    } else if (s.h_avatar.isTouchingBody(l2)) {


      print("posEE.y=", (posEE.y - 14.5) * (-1), "\n");
      print("posEE.x=", (posEE.x - worldWidth/2) * (-1), "\n");
      print("-------------------------\n");




      forceEE.x = (posEE.x - worldWidth/2)/4 * random(-1, 1);
      forceEE.y = K * ((posEE.y - 14.5) * (-1));
    } else if (s.h_avatar.isTouchingBody(l3)) {
      print("posEE.y=", (posEE.y - 14.5) * (-1), "\n");
      print("posEE.x=", (posEE.x - worldWidth/2) * (-1), "\n");
      print("-------------------------\n");
      forceEE.x = (posEE.x - worldWidth/2)/4 * random(-1, 1);
      forceEE.y = 0;
    } else if (s.h_avatar.isTouchingBody(l4)) {


      print("posEE.y=", (posEE.y - 14.5) * (-1), "\n");
      print("posEE.x=", (posEE.x - worldWidth/2) * (-1), "\n");
      print("-------------------------\n");

      forceEE.x = (posEE.x - worldWidth/2)/4 * random(-1, 1);
      forceEE.y = 0;
    }
    forceEE.div(3);

    world.step(1.0f/1000.0f);
  }
}
