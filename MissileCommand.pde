//arraylists and declaring variables
ArrayList<debris> d = new ArrayList<debris>();
ArrayList<laser> l = new ArrayList<laser>();
ArrayList<spark> s = new ArrayList<spark>();
ArrayList<missile> m = new ArrayList<missile>();
ArrayList<bg> b = new ArrayList<bg>();
ArrayList<bigBoss> bb = new ArrayList<bigBoss>();
ArrayList<drone> dd = new ArrayList<drone>();

button misSpd, Reset, boss;

boolean addBoss;

void setup()
{
  size(640,480);
  
  //spawning stuff initially
  for(int i = 0; i < 5; i++) d.add(new debris(random(width), 10));
  
  for(int i = 0; i < 1; i++) bb.add(new bigBoss(random(width), 10));
  
  for(int i = 0; i < 80; i++) b.add(new bg());
  
  for(int i = 0; i < 1; i++) dd.add(new drone(width/2, height/2));
  
  //assigning button names
  misSpd = new button(10, height - 60, 170, 50, "+Speed Missiles");
  Reset = new button(190, height - 60, 120, 50, "Reset");
  boss = new button(320, height - 60, 170, 50, "Implement Boss");
}

void draw()
{
  background(0);
  
  //debris, boss and drone respawn
  if(d.size() < 5) d.add(new debris(random(width), 10));
  if(bb.size() < 1) bb.add(new bigBoss(random(width), 10));
  if(dd.size() < 1) dd.add(new drone(width/2, height/2));
  
  //make stuff appear on screen
  for(int i = 0; i < b.size(); i++) b.get(i).render();//stars
  for(int i = 0; i < d.size(); i++) d.get(i).render();//space debris

  for(int i = 0; i < bb.size(); i++) //boss implemented only when button is clicked, which is why a boolean variable is used in the if statement below.
    {
      if (addBoss == true && bb.get(i).hp > 0) bb.get(i).render();
    }
  
  for(int i = 0; i < l.size(); i++) l.get(i).render();//lasers
  for(int i = 0; i < m.size(); i++) m.get(i).render();//missiles
  for(int i = 0; i < s.size(); i++) s.get(i).render();//sparks
  for(int i = 0; i < dd.size(); i++) dd.get(i).render();//drone
  
  
  //buttons
  misSpd.render();
  Reset.render();
  boss.render();
  
  //garbage collection
  for (int i = 0; i< l.size(); i++)//laser
  {
    if (l.get(i).x < 0 || l.get(i).x > width || l.get(i).y < 0) l.remove(i);//remove laser when off screen
  }
  
  for (int i = 0; i< d.size(); i++)//debris
  {
    if (d.get(i).hp <= 0) d.remove(i);//remove debris when hp drops to 0 (or less)
  }
  
  for (int i = 0; i< bb.size(); i++)//boss
  {
    if (bb.get(i).hp <= 0) bb.remove(i);//remove boss when hp drops to 0 (or less)
  }
  
  for (int i = 0; i< s.size(); i++)//spark
  {
    if (s.get(i).y > height) s.remove(i);//remove sparks when off screen
  }
  
  for (int i = 0; i< m.size(); i++)//missile
  {
    if(d.size() <= 1 || m.get(i).x < -900) m.remove(i);
  }
}

void mousePressed()
{
  l.add(new laser(width/2, height, mouseX, mouseY));//lasers added to array list when mouse is clicked, making them appear through the render function above
  
  if(misSpd.mtop())//increase missile speed with this button
  {
    for (int i = 0; i < m.size(); i++)
    {
      if (m.get(i).x < m.get(i).target.x) m.get(i).sx += 7;
      else m.get(i).sx -= 7;
      
      if (m.get(i).y < m.get(i).target.y) m.get(i).sy += 7;
      else m.get(i).sy -= 7;
      
      println(m.get(i).sx);
      println(m.get(i).sy);
    }
  }
  
  if(Reset.mtop())//reset button
  {
    reset();//applies the reset function
  }
  
  if(boss.mtop())//implement boss button. This button can only be used once, and it will allow for the boss to appear over and over again after it is pressed
  {
    addBoss = true;//pressing the button will make this boolean variable true, which will trigger the if statement in void draw that allows for the boss to render
  }
}

void keyPressed()
{
  m.add(new missile(width/2, height));//missiles fire when any key is pressed
}

