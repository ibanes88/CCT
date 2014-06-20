import processing.video.*;
import blobDetection.*;

Movie video;
BlobDetection theBlobDetection; //blobDetection Class

PImage prevFrame; //first frame for motionDetect.pde
PImage motionImg, blurImg; //optimized image for blobDetection

boolean newFrame=false;


float threshold = 40; //difference treshold in motionDetect.pde
float blobTreshold = 0.5f; //treshold for blobDetection

String PATH = "innenhof_3.mov";

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


void setup()
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


void draw()
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
		blobDetect(); //detect blobs in frame and create/update person instances
		drawBlobsAndEdges(false, false, true); //visualize (drawBoxes, drawContours, drawPath)
		checkPersonStatus();
		displayActivePersons();
		displayOldWaypoints();
		
    	textFont(f,10);
    	fill(255,0,0);
    	text("Blobs im Frame (>= minA ("+minA+")): " + blobNb, 10, height-10);
    	text(activePersons.size()+ " / " + oldPersons.size(), width-50, height-10);
    	text("draw:  " + draw,width-60,15);
    	text("frame: " + frameCount,width-60,30);
    	blobNb=0;
  	}
}

void displayOldWaypoints()
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
