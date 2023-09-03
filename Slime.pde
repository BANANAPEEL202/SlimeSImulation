import java.util.*;
import com.hamoid.*;
static int WIDTH = 1200;
static int HEIGHT = 900;

//Setup Settings
static int numAgents = 500000;
int SPAWNMODE = 2;  //0 = point
                    //1 = random
                    //2 = inward circle
                    //3 = random circle
                    //4 = outward circle
                    //5 = inward circle outline
                    //6 = outward circle outline
float radius =350;

//Map Settings
static int UPDATESPERSEC = 1;
static float SPEED = 1;
float EVAPORATION = 0.01*UPDATESPERSEC;
float DIFFUSERATE = 0.5; // 0, more like original, 1, more like diffused

//Agent Settings
static float SENSORANGLEDEGREES =35;
static int SIZE = 1;
static float DISTANCE = 10 ; 
static float TURNSPEED =20;
static float TRAILWEIGHT = 5;

boolean showStats = false; 
boolean record = false; // set true to record from start
VideoExport videoExport;
int recordedFrame = 0;

boolean useColor = false;
color primaryColor =  color(14,252,217);
color secondaryColor = color (14,55,126);

static float[][] map = new float[HEIGHT][WIDTH];
Agent[] agents = new Agent[numAgents];

static int numPartitions = 100;
static int partitionSize = numAgents/numPartitions;
static boolean[] partitionsDone = new boolean[partitionSize];
Partition[] partitions = new Partition[numPartitions];


void settings()
{
  size(WIDTH, HEIGHT, P2D);
}

void setup()
{
  for (int i = 0; i < HEIGHT; i++)
  {
    for (int j = 0; j < WIDTH; j++)
    {
      map[i][j] = 0;
    }
  }
  
  for (int i = 0; i < numAgents; i++)
  {
    float randomAngle = random(0, 2*PI);
    float angle = randomAngle;
    PVector startPos = new PVector(0,0);
    if (SPAWNMODE == 0) //point
      {
        startPos = new PVector(WIDTH/2, HEIGHT/2);
        angle = randomAngle;
      }
      else if (SPAWNMODE == 1) // random
      {
        startPos = new PVector(round(random(0, WIDTH)), round(random(0, HEIGHT)));
        angle = randomAngle;
      }
      else if (SPAWNMODE == 2) // inward circle
      {
        float r = radius*sqrt(random(0, 1));
        float randomAngle2 = random(0, 2*PI);
        int x = (int) (WIDTH/2 + cos(randomAngle2)*r);
         int y= (int) (HEIGHT/2 + sin(randomAngle2)*r);
        startPos = new PVector(x, y);
        angle = atan2(HEIGHT/2-y,WIDTH/2-x);
      }
      else if (SPAWNMODE == 3) // random circle
      {
        float r = radius*sqrt(random(0, 1));
        float randomAngle2 = random(0, 2*PI);
        int x = (int) (WIDTH/2 + cos(randomAngle2)*r);
         int y= (int) (HEIGHT/2 + sin(randomAngle2)*r);
        startPos = new PVector(x, y);
        angle = randomAngle;
      }
        else if (SPAWNMODE == 4) // outward circle
      {
       float r = radius*sqrt(random(0, 1));
        int x = (int) (WIDTH/2 + cos(randomAngle)*r);
         int y= (int) (HEIGHT/2 + sin(randomAngle)*r);
        startPos = new PVector(x, y);
        angle = randomAngle;
      }
       else if (SPAWNMODE == 5) // inward circle outline
      {
        float r = radius;
        int x = (int) (WIDTH/2 + cos(randomAngle)*r);
         int y= (int) (HEIGHT/2 + sin(randomAngle)*r);
        startPos = new PVector(x, y);
         angle = atan2(HEIGHT/2-y,WIDTH/2-x);
      }
       else if (SPAWNMODE == 6) // outward circle
      {
        float r = radius;
        int x = (int) (WIDTH/2 + cos(randomAngle)*r);
         int y= (int) (HEIGHT/2 + sin(randomAngle)*r);
        startPos = new PVector(x, y);
        angle = randomAngle;
      }
    agents[i] = (new Agent(startPos, angle, i));
  }
  /*
  for (int i = 0; i < numPartitions; i++)
  {
     partitions[i] = new Partition(Arrays.copyOfRange(agents, i*partitionSize, (i+1)*partitionSize), i);
  }
  */
  
}

