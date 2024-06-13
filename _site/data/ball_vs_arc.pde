/**
 * Ball vs Arc 
 * by hyonsoo han
 *
 * Shows how to find the collision position between a ball and arc.
 * Checkout : brownsoo.github.io/2DVectors
 * Apache License 2.0 - http://www.apache.org/licenses/LICENSE-2.0
 */

final int _GREEN = 0xff4CAF50;
final int _RED = 0xffFF5252;
final int _BLUE = 0xff03A9F4;
final int _GRAY = 0xff757575;
final int _BLACK = 0xff212121;

final int maxV = 10;
final int scale = 10;
final float gravity = 0;

boolean dragging = false;
Dragger[] draggers;
Arrow[] arrows;

Ball ball; // main object
Ball ballA; // main object
Arc arcObj;

//Helper vectors
Vector vc;
Vector vn;
Vector vm;//vector from ball center to p3
Vector v3;//v3 on image
Vector v2;//v2 on image
Point p3;//position on ball vector at collision
Point cp;//position of ball at collision

//reset button
SimpleButton resetBt;

void setup() {
  size(400, 400);
  // Pulling the display's density dynamically
  try {
    pixelDensity(displayDensity());
  } catch(Exception e){}
  
  //create object
  ball = new Ball(_BLUE, 40);
  ball.p0 = new Point(100, 100);
  ball.p1 = new Point(250, 250);
  updateVector(ball, true);
  
  ballA = new Ball(_BLUE&0x23FFFFFF, 40);
  
  arcObj = new Arc(_RED, 50);
  arcObj.p0 = new Point(200, 200);
  arcObj.angle1 = 135 * PI / 180;
  arcObj.angle2 = 315 * PI / 180;
  findArc(arcObj);
  updateVector(arcObj, true);
  
  vc = new Vector();
  vn = new Vector();
  vm = new Vector();
  v3 = new Vector();
  v2 = new Vector();
  p3 = new Point();
  cp = new Point();
  
  //Dragging Handler
  draggers = new Dragger[5];
  for(int i=0; i<draggers.length; i++) {
    draggers[i] = new Dragger();
  }
  
  //Arrow graphics for vector
  arrows = new Arrow[5];
  arrows[0] = new Arrow(_GRAY&0x50FFFFFF);
  arrows[1] = new Arrow(0xFF7B1FA2);//edge vector
  arrows[2] = new Arrow(_RED);
  arrows[3] = new Arrow(_GREEN);
  arrows[4] = new Arrow(_GRAY);
  
  resetBt = new SimpleButton("Reset");
  resetBt.x = 10;
  resetBt.y = height - 50;
  resetBt.setCallback(new OnButtonClick());
  
  findCollision();
}

class OnButtonClick implements ButtonCallback {
  void onClick(SimpleButton b) {
    //println(b.label + " click");
    ball.p0 = new Point(50, 50);
    ball.p1 = new Point(250, 250);
    updateVector(ball, true);
    
    arcObj.p0 = new Point(190, 170);
    arcObj.angle1 = 135 * PI / 180;
    arcObj.angle2 = 315 * PI / 180;
    findArc(arcObj);
    updateVector(arcObj, true);
    
    findCollision();
  }
}

void draw() {
  resetBt.place();
  // if(!mousePressed) return; //redraw only when interacting
  runMe();
}

void mousePressed() {
  boolean b = false;
  for(int i=0; i<draggers.length; i++) {
    if(draggers[i].contains(mouseX, mouseY)) {
      draggers[i].pressed = true;
      b = true;
    }
    else {
      draggers[i].pressed = false;
    }
  }
  dragging = b;
}

void mouseReleased() {
  dragging = false;
  for(int i=0; i<draggers.length; i++) {
    draggers[i].pressed = false;
  }
  runMe();
}

//main function
void runMe() {
  if(dragging) {
    for(int i=0; i<draggers.length; i++) {
      if(draggers[i].pressed) {
        draggers[i].x = mouseX;
        draggers[i].y = mouseY;
      }
    }
    
    ball.p0.x = draggers[0].x;
    ball.p0.y = draggers[0].y;
    ball.p1.x = draggers[1].x;
    ball.p1.y = draggers[1].y;
    arcObj.p0.x = draggers[2].x;
    arcObj.p0.y = draggers[2].y;
    
    float x;
    float y;
    if(draggers[3].pressed) {
      x = draggers[3].x - arcObj.p0.x;
      y = draggers[3].y - arcObj.p0.y;
      arcObj.angle1 = (float)Math.atan2(y, x);
      arcObj.r = sqrt(x*x + y*y);
    }
    else if(draggers[4].pressed) {
      x = draggers[4].x - arcObj.p0.x;
      y = draggers[4].y - arcObj.p0.y;
      arcObj.angle2 = (float)Math.atan2(y, x);
      arcObj.r = sqrt(x*x + y*y);
    }
  }
  
  findArc(arcObj);
  findCollision();
  
  //draw it
  drawAll();
}

