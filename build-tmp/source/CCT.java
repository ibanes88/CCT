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




Movie video;
BlobDetection theBlobDetection; //blobDetection Class

PImage prevFrame; //first frame for motionDetect.pde
PImage motionImg, blurImg; //optimized image for blobDetection

boolean newFrame=false;


float threshold = 40; //difference treshold in motionDetect.pde
float blobTreshold = 0.5f; //treshold for blobDetection

String PATH = "innenhof_komplett.mp4";

int blobBlur = 1; //blur ratio used on blurImg for computeBlobs
int minA=200; //min area in pixels for Blob to be treated as a person
int blobNb = 0; //blobNumber in current frame
int draw=0;
int range=10; //range for person.update
int W = 700; 
int H = 394;

ArrayList <Person> activePersons; //contains persons active in current frame
ArrayList <Person> oldPersons; //contains "dead" persons

PFont f;


public void setup()
{
	size(W,H);
	video = new Movie(this, PATH);
	video.loop();
	prevFrame = createImage(W,H,RGB);
        
	//lTest = rauschCheckX*rauschCheckY; //for rauschCheck
	//schwelle = int(lTest*0.6);         //for rauschCheck
        
	video.speed(1);
	frameRate(15);
	    
	blurImg = new PImage(120,90); //small copy of camera frame for blobDetection
	motionImg = new PImage(W,H);
	    
	theBlobDetection = new BlobDetection(blurImg.width, blurImg.height);	
	theBlobDetection.setPosDiscrimination(true);
	theBlobDetection.setThreshold(blobTreshold);
	activePersons = new ArrayList <Person>();
	oldPersons = new ArrayList <Person>();
	f = createFont("Arial",16,true);
}


public void draw()
{
	prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height);
	prevFrame.updatePixels();
	video.read();
	newFrame = true;
	
	if (newFrame)
	{
		newFrame=false;
		draw++;
		noStroke();
		fill(255,255,255,75);
		rect(0,0,width,height); //plane with alpha for motionBlur
		motionDetect();
		//tint(255,120);
		//rauschCheck();
		//blobDetect(); //detect blobs in frame and create/update person instances
		//drawBlobsAndEdges(false, false, false); //visualize (drawBoxes, drawContours, drawPath)
		//checkPersonStatus();
		//displayActivePersons();
		//displayOldWaypoints();
		
    	textFont(f,10);
    	fill(255,0,0);
    	text("Blobs im Frame (>= minA ("+minA+")): " + blobNb, 10, height-10);
    	text(activePersons.size()+ " / " + oldPersons.size(), width-50, height-10);
    	text("draw:  " + draw,width-60,15);
    	text("frame: " + frameCount,width-60,30);
    	blobNb=0;
  	}
}

public void displayOldWaypoints()
{
  if (keyPressed == true)
  {
    for (int z=oldPersons.size()-1; z>0; z--)
    {
      Person p = oldPersons.get(z);
      p.drawWaypoints(0,255,0); //inactiveWaypoints color
    }  
  }
}
public void blobDetect() 
{
	motionImg = get(); //get processed image after motionDetect
	image(video, 0, 0, width, height);
	blurImg.copy(motionImg, 0, 0, video.width, video.height, 0, 0, blurImg.width, blurImg.height);
	fastblur(blurImg, blobBlur); //blur image
	//image(blurImg, 0, 0, width, height);
	theBlobDetection.computeBlobs(blurImg.pixels); //detect blobs in blurred image
}


public void drawBlobsAndEdges(boolean drawBlobs, boolean drawEdges, boolean track)
{
	noFill();
	Blob b;
	EdgeVertex eA, eB;
	for (int n=0; n<theBlobDetection.getBlobNb (); n++)
	{
		b=theBlobDetection.getBlob(n);
		if (b!=null)
		{
			// draw Edges
			if (drawEdges)
			{
				strokeWeight(3);
				stroke(0, 255, 0);
				for (int m=0; m<b.getEdgeNb (); m++)
				{
					eA = b.getEdgeVertexA(m);
					eB = b.getEdgeVertexB(m);
					if (eA !=null && eB !=null)
					line(eA.x*width, eA.y*height, eB.x*width, eB.y*height);
				}
			}

			// draw Blobs
			if (drawBlobs)
			{
        		strokeWeight(1);
        		noFill();
        		stroke(255, 0, 0);
        		rect(b.xMin*width,b.yMin*height,b.w*width,b.h*height);
			}

			// tracking + draw path
			if (track)
			{ 
				if (b.w*width*b.h*height>minA) 
				{
					createUpdate(b.x*width,b.y*height);
					blobNb++;
				}
			}
		}
	}
}