void keyPressed()
{
  if (keyCode == ' ')
  {
    showStats = true;
  }
  if (key =='r' || key == 'R')
  {
    if (record == false)
    {
      println("Recording");
    }
    else
    {
      videoExport.endMovie();
      println("End Recording");
      recordedFrame = 0;
    }
    record = !record;

  }
}

void keyReleased()
{ if (keyCode == ' ')
  {
    showStats = false;
  }
}



void draw()
{
  
  for (Agent agent: agents)
  {
    agent.update();
  }

  

  

  updateMap();
  
  displayMap();
  if (showStats)
  {
  textSize(18);
  text("Agents: " + str(numAgents), 10, 25);
  text("Speed: " + str(SPEED), 10, 45); 
  text("Evaporation: " + str(EVAPORATION/SPEED), 10,65); 
  text("Diffuse Rate: " + str(DIFFUSERATE), 10,85); 
  text("Sensor Angle: " + str(SENSORANGLEDEGREES)+"°", 10,105); 
  text("Sensor Size: " + str(SIZE), 10,125); 
  text("Sensor Distance: " + str(DISTANCE), 10,145); 
  text("Turn Speed: " + str(TURNSPEED) + "°", 10,165); 
  text("Trail Weight: " + str(TRAILWEIGHT), 10,185); 
  text("FPS: " + str(frameRate).substring(0,4) ,10, 205); 
  }
  if (record)
  {
    record();
    fill(color(241,36,0));
    ellipse(WIDTH-20, 20, 10, 10);
    fill(color(255, 255, 255));
  }
}

void updateMap()
{
  //DIFFUSE

  for (int y = 0; y < HEIGHT; y++)
  {
    for (int x = 0; x < WIDTH; x++)
    {
      float sum = 0;
       for (int offsetX = -1; offsetX <= 1; offsetX ++) {
        for (int offsetY = -1; offsetY <= 1; offsetY ++) {
          int sampleX = min(WIDTH-1, max(0, x + offsetX));
          int sampleY = min(HEIGHT-1, max(0, y + offsetY));
          sum += map[sampleY][sampleX];
        }
        }
        map[y][x] = max(0, lerp(map[y][x], sum/9.0, DIFFUSERATE) - EVAPORATION);
  }
  
  /*
  for (int x = 0; x < WIDTH; x++)
  {
    map[450][x] = 1;
  }
  */

  
  }
}

void displayMap()
{
  loadPixels();
  for (int y = 0; y < HEIGHT; y++)
  {
    for (int x = 0; x < WIDTH; x++)
    {
      float value = (map[y][x]);
      pixels[x+(y*WIDTH)] =  color(value*255);
      
      if (useColor)
      {
      int loc = x + y*WIDTH;
     
     

    if (value != 0)
    {
      color c;
     if (value > .5)
     {
     c = lerpColor(secondaryColor, primaryColor, (value-0.5)*2);
     }
     else
     {
       c = lerpColor(color (0,0,0), secondaryColor, value*2);
     }
    

    pixels[loc] = c;
    }
      }
    
    
    
    
    }
  }
  updatePixels();
}

void record()
{
  if (recordedFrame == 0)
  {
    String path = "Slime Simulation.mp4";
    int increment = 0;
    while (new File("/Users/home/Documents/Processing/Slime/" + path).exists())
    {
      increment ++;
      path = "Slime Simulation (" + increment + ").mp4";
    }
    
    videoExport = new VideoExport(this, path);
    videoExport.setFrameRate(30);
    videoExport.startMovie();
    
    background(0);
     textSize(18);
  text("Agents: " + str(numAgents), 10, 25);
  text("Speed: " + str(SPEED), 10, 45); 
  text("Evaporation: " + str(EVAPORATION/SPEED), 10,65); 
  text("Diffuse Rate: " + str(DIFFUSERATE), 10,85); 
  text("Sensor Angle: " + str(SENSORANGLEDEGREES)+"°", 10,105); 
  text("Sensor Size: " + str(SIZE), 10,125); 
  text("Sensor Distance: " + str(DISTANCE), 10,145); 
  text("Turn Speed: " + str(TURNSPEED) + "°", 10,165); 
  text("Trail Weight: " + str(TRAILWEIGHT), 10,185); 
  text("FPS: " + str(frameRate).substring(0,4) ,10, 205); 
  videoExport.saveFrame();
  
  }
  recordedFrame++;
  videoExport.saveFrame();
}


boolean isAllTrue(boolean[] array)
{
    for(boolean b : array) if(!b) return false;
    return true;
}