class movement//The class that will basically be used by most other classes, handles movement
{
  float x,y,sx,sy;
  
  movement(float a, float b, float c, float d)
  {
    this.x = a;
    this.y = b;
    this.sx = c;
    this.sy = d;
  }
  
  void move()
  {
    this.x += this.sx;
    this.y += this.sy;
  }
}

class laser extends movement//class that handles everything lasers, using the movement class as an extension
{
  laser(float sx, float sy, float dx, float dy)
  {
    super(sx, sy, 14*(dx - sx)/dist(sx,sy,dx,dy),14*(dy - sy)/dist(sx,sy,dx,dy)); 
  }
  
  void render()
  {
    //move code from class movement
    this.move();
    
    //laser drawing
    stroke(255,0,0);
    strokeWeight(3);
    line(this.x, this.y, this.x + this.sx, this.y + this.sy);
    
    //collision detection for debris
    for(int i = 0; i < d.size(); i++)
    {
      if(d.get(i).hp > 0 && dist(this.x,this.y,d.get(i).x, d.get(i).y) < 50)//when distance between debris and laser is less than 50, collision happens
      {
        d.get(i).hp--;//1 hp lost per hit
        
        for(int j = 0; j < 10; j++) s.add(new spark(this.x, this.y));//spark animation added at the coordinates where the laser hit the debris
        
        for(int k = 0; k < 1; k++)
        {
          if(d.get(i).hp >= 4)//splitting space debris per laser hit
          {
            d.add(new debris(d.get(i).x+20, d.get(i).y));//adds another piece of debris next to the one that has been hit by the laser
          }
        }
        
        this.x = -1000;//moves laser off scree, which helps with garbage collection done above
      }
    }
    
    //collision detection for boss
    for(int i = 0; i < bb.size(); i++)
    {
      if(bb.get(i).hp > 0 && dist(this.x,this.y,bb.get(i).x, bb.get(i).y) < 100)//when distance between boss and laser is less than 100, collision happens
      {
        bb.get(i).hp--;//1 hp lost per hit
        
        for(int j = 0; j < 20; j++) s.add(new spark(this.x, this.y));//spark animation added at the coordinates where the laser hit the boss
        
        for(int k = 0; k < 1; k++)
        {
          if(bb.get(i).hp >= 4)//splitting space debris from boss per laser hit
          {
            d.add(new debris(bb.get(i).x+20, bb.get(i).y));//adds another piece of debris next to the boss when hit by the laser, will keep adding pieces per hit as long as hp is more than 4
          }
        }
        
        this.x = -1000;//moves laser off screen, which helps with garbage collection done above
      }
    }
  }
}

class debris extends movement//class handles everythig to do with debris, is also using the movement class
{
  int hp;
  
  debris(float a, float b)
  {
    super(a, b, random(4) - 2, 1 + random(2));
    
    this.hp = 5;
  }
  
  void render()
  {
    //movement code
    this.move();
    
    //debris boundaries
    if(this.x < 0) this.x = width;
    if(this.x > width) this.x = 0;
    if(this.y > height) this.y = 0;
    
    //drawing space debris
    stroke(0);
    fill(180);
    ellipse(this.x, this.y, this.hp*10, this.hp*10);
    
    textSize(15);//Debris health
    fill(0,200,0);
    text(this.hp, this.x+25, this.y-25);
  }
}

//explosion sparks, also using an movement class as an extension
class spark extends movement
{
  spark(float a, float b)
  {
    super(a,b, random(4) - 2, random(4) - 2);
  }
  
  void render()
  {
    //gravity
    this.sy += 0.1;
    
    //movement
    this.move();
    
    //draw
    stroke(222,200,0);
    fill(222,200,0,50);
    ellipse(this.x, this.y, 10,10);
  }
}

class missile extends movement//class handles the missiles, movement extention
{
  debris target;//target variable is of the class debris, which allows the missiles to target the debris
  
  missile(float stx, float sty)
  {
    super(stx, sty, 0, 0);
    
    this.target = d.get(floor(random(d.size())));//target is chosen at random from whatever debris appears on screen
  }
  