//function to draw the points, lines and show text
void drawAll() {
  //clear all
  background(255);
  //Draw draggers
  draggers[0].x = ball.p0.x;
  draggers[0].y = ball.p0.y;
  draggers[1].x = ball.p1.x;
  draggers[1].y = ball.p1.y;
  draggers[2].x = arcObj.p0.x;
  draggers[2].y = arcObj.p0.y;
  draggers[3].x = arcObj.edge.p0.x;
  draggers[3].y = arcObj.edge.p0.y;
  draggers[4].x = arcObj.edge.p1.x;
  draggers[4].y = arcObj.edge.p1.y;
  for(int i=0; i<draggers.length; i++) {
    draggers[i].place();
  }
  
  ballA.placeAt(ball.p0);
  //place balls at collision
  ball.placeAt(cp);
  //
  arcObj.placeAtP0();
  
  noFill();
  strokeWeight(1);
  
  //movement vector of ball
  stroke(arrows[0].c);
  line(ball.p0.x, ball.p0.y, ball.p1.x, ball.p1.y);
  arrows[0].x = ball.p1.x;
  arrows[0].y = ball.p1.y;
  arrows[0].rotation = atan2(ball.vy, ball.vx);
  arrows[0].place();
  
  //edge vector of arcObj
  stroke(arrows[1].c);
  line(arcObj.edge.p0.x, arcObj.edge.p0.y, arcObj.edge.p1.x, arcObj.edge.p1.y);
  arrows[1].x = arcObj.edge.p1.x;
  arrows[1].y = arcObj.edge.p1.y;
  arrows[1].rotation = atan2(arcObj.edge.vy, arcObj.edge.vx);
  arrows[1].place();
  
  //vector between centers at collision
  if(v2.length > 0) {
   stroke(arrows[2].c);
   strokeWeight(1);
   line(v2.p0.x, v2.p0.y, v2.p1.x, v2.p1.y);
   arrows[2].x = v2.p1.x;
   arrows[2].y = v2.p1.y;
   arrows[2].rotation = atan2(v2.vy, v2.vx);
   arrows[2].place();
   text("v2", (v2.p0.x + v2.p1.x)/2, (v2.p0.y + v2.p1.y)/2);
  }
  
  //vector v3 
  if(v3.length > 0) {
   stroke(arrows[3].c);
   strokeWeight(1);
   line(v3.p0.x, v3.p0.y, v3.p1.x, v3.p1.y);
   arrows[3].x = v3.p1.x;
   arrows[3].y = v3.p1.y;
   arrows[3].rotation = atan2(v3.vy, v3.vx);
   arrows[3].place();
  }
  
  //ball vector to move on collision position
  if(vm.length > 0) {
   stroke(arrows[4].c);
   strokeWeight(1);
   line(vm.p0.x, vm.p0.y, vm.p1.x, vm.p1.y);
   arrows[4].x = vm.p1.x;
   arrows[4].y = vm.p1.y;
   arrows[4].rotation = atan2(vm.vy, vm.vx);
   arrows[4].place();
  }
  
  
  ellipse(p3.x, p3.y, 4, 4);
  fill(_BLACK);
  
  //text
  fill(0);
  textAlign(CENTER);
  text("ball", cp.x, cp.y - ball.r - 10);
  text("arcObj", arcObj.p0.x, arcObj.p0.y + arcObj.r + 20);
  //text("vc", (vc.p0.x + vc.p1.x)/2, (vc.p0.y + vc.p1.y)/2);
  //text("vn", (vn.p0.x + vn.p1.x)/2, (vn.p0.y + vn.p1.y)/2);
  text("p3", p3.x, p3.y - 10);
  //noStroke();
  //ellipse(vn.p0.x, vn.p0.y, 4, 4);
  //fill(ball.c);
  //textAlign(LEFT);
  //text("red : main vector v", 15, 35);
  //if(v4.length > 0) {
  //  text("v3", (v3.p0.x + v3.p1.x)/2, (v3.p0.y + v3.p1.y)/2);
  //}
}

