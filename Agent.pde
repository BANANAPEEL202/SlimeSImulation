public class Agent 
{

  PVector position;
  float angle;
  
   float sensorAngleRad;
    float turnSpeed;
  int id; 
  public Agent(PVector position2, float angle2, int id2) 
  {
    position = position2;
    angle = angle2;
    id = id2;
      sensorAngleRad = SENSORANGLEDEGREES * (PI / 180);

     turnSpeed = TURNSPEED * PI/180;
  }

  public void update()
  {
    for (int i = 0; i < UPDATESPERSEC; i++)
    {
    // Steer based on sensory data
   
     float weightForward = sense(DISTANCE, SIZE, 0);
    float  weightLeft = sense(DISTANCE, SIZE, -sensorAngleRad);
     float weightRight = sense(DISTANCE, SIZE, sensorAngleRad);
    float randomSteerStrength = random(0, 1);
   

    // Continue in same direction
    if (weightForward > weightLeft && weightForward > weightRight) {
      angle += 0;
    } 
    else if (weightForward < weightLeft && weightForward < weightRight) {
      angle -= (randomSteerStrength - 0.5) * 2 * turnSpeed;
    }
    
    // Turn right
    else if (weightRight > weightLeft) {
      angle += randomSteerStrength * turnSpeed;
    }
    // Turn left
    else if (weightLeft > weightRight) {
      angle -= randomSteerStrength * turnSpeed;
    }



//PVector direction = new PVector(cos(angle), sin(angle));
    
    for (int j = 0; j < SPEED; j++)
    {
      position.add(new PVector(cos(angle), sin(angle)));
      if (position.x < 0 || position.x >= WIDTH || position.y < 0 || position.y >= HEIGHT)
      {
        position.x = min(WIDTH-1, max(0, position.x));
        position.y = min(HEIGHT-1, max(0, position.y));
        angle = random(0, 2*PI);
      }
      map[int(position.y)][int(position.x)] = 1;
    }
    }
  }

  float sense(float distance, int size, float sensorAngleOffset) {
    float sensorAngle = angle + sensorAngleOffset;
    PVector sensorDir = new PVector(cos(sensorAngle), sin(sensorAngle));


    int sensorCentreX = (int) (position.x + sensorDir.x * distance);
    int sensorCentreY = (int) (position.y + sensorDir.y * distance);

    float sum = 0;

    //int4 senseWeight = agent.speciesMask * 2 - 1;

    for (int offsetX = -size; offsetX <= size; offsetX ++) {
      for (int offsetY = -size; offsetY <= size; offsetY ++) {
        int sampleX = min(WIDTH - 1, max(0, sensorCentreX + offsetX));
        int sampleY = min(HEIGHT - 1, max(0, sensorCentreY + offsetY));
        //sum += dot(senseWeight, TrailMap[int2(sampleX, sampleY)]);
        //map[sampleY][sampleX] = 1;
        sum += map[sampleY][sampleX];
      }
    }

    return sum*TRAILWEIGHT;
  }
  

}
