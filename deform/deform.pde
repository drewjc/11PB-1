// LecturesInGraphics: aniamted deformation of an image
// Template for project
// Author: Jarek ROSSIGNAC, last edited on September 25, 2013
PImage myImage;                            // image used as tecture 

//**************************** global variables ****************************
pts P = new pts(), Gmagenta = new pts(), Gred = new pts(), Ggreen = new pts(), Gblue = new pts(), Gyellow = new pts();
int levels=6, grid=5;
float t=0, f=0, s=0;
Boolean animate=false, fill=true, showIDs=false, timing=false;
int ms=0, me=0; // milli seconds start and end
int npts=20000; // number of points
//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(600, 600,P3D);            // window size
  myImage = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  P.declare();Gmagenta.declare();Gred.declare();Ggreen.declare();Gblue.declare();Gyellow.declare();
  P.makeGrid(grid);Gmagenta.makeGrid(grid);Gred.makeGrid(grid);Ggreen.makeGrid(grid);Gblue.makeGrid(grid);Gyellow.makeGrid(grid);
  P = Gmagenta;
  }

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  noFill();  
  if(fill) P.paintImage(grid);
  pen(magenta,7); Gmagenta.showGrid(grid);
  pen(red,5); Gred.showGrid(grid);
  pen(green,3); Ggreen.showGrid(grid);
  pen(blue,1); Gblue.showGrid(grid);
  
  if(showIDs) P.IDs(); // shows polyloop with vertex labels
 
  if(animate) {t+=0.006; if(t>=1) animate=false;} 
  if(scribeText) {fill(black); displayHeader();}
  if(scribeText && !filming) displayFooter(); // shows title, menu, and my face & name 
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif");  
  change=false; // to avoid capturing frames when nothing happens
  }  // end of draw()
  
//**************************** user actions ****************************
void keyPressed() { // executed each time a key is pressed: sets the "keyPressed" and "key" state variables, 
                    // till it is released or another key is pressed or released
  if(key=='?') scribeText=!scribeText; // toggle display of help text and authors picture
  if(key=='!') snapPicture(); // make a picture of the canvas
 
  if(key=='a') {animate=true; t=0;}
  if(key==']') P.fitToCanvas();
  if(key=='~') { filming=!filming; } // filming on/off capture frames into folder FRAMES 
  if(key=='S') selectOutput("Select a file to write to:", "saveToFile");   
  if(key=='L') selectInput("Select a file to read from:", "readFromFile"); 
  if(key=='s') P.savePts(path);   
  if(key=='l') P.loadPts(path); 

  if(key=='f') fill=!fill; // used for timing
  if(key=='Q') exit();  // quit application
  if(key=='#') showIDs=!showIDs;  // increment subdivision levels
  //if(key=='=') {P.G[2].setTo(P.G[0]); s=3;}
  if(key=='=') {P.G = Gmagenta.G; s=3;}
  if(key=='+') levels++;  // increment subdivision levels
  if(key=='-') levels=max(0,levels-1);  // decrement subdivision levels
  
  if(key=='0') P=Gmagenta;
  if(key=='1') P=Gred;
  if(key=='2') P=Ggreen;
  if(key=='3') P=Gblue;
  change=true;
  }

void mousePressed() {  // executed when the mouse is pressed
  P.pickClosest(Mouse()); // pick vertex closest to mouse: sets pv ("picked vertex") in pts
  if (keyPressed&&false) { // disabled ***
     if (key=='a')  P.addPt(Mouse()); // appends vertex after the last one
     if (key=='i')  P.insertClosestProjection(Mouse()); // inserts vertex at closest projection of mouse
     if (key=='d')  P.deletePickedPt(); // deletes vertex closeset to mouse
     }  
  change=true;
  }

void mouseDragged() {
  if (!keyPressed || (key=='a')|| (key=='i')) P.dragPicked();   // drag selected point with mouse
  if (keyPressed) {
      if (key=='.') t+=2.*float(mouseX-pmouseX)/width;  // adjust current frame   
      if (key=='t') P.dragAll(); // move all vertices
      if (key=='r') P.rotateAllAroundCentroid(Mouse(),Pmouse()); // turn all vertices around their center of mass
      if (key=='z') P.scaleAllAroundCentroid(Mouse(),Pmouse()); // scale all vertices with respect to their center of mass
      }
  change=true;
  } 
  
void mouseWheel(MouseEvent event) { // reads mouse wheel and uses to zoom
  float s = event.getAmount();
  P.scaleAllAroundCentroid(s/100);
  change=true;
  }
  
//**************************** text for name, title and help  ****************************
String title ="P08: Jarek Deformation - Base code", name ="Jarek Rossignac",
       menu="?:help, !:picture, ~:(start/stop) recording, Q:quit",
       guide="=:same as grid 0, .:s, +/-:level, f:fill, t:tran, r:rot, z:zoom, s:save, l:load"; // help info



