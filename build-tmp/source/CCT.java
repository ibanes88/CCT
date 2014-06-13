import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import blobDetection.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CCT extends PApplet {

// - Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
// - BlobDetection library




//Capture video;
Movie video;
BlobDetection theBlobDetection;
PImage prevFrame;
PImage motionImg, blurImg;
boolean newFrame=false;
float threshold = 20;
String PATH = "test.mov";
int blobBlur = 1;
float blobTreshold = 0.2f;
PVector bCenter, bDirection;
int minA=300;
//int W = 540; //abbey.mp4
//int H = 360;
//int W = 960; //crowd.mp4
//int H = 720;
//int W = 320;
//int H = 240;
int W = 641; //test.mov
int H = 361;


public void setup()
{
	size(W, H);
	video = new Movie(this, PATH);
        video.play();
        video.loop();
        video.volume(0);
        prevFrame = createImage(W,H,RGB);
        lTest = rauschCheckX*rauschCheckY;
        schwelle = PApplet.parseInt(lTest*0.7f);
        //println(schwelle);
        //video.start();
        
	// BlobDetection
	// blurImg which will be sent to detection (a smaller copy of the cam frame);
	blurImg = new PImage(480,360);
  motionImg = new PImage(W,H);
	theBlobDetection = new BlobDetection(blurImg.width, blurImg.height);
	theBlobDetection.setPosDiscrimination(true);
	theBlobDetection.setThreshold(blobTreshold); // will detect bright areas whose luminosity > 0.2f;
}

/*
// captureEvent()
void movieEvent(Movie video)
{
	video.read();
}*/

public void draw()
{
  motionDetect();
  tint(255,120);
  blobDetect();
  rauschCheck();
  drawBlobsAndEdges(false, false, true);
}
public void blobDetect(){
  motionImg = get();
  //test.filter(BLUR, 2);
  image(video, 0, 0, width, height);
  //image(motionImg, 0, 0, width, height);
  blurImg.copy(motionImg, 0, 0, video.width, video.height, 0, 0, blurImg.width, blurImg.height);
  
  fastblur(blurImg, blobBlur);
  image(blurImg,0,0,width,height);
  //image(blurImg, width-width/3, height-height/3, width/3, height/3);
  theBlobDetection.computeBlobs(blurImg.pixels);
}

public void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges, boolean track)
{
	noFill();
	Blob b;
	EdgeVertex eA,eB;
	for (int n=0 ; n<theBlobDetection.getBlobNb() ; n++)
	{
		b=theBlobDetection.getBlob(n);
		if (b!=null)
		{
			// Edges
			if (drawEdges)
			{
				strokeWeight(3);
				stroke(0,255,0);
				for (int m=0;m<b.getEdgeNb();m++)
				{
					eA = b.getEdgeVertexA(m);
					eB = b.getEdgeVertexB(m);
					if (eA !=null && eB !=null)
						line(
							eA.x*width, eA.y*height, 
							eB.x*width, eB.y*height
							);
				}
			}

			// Blobs
			if (drawBlobs)
			{
				strokeWeight(1);
				stroke(255,0,0);
                                rect(
					b.xMin*width,b.yMin*height,
					b.w*width,b.h*height
					);
			}
                        
      if (track)
      {
        if (b.w*width*b.h*height>minA){
          bCenter = new PVector(b.x, b.y);
          float bx = bCenter.x*width;
          float by = bCenter.y*height;
          strokeWeight(1);
          stroke(0,0,255);
          line(0,0,bx,by);
          noStroke();
          ellipseMode(CENTER);
          fill(0,0,255);
          ellipse(bx,by,10,10);
          //println(bCenter.x, bCenter.y, theBlobDetection.getBlobNb()); 
        } 
      }
		}
  }
}