//collision
void findCollision() {
  updateVector(ball, true);
  updateVector(arcObj, true);
  Vector collision = ballVsBall(ball, arcObj.p0, arcObj.r);
  
  if(collision != null) {
    //vector between center points
    v2.p0 = arcObj.p0;
    v2.p1 = p3;// ball position at collision
    updateVector(v2, true);
    //check if the point is on the right side of vector between arcObj points
    //vector between starting point of arcObj and collision point
    v3.p0 = arcObj.edge.p0;
    v3.p1.x = arcObj.p0.x + v2.dx * arcObj.r;
    v3.p1.y = arcObj.p0.y + v2.dy * arcObj.r;
    updateVector(v3, true);
    
    Vector arcNormal = new Vector();
    arcNormal.vx = arcObj.edge.lx;
    arcNormal.vy = arcObj.edge.ly;
    
    if(dotP(v3, arcNormal) >= 0) {
      cp = p3;
    }
    else {
      //not on the arc
      collision = null;
    }
  }
  //need to check with other side of arc too
  if(collision == null) {
    if(vn.length < arcObj.r) {
      //amount to move back moving ball
      float r = arcObj.r - ball.r;
      float moveForward = sqrt(r*r - vn.length * vn.length);
      p3.x = vn.p0.x + moveForward * ball.dx;
      p3.y = vn.p0.y + moveForward * ball.dy;
      vm.p0 = ball.p0;
      vm.p1 = p3;
      //check if p3 is on the movement vector
      if(vm.length < ball.length && dotP(vm, ball)>0) {
        //collision point found
        v2.p0 = arcObj.p0;
        v2.p1 = p3;
        updateVector(v2, true);
        //check if the point is on the right side of vector between arcObj points
        //vector between starting point of arc and collision point
        v3.p0 = arcObj.edge.p0;
        v3.p1.x = arcObj.p0.x + v2.dx*arcObj.r;
        v3.p1.y = arcObj.p0.y + v2.dy*arcObj.r;
        updateVector(v3, true);
        
        Vector arcNormal = new Vector();
        arcNormal.vx = arcObj.edge.lx;
        arcNormal.vy = arcObj.edge.ly;
        if(dotP(v3, arcNormal) >=0) {
          cp = p3;
          collision = vm;
        }
      }
    }
    //we need to check if endpoints of arc are being hit
    Vector nextCollision = ballVsBall(ball, arcObj.edge.p0, 0);
    if(nextCollision != null) {
      if(collision == null || nextCollision.length<collision.length) {
        collision = nextCollision;
        cp = p3;
      }
    }
    nextCollision = ballVsBall(ball, arcObj.edge.p1, 0);
    if(nextCollision != null) {
      if(collision == null || nextCollision.length<collision.length) {
        collision = nextCollision;
        cp = p3;
      }
    }
  }
  if(collision == null) {
    //no collision
    cp = ball.p1;
    vm.length = 0;
    v2.length = 0;
    v3.length = 0;
    p3.x = -100;
    p3.y = -100;
  }
  //draw it
  drawAll();
}



//find collision between balls
/*
@param b main ball
@param tp center of target ball
@param r target radius
return ball's vector to the position of collision 
*/
Vector ballVsBall(Ball b, Point tp, float r) {
  //vector between center points of balls
  vc.p0 = b.p0;
  vc.p1 = tp;
  updateVector(vc, true);
  //projection of vc on movement vector
  Vector vp = projectVector(vc, b.dx, b.dy);
  //vector to center of target ball(tp) in direction of b vector's normal
  vn.p0.x = b.p0.x + vp.vx;
  vn.p0.y = b.p0.y + vp.vy;
  vn.p1 = tp;
  updateVector(vn, true);
  //sum of radius
  float sumRadius = b.r + r;
  float diff = sumRadius - vn.length;
  if(diff > 0) {//collision
    //amount to move back moving ball
    float moveBack = sqrt(sumRadius*sumRadius - vn.length*vn.length);
    p3.x = vn.p0.x - moveBack * b.dx;
    p3.y = vn.p0.y - moveBack * b.dy;
    vm.p0 = b.p0;
    vm.p1 = p3;
    updateVector(vm, true);
    //check if p3 is on the movement vector
    if(vm.length < b.length && dotP(vm, b) > 0) {
      return vm;
    }
  }
  return null;
}



//function to find all parameters for the vector
void updateVector(Vector v, boolean fromPoints) {
  //x and y components
  if(fromPoints) {
    v.vx = v.p1.x-v.p0.x;
    v.vy = v.p1.y-v.p0.y;
  }
  else {
    v.p1.x = v.p0.x + v.vx;
    v.p1.y = v.p0.y + v.vy;
  }
  //length of vector
  v.length = sqrt(v.vx*v.vx+v.vy*v.vy);
  //normalized unit-sized components
  if (v.length > 0) {
    v.dx = v.vx/v.length;
    v.dy = v.vy/v.length;
  }
  else {
    v.dx = 0;
    v.dy = 0;
  }
  
  //right hand normal
  v.rx = -v.dy;
  v.ry = v.dx;
  //v.rdx = -v.dy;
  //v.rdy = v.dx;
  //left hand normal
  v.lx = v.dy;
  v.ly = -v.dx;
  //v.ldx = v.dy;
  //v.ldy = -v.dx;
}

