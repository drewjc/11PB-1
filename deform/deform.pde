// LecturesInGraphics: aniamted deformation of an image
// Template for project
// Author: Jarek ROSSIGNAC, last edited on September 25, 2013
PImage myImage;                            // image used as tecture 

//**************************** global variables ****************************
pts P = new pts(), G0 = new pts(), G1 = new pts(), G2 = new pts(), G3 = new pts(), Gt = new pts();
pts RG0 = new pts(), RG1 = new pts(), RG2 = new pts(), RG3 = new pts(), RGt = new pts();

int levels=6, grid=5;
float t=0, f=0, s=0;
Boolean animate=false, fill=true, showIDs=false, timing=false;
Boolean showKeyFrames=true, showGrids=true, showResampled=true, useSampled=false, useBezier=false;
int samples = 15;
int ms=0, me=0; // milli seconds start and end
int npts=20000; // number of points
//**************************** initialization ****************************
void setup() {               // executed once at the begining 
  size(900, 900,P3D);            // window size
  myImage = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  P.declare();G0.declare();G1.declare();G2.declare();G3.declare();Gt.declare();
  P.makeGrid(grid);G0.makeGrid(grid);G1.makeGrid(grid);G2.makeGrid(grid);G3.makeGrid(grid);Gt.makeGrid(grid);
  RG0.declare();RG1.declare();RG2.declare();RG3.declare();RGt.declare();
//  G0.loadPts(path+'0');G1.loadPts(path+'1');G2.loadPts(path+'2');RG3.loadPts(path+'3');
  P = G0;
  }

//**************************** display current frame ****************************
void draw() {      // executed at each frame
  background(white); // clear screen and paints white background
  noFill();  
  if(fill) P.paintImage(grid);
  pen(magenta,7); G0.showGrid(grid);
  pen(red,5); G1.showGrid(grid);
  pen(green,3); G2.showGrid(grid);             
  pen(blue,1); G3.showGrid(grid);
  
  image(myImage, 0,0);
  
  if(showKeyFrames){
    if(fill) {
      noStroke();
      if(useSampled){
        RG1.paintImage(grid);  
        RG2.paintImage(grid);
        RG3.paintImage(grid);
      }
      else{
        G1.paintImage(grid);  
        G2.paintImage(grid);
        G3.paintImage(grid);    
      }
      }
    }  
  
  
  if(showIDs) P.IDs(); // shows polyloop with vertex labels
  
  if(animate || (keyPressed && key=='.')){
    Gt.interpolate(G1, G2, G3, t);
//    Gt.resampleTo(RGt, grid, samples);
    noStroke(); if(fill) if(useSampled) RGt.paintImage(grid); else Gt.paintImage(grid);
    pen(cyan, 1); if(showResampled) RGt.showGrid(grid);
    pen(grey, 1); if(showGrids) Gt.showGrid(grid);
     
  }
   
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
  if(key=='s') {G0.savePts(path+"0"); G1.savePts(path+"1"); G2.savePts(path+"2"); G3.savePts(path+"3");}   
  if(key=='l') {G0.savePts(path+"0"); G1.savePts(path+"1"); G2.savePts(path+"2"); G3.savePts(path+"3"); P=G0;} 

  if(key=='f') fill=!fill; // used for timing
  if(key=='Q') exit();  // quit application
//  if(key=='#') showIDs=!showIDs;  // increment subdivision levels
  if(key=='#') G0.makeGrid(grid);
  //if(key=='=') {P.G[2].setTo(P.G[0]); s=3;}
  if(key=='=') {G0.copyInto(G1); G0.copyInto(G2); G0.copyInto(G3);}
//  if(key=='+') levels++;  // increment subdivision levels
//  if(key=='-') levels=max(0,levels-1);  // decrement subdivision levels
  if(key=='+') samples++;
  if(key=='-') samples=max(2, samples-1);
  if(key=='u') useSampled=!useSampled;
  if(key=='b') useBezier=!useBezier;
  if(key=='k') showKeyFrames=!showKeyFrames;
  if(key=='g') showGrids=!showGrids;
  if(key=='m') showResampled=!showResampled;
  if(key=='p') fill=!fill;
  
  if(key=='0') {P=G0; fill=false;}
  if(key=='1') P=G1;
  if(key=='2') P=G2;
  if(key=='3') P=G3;
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