public void fastblur(PImage img, int radius)
{
	if (radius<1) 
	{
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
	int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
	int vmin[] = new int[max(w, h)];
	int vmax[] = new int[max(w, h)];
	int[] pix=img.pixels;
	int dv[]=new int[256*div];
	
	for (i=0; i<256*div; i++) 
	{
		dv[i]=(i/div);
	}

	yw=yi=0;

	for (y=0; y<h; y++) 
	{
		rsum=gsum=bsum=0;
		for (i=-radius; i<=radius; i++) 
		{
			p=pix[yi+min(wm, max(i, 0))];
			rsum+=(p & 0xff0000)>>16;
			gsum+=(p & 0x00ff00)>>8;
			bsum+= p & 0x0000ff;
		}

		for (x=0; x<w; x++) 
		{

			r[yi]=dv[rsum];
			g[yi]=dv[gsum];
			b[yi]=dv[bsum];

			if (y==0) 
			{
				vmin[x]=min(x+radius+1, wm);
				vmax[x]=max(x-radius, 0);
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

	for (x=0; x<w; x++) 
	{
		rsum=gsum=bsum=0;
		yp=-radius*w;
		for (i=-radius; i<=radius; i++) 
		{
			yi=max(0, yp)+x;
			rsum+=r[yi];
			gsum+=g[yi];
			bsum+=b[yi];
			yp+=w;
		}
		yi=x;
		for (y=0; y<h; y++) 
		{
			pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
			if (x==0) 
			{
				vmin[y]=min(y+radius+1, hm)*w;
				vmax[y]=max(y-radius, 0)*w;
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
  
	loadPixels();
	video.loadPixels(); //current pixels
	prevFrame.loadPixels(); //last frame pixels 
  
	// loop throuh pixelArray
	for (int x = 0; x < video.width; x ++ ) 
	{
		for (int y = 0; y < video.height; y ++ ) 
		{
			int loc = x + y*video.width; // 1d position
			int current = video.pixels[loc]; // current color
			int previous = prevFrame.pixels[loc]; // last frame color
	   
			// difference
			float r1 = red(current); float g1 = green(current); float b1 = blue(current); //colorvalues for pixel in this frame
			float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous); //colorvalues for pixel in last frame
			float diff = dist(r1,g1,b1,r2,g2,b2); //colordifference
	   
			// compare to treshold
			if (diff > threshold) 
			{ 
				// black
				pixels[loc] = color(0);
				} else 
				{
	      		// white 
	      		//pixels[loc] = color(255);
	    		}
	  	}
	}

  updatePixels();
}
class Person 
{
	int id; //specific Id
	boolean hasBeenUpdated = true;
	boolean isDead = false;

	PVector location;
	PVector locationOld;

	ArrayList <PVector> way = new ArrayList <PVector>();


Person(float x, float y)
{
	location = new PVector(x,y);
}


public void update(float x, float y)
{
	if(frameCount%5==0)
	{
		way.add(new PVector(location.x,location.y));
	}

	location.x = x;
	location.y = y;
	hasBeenUpdated = true;
}


public void drawID() 
{
	textFont(f,10);
	fill(255,0,0);
	text(id, location.x+20,location.y+20);
}


public void display()
{
	noStroke();
	fill(0,0,255);
	ellipse(location.x,location.y,12,12);
}


public void drawWaypoints(int r, int g, int b)
{
	for (int i=way.size()-1;i>1;i--)
	{
		PVector f = way.get(i);
		PVector d = way.get(i-1);
		stroke(r,g,b);
		strokeWeight(2);
		line(f.x,f.y,d.x,d.y);
    }
}
};

int xRausch, yRausch, lTest, schwelle;
PImage rauschen;
int rauschCheckX = 5;
int rauschCheckY = 12;
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
public void createUpdate(float x, float y)
{
	boolean isNear=false;
	for (int z=0; z<activePersons.size(); z++) 
	{
		Person person = activePersons.get(z);
		if (x-range<person.location.x && x+range>person.location.x && y-range<person.location.y && y+range>person.location.y) 
    	{
			isNear=true;
			person.update(x, y);
			z=activePersons.size()-1;
		}
	}
  	if (!isNear) 
	{
		activePersons.add(new Person(x, y));
	} 
}


public void checkPersonStatus()
{
	for (int z=activePersons.size()-1;z>0; z--) 
	{
		Person person = activePersons.get(z);
		if(person.isDead)
		{
			oldPersons.add(person);
			activePersons.remove(z);
		} else if (!person.hasBeenUpdated)
		{
        	person.isDead=true;
		}
		person.hasBeenUpdated=false;
	}

}


public void displayActivePersons()
{
	for (int z=activePersons.size()-1;z>0; z--) 
	{
		Person person = activePersons.get(z);
		//person.id = z;
		person.drawID();
		person.display();
		person.drawWaypoints(255,0,255);
		//println("ID : "+person.id+" ist : " + "x : " + person.location.x + " y : " + person.location.y);
		//println(activePersons[z].id);
	}
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