  void render()
  {
    this.move();
    
    //steering -- chunk of code allows the missiles to 'home in' on the debris 
    if (this.x < this.target.x) this.sx += 0.01;
    else this.sx -= 0.01;
    
    if (this.y < this.target.y) this.sy += 0.01;
    else this.sy -= 0.01;
    
    //collision
    if(dist(this.x, this.y, this.target.x, this.target.y) < 50)//collision happens when distance between missile and debris is less than 50
    {
      this.x = -1000;//missile moved off screen
      this.target.hp -= 2;//debris takes 2 damage, more than it would if hit by a normal laser
      
      for (int i = 0; i < 20; i++) s.add(new spark(this.target.x, this.target.y));//same idea as how spark animation works with laser and debris
  }
  
  //retargeting
  if(d.contains(this.target) == false)//when the missile has no target
  {
    this.target = d.get(floor(random(d.size())));//reassigns the target
  }
  
  //drawing
  stroke(0,255,0);
  strokeWeight(5);
  ellipse(this.x,this.y,2,2);
  
  //reset stroke
  strokeWeight(1);
  }
}

class button//handles making the buttons
{
  int x,y,w,h;
  String name;
  
  button(int a, int b, int c, int d, String n)
  {
    this.x = a;
    this.y = b;
    this.w = c;
    this.h = d;
    this.name = n;
  }
  
  void render()
  {
    //drawing the button
    fill(255,200);
    stroke(0);
    strokeWeight(1);
    rect(this.x,this.y,this.w,this.h);
    
    fill(0,100,100);
    textSize(20);
    text(this.name, this.x + this.w/2 - textWidth(this.name)/2, this.y + this.h/2 + 10);//centering text
  }
    
    boolean mtop()//instead of writting an if statement with specific coordinates every time with a new button in void mousePressed, this chunk of code will allow for the button class to handle it all
    {
      boolean result;
      
      if(mouseX > this.x && mouseX < (this.x + this.w) && mouseY > this.y && mouseY < (this.y + this.h)) result = true;//true only when mouse is on top of buttons
      else result = false;
      
      return result;
    }
}

class bg extends movement//star background, uses movement class
{
  bg()
  {
    super(random(width),random(height),-random(10)-1,0);
  }
  
  void render()
  {
    this.move();
    if (this.x < 0) this.x = width;//recycles the stars and makes the animation go on forever
    
    //drawing stars
    fill(200,200,255);
    stroke(200,200,255);
    ellipse(this.x, this.y, 3, 3);
  }
}
//to make boss special, I made it so the missiles can not damage it. Player can ony beat the boss using lasers. I wanted the boss and the debris to have differences other than just the size and colour
class bigBoss extends movement//class handles everythig to do with the boss, is also using the movement class -- very similar to debris class
{
  int hp;
  
  bigBoss(float a, float b)
  {
    super(a, b, random(4) - 2, 1 + random(2));
    
    this.hp = 10;
  }
  
  void render()
  {
    //movement code
    this.move();
    
    //boss boundaries
    if(this.x < 0) this.x = width;
    if(this.x > width) this.x = 0;
    if(this.y > height) this.y = 0;
    
    //drawing the boss
    stroke(0);
    fill(200,0,200);
    ellipse(this.x, this.y, this.hp*10, this.hp*10);
    
    textSize(15);//Boss health
    fill(0,200,0);
    text(this.hp, this.x+50, this.y-50);
  }
}

class drone extends movement//general idea is that a 'drone' bounces around the screen dropping missiles, also uses movement class 
{
  int mc;//cooldown variable
  drone(float stx, float sty)
  {
    super(stx, sty, 4, 4);
    
    this.mc = 20;
  }
  
  void render()
  {
    //movement
    this.move();
    
    //boundaries - but it bounces off the edges
    if (this.x >= width -20) this.sx = -this.sx;
    else if (this.x <= 0) this.sx = -this.sx;
    
    if (this.y >= height - 40) this.sy = -this.sy;
    else if (this.y <= 0) this.sy = -this.sy;
    
    //missile shooting
    this.mc--;//cooldown lowers
    if(this.mc < 0)//when it's below 0, the drone shoots a missile
    {
      m.add(new missile(this.x,this.y));//missile shot at the position where the drone was at the moment
      this.mc = 20;//cooldown restarts
    }
    
    //drone drawing
    fill(0,255,255);
    stroke(0);
    rect(this.x, this.y, 20,40);
  }
}

void reset()//function used for the reset button, clears all array lists so the game can restart from the beggining
{
  d.clear();
  m.clear();
  l.clear();
  s.clear();
  bb.clear();
  dd.clear();
  addBoss = false;//makes this false so boss just doesn't keep appearing after the reset
}