//calculate dot product of 2 vectors
float dotP(Vector v1, Vector v2) {
 return v1.vx*v2.vx + v1.vy*v2.vy; 
}

//project vector of v1 on unit-sized vector dx/dy
Vector projectVector(Vector v1, float dx, float dy) {
  //find dot product
  float dp = v1.vx*dx+v1.vy*dy;
  Vector proj = new Vector();
  //projection components
  proj.vx = dp*dx;
  proj.vy = dp*dy;
  
  return proj;
}

void findArc(Arc a) {
  //vector between end points of the arc
  a.edge.p0.x = a.p0.x + a.r * cos(a.angle1);
  a.edge.p0.y = a.p0.y + a.r * sin(a.angle1);
  a.edge.p1.x = a.p0.x + a.r * cos(a.angle2);
  a.edge.p1.y = a.p0.y + a.r * sin(a.angle2);
  updateVector(a.edge, true);
}






// ------------------------------------
// -------------- CLASS ---------------
// ------------------------------------


/** Arc Graphic */
class Arc extends Ball {
 public float angle1 = 0;
 public float angle2 = TWO_PI;
 public Vector edge;//vector from angle1 to angle2
 
 Arc(int color0, float radius0){
   super(color0, radius0);
   this.c = color0;
   this.r = radius0;
   this.edge = new Vector();
 }
 
 public void place() {
   updateAngle();
   noFill();
   strokeWeight(1);
   stroke(c);
   arc(p1.x, p1.y, r*2, r*2, angle1, angle2);
   
   noStroke();
   fill(c, 10);
   ellipse(p0.x, p0.y, r*2, r*2);
   
   fill(c);
   ellipse(p1.x, p1.y, 4, 4);
 }
 
 public void placeAtP0() {
   updateAngle();
   noFill();
   strokeWeight(1);
   stroke(c);
   arc(p0.x, p0.y, r*2, r*2, angle1, angle2);
   
   noStroke();
   fill(c, 10);
   ellipse(p0.x, p0.y, r*2, r*2);
   
   fill(c);
   
   ellipse(p0.x, p0.y, 4, 4);
 }
 
 private void updateAngle() {
   if(angle1 < 0) {
     angle1 += TWO_PI;
   }
   if(angle2 < 0) {
     angle2 += TWO_PI;
   }
   if(angle1 > angle2) {
     angle2 += TWO_PI;
   }
 }
}

/** Ball Graphic */
class Ball extends Vector {
 public float r = 10; //radius
 public int c = 0;
 public int lastTime = 0;
 public float timeFrame = 0;
 
 Ball(int color0, float radius0){
   super();
   this.c = color0;
   this.r = radius0;
 }
 
 Ball(Point p0, int color0, float radius0){
   super();
   this.p0 = p0;
   this.c = color0;
   this.r = radius0;
 }
 
 public void place() {
   fill(c, 30);
   strokeWeight(1);
   stroke(c);
   ellipse(p1.x, p1.y, r*2, r*2);
   
   fill(c);
   noStroke();
   ellipse(p1.x, p1.y, 4, 4);
 }
 
 public void placeAtP0() {
   strokeWeight(1);
   fill(c, 30);
   stroke(c);
   ellipse(p0.x, p0.y, r*2, r*2);
   
   fill(0);
   noStroke();
   ellipse(p0.x, p0.y, 4, 4);
 }
 
 public void placeAt(Point p) {
   strokeWeight(1);
   fill(c, 30);
   stroke(c);
   ellipse(p.x, p.y, r*2, r*2);
   
   fill(0);
   noStroke();
   ellipse(p.x, p.y, 4, 4);
 }
 
}


/** Handler to drag the points */
class Dragger {
  public float x;
  public float y;
  public boolean pressed = false;
  private float size;
  private float degree = 0;
  private float expend = 0;
  private float maxExpend = 6;