public void fastblur(PImage img,int radius)
{
 if (radius<1){
    return;
  }
  int w=img.width;
  int h=img.height;
  int wm=w-1;
  int hm=h-1;
  int wh=w*h;
  int div=radius+radius+1;
  int r[]=new int[wh];
  int g[]=new int[wh];
  int b[]=new int[wh];
  int rsum,gsum,bsum,x,y,i,p,p1,p2,yp,yi,yw;
  int vmin[] = new int[max(w,h)];
  int vmax[] = new int[max(w,h)];
  int[] pix=img.pixels;
  int dv[]=new int[256*div];
  for (i=0;i<256*div;i++){
    dv[i]=(i/div);
  }

  yw=yi=0;

  for (y=0;y<h;y++){
    rsum=gsum=bsum=0;
    for(i=-radius;i<=radius;i++){
      p=pix[yi+min(wm,max(i,0))];
      rsum+=(p & 0xff0000)>>16;
      gsum+=(p & 0x00ff00)>>8;
      bsum+= p & 0x0000ff;
    }
    for (x=0;x<w;x++){

      r[yi]=dv[rsum];
      g[yi]=dv[gsum];
      b[yi]=dv[bsum];

      if(y==0){
        vmin[x]=min(x+radius+1,wm);
        vmax[x]=max(x-radius,0);
      }
      p1=pix[yw+vmin[x]];
      p2=pix[yw+vmax[x]];

      rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
      gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
      bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
      yi++;
    }
    yw+=w;
  }

  for (x=0;x<w;x++){
    rsum=gsum=bsum=0;
    yp=-radius*w;
    for(i=-radius;i<=radius;i++){
      yi=max(0,yp)+x;
      rsum+=r[yi];
      gsum+=g[yi];
      bsum+=b[yi];
      yp+=w;
    }
    yi=x;
    for (y=0;y<h;y++){
      pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
      if(x==0){
        vmin[y]=min(y+radius+1,hm)*w;
        vmax[y]=max(y-radius,0)*w;
      }
      p1=x+vmin[y];
      p2=x+vmax[y];

      rsum+=r[p1]-r[p2];
      gsum+=g[p1]-g[p2];
      bsum+=b[p1]-b[p2];

      yi+=w;
    }
  }

}
public void motionDetect()
{
  // Capture video
  if (video.available()) {
    // Save previous frame for motion detection!!
    prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height); // Before we read the new frame, we always save the previous frame for comparison!
    prevFrame.updatePixels();
    video.read();
  }
  
  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();
  
  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      
      int loc = x + y*video.width;            // Step 1, what is the 1D pixel location
      int current = video.pixels[loc];      // Step 2, what is the current color
      int previous = prevFrame.pixels[loc]; // Step 3, what is the previous color
      
      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); float g1 = green(current); float b1 = blue(current);
      float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
      float diff = dist(r1,g1,b1,r2,g2,b2);
      
      // Step 5, How different are the colors?
      // If the color at that pixel has changed, then there is motion at that pixel.
      if (diff > threshold) { 
        // If motion, display black
        pixels[loc] = color(0);
      } else {
        // If not, display white
        pixels[loc] = color(255);
      }
    }
  }
  updatePixels();
}
int xRausch, yRausch, lTest, schwelle;
PImage rauschen;
int rauschCheckX = 5;
int rauschCheckY = 10;
int pCount=0;

public void rauschCheck() {
  loadPixels();
  //prevFrame.loadPixels();
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      int loc = x + y*video.width;
      if (pixels[loc] == color(0)){
        rauschen = get(x,y, rauschCheckX, rauschCheckY);
        for (int i=0;i<rauschen.pixels.length;i++){
          if (rauschen.pixels[i] == color(0)){
            pCount++;
          }
        }
        if (pCount<schwelle){
          pixels[loc] = color(255);
        }
        else {
          pixels[loc] = color(0);
        }
        //println(pCount);
        pCount=0;
      }
    }
  }
  updatePixels();
  noFill();
  strokeWeight(1);
  stroke(255,0,0);
  rect(width/2,height/2,rauschCheckX,rauschCheckY);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CCT" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
