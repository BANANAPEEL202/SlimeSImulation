public class Partition implements Runnable
{
  Agent[] agents = new Agent[partitionSize];
  int index;
  
  public Partition(Agent[] agents2, int index2)
  {
    index = index2;
    for (int i = 0; i < partitionSize; i++)
    {
      agents[i] = agents2[i];
    }
  }
  
  void run()
  {
    
    for (Agent agent: agents)
    {
      agent.update();
    }
    partitionsDone[index] = true;
  }
}
