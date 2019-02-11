import gab.opencv.*;
import SimpleOpenNI.*;
import KinectProjectorToolkit.*;
import processing.video.*;

SimpleOpenNI kinect;
OpenCV opencv;
Timer timer;
Timer strokeTimer;
KinectProjectorToolkit kpc;
ArrayList<ProjectedContour> projectedContours;
Movie[] mov = new Movie[3];
int iterator = 0;
int sine;

void setup()
{
  size(displayWidth, displayHeight, P3D); 
  background(0);
  smooth(8);
  noStroke();
  hint(DISABLE_OPTIMIZED_STROKE);
  timer = new Timer(seconds(60));
  timer.start();
  
  strokeTimer = new Timer(seconds(10));
  strokeTimer.start();
  
  // setup Kinect
  kinect = new SimpleOpenNI(this); 
  kinect.enableDepth();
  kinect.enableUser();
  kinect.alternativeViewPointDepthToImage();
  
  // setup OpenCV
  opencv = new OpenCV(this, kinect.depthWidth(), kinect.depthHeight());

  // setup Kinect Projector Toolkit
  kpc = new KinectProjectorToolkit(this, kinect.depthWidth(), kinect.depthHeight());
  kpc.loadCalibration("calibration.txt");
  kpc.setContourSmoothness(4);
  
  // load Movies into Array
//  mov[0] = new Movie(this, "circle1.mp4");
//  mov[1] = new Movie(this, "circle2.mp4");
//  mov[2] = new Movie(this, "circle3.mp4");
//  mov[3] = new Movie(this, "circle4.mp4");
//  mov[4] = new Movie(this, "circle5.mp4");
//  mov[5] = new Movie(this, "vid.mp4");
  mov[0] = new Movie(this, "vid2.mp4");
  mov[1] = new Movie(this, "vid3.mp4");
  mov[2] = new Movie(this, "vid4.avi");
  
  mov[iterator].loop();
}

void movieEvent(Movie m){
  m.read();
}

void draw(){
  if (timer.isFinished()) {
    background(0);
    timer.start();
  }
  
  kinect.update();  
  kpc.setDepthMapRealWorld(kinect.depthMapRealWorld()); 
  kpc.setKinectUserImage(kinect.userImage());
  opencv.loadImage(kpc.getImage());
  
  // get projected contours
  projectedContours = new ArrayList<ProjectedContour>();
  ArrayList<Contour> contours = opencv.findContours();
  for (Contour contour : contours){
    if (contour.area() > 2000){
      ArrayList<PVector> cvContour = contour.getPoints();
      ProjectedContour projectedContour = kpc.getProjectedContour(cvContour, 1.0);
      projectedContours.add(projectedContour);
    }
  }
  
  
  // draw projected contours
  sine = abs(int(sin(frameCount * 0.1) * 255));
  
  for (int i=0; i<projectedContours.size(); i++){
    ProjectedContour projectedContour = projectedContours.get(i);
    tint(255, 255, 255, sine);
    beginShape();
    
//    if (strokeTimer.isFinished()) {
//      strokeWeight(int(random(10)));
//      stroke(int(random(0, 255)), int(random(0, 255)), int(random(0, 255)), int(random(0, 255)));
//      strokeTimer.start();
//    }
    
    texture(mov[iterator]);
    for (PVector p : projectedContour.getProjectedContours()){
      PVector t = projectedContour.getTextureCoordinate(p);
      vertex(p.x, p.y, mov[iterator].width * t.x, mov[iterator].height * t.y);
    }
    endShape();
  }
  
  if (mousePressed == true){
    if(mouseButton == LEFT){
      background(0);  
    }
  }
}

void mousePressed(){
  if(mouseButton == RIGHT){
    if(iterator < mov.length - 1){
      mov[iterator].stop();
      iterator++;
      mov[iterator].loop();
    }
    else{
      mov[iterator].stop();
      iterator = 0;
      mov[iterator].loop();
    }
  }
  else if(mouseButton == CENTER){
    saveFrame();
  }
}

int seconds(int msecs){
  return msecs * 1000; 
}
