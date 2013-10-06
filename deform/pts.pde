//*****************************************************************************
// TITLE:         Point sequence for polylines and polyloops  
// AUTHOR:        Prof Jarek Rossignac
// DATE CREATED:  September 2012
// EDITS:         Last revised Sept 10, 2012
//*****************************************************************************
class pts {
 Boolean loop=true;
 int pv =0, iv=0, nv = 0;                      // picked vertex index, insertion vertex index, number of vertices 
 int maxnv = 1024;                         //  max number of vertices
 pt[] G = new pt [maxnv];                 // geometry table (vertices)
  pts() {}
  pts declare() {for (int i=0; i<maxnv; i++) G[i]=P(); return this;}               // init points
  pts empty() {nv=0; pv=0; return this;}
  pts addPt(pt P) { G[nv].setTo(P); pv=nv; nv++;  return this;}
  pts addPt(float x,float y) { G[nv].x=x; G[nv].y=y; pv=nv; nv++; return this;}
  pts insertPt(pt P) { 
    for(int v=nv-1; v>pv; v--) G[v+1].setTo(G[v]); 
     pv++; 
     G[pv].setTo(P);
     nv++; 
     return this;
     }
  pts insertClosestProjection(pt M) {
    pt P = closestProjectionOf(M); 
    for(int v=nv-1; v>iv; v--) G[v+1].setTo(G[v]); 
     pv=iv+1; 
     G[pv].setTo(P);
     nv++; 
     return this;
     }
  pts resetOnCircle(int k) { // init the points to be on a circle
    pt C = ScreenCenter(); 
    empty();
    for (int i=0; i<k; i++) addPt(R(P(C,V(0,-width/3)),2.*PI*i/k,C));
    return this;
    } 
  pts makeGrid (int w) { // make a 2D grid of w x w vertices
   for (int i=0; i<w; i++) for (int j=0; j<w; j++)  
     addPt(P(.7*height*j/(w-1)+.1*height,.7*height*i/(w-1)+.1*height));
   return this;
   }    
  pt Pnt(int i) {return G[i];}
  pt Pnt(int i, int j, int n) {int k = i*n+j; if(k<nv) return G[k]; else return G[nv-1];}
  pts showGrid(int n) {
    for(int i=0; i<n-1; i++) 
      for(int j=0; j<n-1; j++) {
         edge(Pnt(i,j,n),Pnt(i+1,j,n));
         edge(Pnt(i,j,n),Pnt(i,j+1,n));
         }
    for(int i=0; i<n-1; i++) edge(Pnt(i,n-1,n),Pnt(i+1,n-1,n));
    for(int j=0; j<n-1; j++) edge(Pnt(n-1,j,n),Pnt(n-1,j+1,n)); 
    return this;}
    
  void paintImage(int n) {
     float in = 1./(n-1);
     textureMode(NORMAL);       // texture parameters in [0,1]x[0,1]
     beginShape(QUADS); 
     for (int i=0; i<n-1; i++) {
       beginShape(QUAD_STRIP); texture(myImage); 
       for (int j=0; j<n; j++) { 
         v(Pnt(i,j,n),in*j, in*i); 
         v(Pnt(i+1,j,n),in*j, in*(i+1)); 
         };
       endShape();
       };
     }
        
  pts deletePickedPt() {for(int i=pv; i<nv; i++) G[i].setTo(G[i+1]); pv=max(0,pv-1); nv--;  return this;}
  pts setPt(pt P, int i) { G[i].setTo(P); return this;}
  pts IDs() {
    for (int v=0; v<nv; v++) { 
      fill(white); show(G[v],13); fill(black); 
      if(v<10) label(G[v],str(v));  else label(G[v],V(-5,0),str(v)); 
      }
    noFill();
    return this;
    }
  pts showPicked() {show(G[pv],13); return this;}
  pts draw(color c) {fill(c); for (int v=0; v<nv; v++) show(G[v],13); return this;}
  pts drawVertex(int v) {show(G[v],15); return this;}
  pt PtAt(float t) {int i = floor(t*nv); return L(G[i],G[n(i)],(t*nv-float(i))); } 
  