  public Dragger() {
    this(20);
  }
  public Dragger(int size0) {
    this.size = size0;
  }
  public void place() {
    degree = degree > 180 ? 0 : degree + 5;
    noStroke();
    fill(50, 76);
    expend = sin(radians(degree)) * maxExpend;
    ellipse(x, y, size + expend, size + expend);
    if(pressed) {
      fill(135, 181, 255, 200);
      ellipse(x, y, size + maxExpend * 6, size + maxExpend * 6);
    }
  }
  public boolean contains(float x0, float y0) {
    if(x0 < x - size/2 - maxExpend || x0 > x + size/2 + maxExpend 
      || y0 < y - size/2 - maxExpend || y0 > y + size/2 + maxExpend) {
      return false;
    }
    return true;
  }
}


/** Arrow Graphic definition */
class Arrow {
 public float x;
 public float y;
 public float rotation = 0;//radian
 public int c = 0;
 
 Arrow(int color0){
   c = color0;
 }
 
 public void place() {
   stroke(c);
   noFill();
   pushMatrix();
   translate(x, y);
   rotate(rotation + QUARTER_PI); //Arrow is leaned by QUARTER_PI 
   line(0, 0, -9, 2);
   line(0, 0, -2, 9);
   popMatrix();
 }
}

/** Point definition */
class Point {
 public float x;
 public float y;
 Point(){}
 Point(float x0, float y0) {
   this.x = x0;
   this.y = y0;
 }
}

/** Vector definition */
class Vector {
  public Point p0;
  public Point p1;
  public float vx = 0;
  public float vy = 0;
  public float rx = 0;
  public float ry = 0;
  public float lx = 0;
  public float ly = 0;
  public float dx = 0;
  public float dy = 0;
  public float rdx = 0;//right unit normal
  public float rdy = 0;
  public float ldx = 0;//left unit normal
  public float ldy = 0;
  public float length;
  public float airf = 1;//air friction
  public float b = 1;//bounce
  public float f = 1;//friction
  
  public Vector() {
    p0 = new Point();
    p1 = new Point();
  }
  
  public Vector(Point p0, Point p1) {
    this.p0 = p0;
    this.p1 = p1;
  }
  
  public Vector(Point p0, Point p1, float b, float f) {
    this.p0 = p0;
    this.p1 = p1;
    this.b = b;
    this.f = f;
  }
}



//----------------------------------

/** 
* Simple Button 
* by hyonsoo han
* 
To make button;

1. create new SimpleButton instance.
  btn = new SimpleButton("OK"); 
  btn.x = 10;
  btn.y = 50;

2. create new class of ButtonCallback.
  class ClickImpl implements ButtonCallback {
    void onClick() {
      println("onclick");
    }
  }

3. Connect listener instance with the button.
  btn.setCallback(new ClickImpl());

4. Call the place-function of SimpleButton in every time to draw 

*/
public class SimpleButton {
  public int x;
  public int y;
  public boolean pressed = false;
  public int c = 0xFFFFC107;
  private String label;
  private float tw;
  private float th;
  private int mx=0, my=0;
  private int mTime = 0;
  private int mState = 0;
  
  private ButtonCallback callback;
  public SimpleButton(String label0){
    this(label0, 0xFFFFC107);
  }
  public SimpleButton(String label0, int color0) {
    label = label0;
    textSize(12);
    tw = textWidth(label0) + 10;
    th = 24;
    c = color0;
  }
  
  public void place() {
    
    noStroke();
    
    if(!pressed) {
      fill(c);
      rect(x, y, tw, th);
      fill(255);
      textAlign(CENTER, CENTER);
      text(label, x + tw/2, y + th/2);
    }
    else {
      fill(200, 156);
      rect(x, y, tw, th);
      fill(0);
      textAlign(CENTER, CENTER);
      text(label, x + tw/2, y + th/2);
    }
    textAlign(LEFT, BASELINE);
    
    if(mState == 0 && mousePressed) {
      mPressed();
    }
    else if(mState == 1 && !mousePressed) {
      mReleased();
    }
  }
  
  
  public void mPressed() {
    mx = mouseX;
    my = mouseY;
    mTime = millis();
    pressed = contains(mouseX, mouseY);
    mState = (pressed?1:0);
  }
  
  public void mReleased() {
    pressed = false;
    mState = 0;
    if(!contains(mouseX, mouseY)) return;
    if(abs(mx - mouseX) > 10) return;
    if(abs(my - mouseY) > 10) return;
    if(millis() - mTime > 200) return;
    if(callback != null) callback.onClick(this);
  }
  
  public boolean contains(float x0, float y0) {
    if(x0 < x || x0 > x + tw 
      || y0 < y || y0 > y + th) {
      return false;
    }
    return true;
  }
  
  public void setCallback(ButtonCallback callback0) {
    callback = callback0;
  }
}

/** Listener for Simple Button */
public interface ButtonCallback {
  void onClick(SimpleButton button);
}