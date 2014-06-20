import processing.video.*;
import blobDetection.*;

Movie video;
BlobDetection theBlobDetection; //blobDetection Class

PImage prevFrame; //first frame for motionDetect.pde
PImage motionImg, blurImg; //optimized image for blobDetection

boolean newFrame = false;

int blobNb = 0; //blobs in current frame
int draw=0; // current draw
int lwp = 0;
int id = 1; //id starting number

String PATH = "innenhof_komplett.mp4";

float threshold = 50; //difference treshold in motionDetect.pde
float blobTreshold = 0.5f; //treshold for blobDetection

int blobBlur = 1; //blur ratio used on blurImg for computeBlobs
int minA = 430; //min area in pixels for Blob to be treated as a person
int trackDistance = 25; //trackDistance for person.update
int viewportBorder = 15; //border thickness in which leftViewport will be detected
int timerLimit = 30;

	int pCount0=0;
  int pCount1=0;
  int pCount2=0;
  int pCount3=0;
  int pCount4=0;
  int pCount5=0;

int W = 700; 
int H = 394;

ArrayList <Person> activePersons; //contains persons active in current frame
ArrayList <Person> oldPersons; //contains "dead" persons
ArrayList <Integer> detectedPixels;

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
	detectedPixels = new ArrayList <Integer>();
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
		motionDetect();
			//rauschCheck();
		blobDetect(); //detect blobs in frame and create/update person instances
		drawBlobsAndEdges(false, false, false); //visualize (drawBoxes, drawContours, drawPath)
		checkPersonStatus();
		displayActivePersons();
		displayOldWaypoints();
		
    	textFont(f,10);
    	fill(255,0,0);
    	text("Blobs im Frame (>= minA ("+minA+")): " + blobNb, 10, height-10);
    	text(activePersons.size()+ " / " + oldPersons.size(), width-50, height-10);
    	text("draw:  " + draw,width-60,15);
    	text("frame: " + frameCount,width-60,30);
    	text("leftViewport: " + lwp, 10, 10);
    	blobNb=0;
    	draw++;
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