  pts draw() {for (int v=0; v<nv; v++) show(G[v],13); return this;}
  pts drawCurve() {if(loop) drawClosedCurve(); else drawOpenCurve(); return this; }
  pts drawOpenCurve() {beginShape(); for (int v=0; v<nv; v++) G[v].v(); endShape(); return this;}
  pts drawClosedCurve() {beginShape(); for (int v=0; v<nv; v++) G[v].v(); endShape(CLOSE); return this;}
  pts pickClosest(pt M) {pv=0; for (int i=1; i<nv; i++) if (d(M,G[i])<d(M,G[pv])) pv=i; return this;}

  pt CentroidOfVertices() {pt C=P(); for (int i=0; i<nv; i++) C.add(G[i]); return P(1./nv,C);} 
  
  pts dragPicked() { G[pv].moveWithMouse(); return this;}      // moves selected point (index p) by amount mouse moved recently
  pts dragAll() { for (int i=0; i<nv; i++) G[i].moveWithMouse(); return this;}      // moves selected point (index p) by amount mouse moved recently
  pts moveAll(vec V) {for (int i=0; i<nv; i++) G[i].add(V); return this;};   

  pts rotateAll(float a, pt C) {for (int i=0; i<nv; i++) G[i].rotate(a,C); return this;}; // rotates points around pt G by angle a
  pts rotateAllAroundCentroid(float a) {rotateAll(a,CentroidOfVertices()); return this;}; // rotates points around their center of mass by angle a
  pts rotateAll(pt G, pt P, pt Q) {rotateAll(angle(V(G,P),V(G,Q)),CentroidOfVertices()); return this;}; // rotates points around G by angle <GP,GQ>
  pts rotateAllAroundCentroid(pt P, pt Q) {rotateAll(CentroidOfVertices(),P,Q); return this;}; // rotates points around their center of mass G by angle <GP,GQ>

  pts scaleAll(float s, pt C) {for (int i=0; i<nv; i++) G[i].translateTowards(s,C); return this;};  
  pts scaleAllAroundCentroid(float s) {scaleAll(s,CentroidOfVertices()); return this;};
  pts scaleAllAroundCentroid(pt M, pt P) {pt C=CentroidOfVertices(); float m=d(C,M),p=d(C,P); scaleAll((p-m)/p,C); return this;};

  pts fitToCanvas() {  // translates and scales mesh to fit canvas
     float sx=100000; float sy=10000; float bx=0.0; float by=0.0; 
     for (int i=0; i<nv; i++) {
       if (G[i].x>bx) {bx=G[i].x;}; if (G[i].x<sx) {sx=G[i].x;}; 
       if (G[i].y>by) {by=G[i].y;}; if (G[i].y<sy) {sy=G[i].y;}; 
       }
     for (int i=0; i<nv; i++) {
       G[i].x=0.93*(G[i].x-sx)*(width)/(bx-sx)+23;  
       G[i].y=0.90*(G[i].y-sy)*(height-100)/(by-sy)+100;
       } 
     return this;
     }   
     
void savePts(String fn) {
  String [] inppts = new String [nv+1];
  int s=0;
  inppts[s++]=str(nv);
  for (int i=0; i<nv; i++) {inppts[s++]=str(G[i].x)+","+str(G[i].y);}
  saveStrings(fn,inppts);
  };
  
void loadPts(String fn) {
  println("loading: "+fn); 
  String [] ss = loadStrings(fn);
  String subpts;
  int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
  nv = int(ss[s++]); print("nv="+nv);
  for(int k=0; k<nv; k++) {int i=k+s; float [] xy = float(split(ss[i],",")); G[k].setTo(xy[0],xy[1]);}
  pv=0;
  }; 
  
  
//********* measures
float length () {float L=0; for (int i=nv-1, j=0; j<nv; i=j++) L+=d(G[i],G[j]); return L; }
pt closestProjectionOf(pt M) {
   int c=0; pt C = P(G[0]); float d=d(M,C);       
   for (int i=1; i<nv; i++) if (d(M,G[i])<d) {c=i; C=P(G[i]); d=d(M,C); }  
   for (int i=nv-1, j=0; j<nv; i=j++) { 
       pt A = G[i], B = G[j];
       if(projectsBetween(M,A,B) && disToLine(M,A,B)<d) {d=disToLine(M,A,B); c=i; C=projectionOnLine(M,A,B);}
       } 
   iv=c;    
   return C;    
   }

void copyInto(pts Q) {
  Q.empty();
  for(int i=0; i<nv; i++) Q.addPt(G[i]);
  }
  
int n(int i) {if(i==nv-1) return 0; else return i+1;}
int p(int i) {if(i==0) return nv-1; else return i-1;}

 }  // end class pts
