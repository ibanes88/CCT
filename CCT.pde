import processing.video.*;
import blobDetection.*;

Movie video;
BlobDetection theBlobDetection; //blobDetection Class

PImage bgImage; 
PImage prevFrame; //first frame for motionDetect.pde
PImage motionImg, blurImg; //optimized image for blobDetection

boolean newFrame = false;

int blobNb = 0; //blobs in current frame
int draw=0; // current draw
int lwp = 0;
int id = 1; //id starting number

String PATH = "innenhof_komplett.mp4";

float threshold = 30; //difference treshold in motionDetect.pde
float blobTreshold = 0.5f; //treshold for blobDetection

int blobBlur = 1; //blur ratio used on blurImg for computeBlobs
int minA = 500; //min area in pixels for Blob to be treated as a person
int trackDistance = 30; //trackDistance for person.update
//int checkIfGhostDistance = trackDistance*3;
//int maxAge = 8;
int viewportBorder = 5; //border thickness in which leftViewport will be detected
float fieldOfVision = 90; //search field (in Degrees) of lastWaypoint for blobs
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
//ArrayList <Person> inactivePersons; //contains inactive persons in current frame
ArrayList <Person> oldPersons; //contains "dead" persons
ArrayList <Integer> detectedPixels;

PFont f;

PrintWriter output;


void setup()
{
  size(W, H);
  video = new Movie(this, PATH);
  video.loop();
  prevFrame = createImage(W, H, RGB);
  bgImage = createImage(W, H, RGB);
  //lTest = rauschCheckX*rauschCheckY; //for rauschCheck
  //schwelle = int(lTest*0.6);         //for rauschCheck

  video.speed(1);
  frameRate(15);

  blurImg = new PImage(120, 68); //small copy of camera frame for blobDetection
  motionImg = new PImage(W, H);

  theBlobDetection = new BlobDetection(blurImg.width, blurImg.height);	
  theBlobDetection.setPosDiscrimination(true);
  theBlobDetection.setThreshold(blobTreshold);
  activePersons = new ArrayList <Person>();
  //inactivePersons = new ArrayList <Person>();
  oldPersons = new ArrayList <Person>();
  detectedPixels = new ArrayList <Integer>();
  f = createFont("Arial", 16, true);
  output = createWriter("positions.txt");
}


void draw()
{
	if (video.available())
  {
		prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height);
		prevFrame.updatePixels();
		video.read();
		newFrame = true;
	}

  if (newFrame)
  {
    newFrame=false;
    motionDetect();
    //rauschCheck();
    blobDetect(); //detect blobs in frame and create/update person instances
    drawBlobsAndEdges(true, true, true); //visualize (drawBoxes, drawContours, drawPath)
    checkPersonStatus();

    textFont(f, 10);
    fill(255, 0, 0);
    text("Blobs im Frame (>= minA ("+minA+")): " + blobNb, 10, height-10);
    text(activePersons.size()+ " / " + oldPersons.size(), width-50, height-10);
    text("draw:  " + draw, width-60, 15);
    text("frame: " + frameCount, width-60, 30);
    text("leftViewport: " + lwp, 10, 10);
    blobNb=0;
    draw++;
  }

  //Save Frames for debugging and display paths if anyKey pressed
 	if (keyPressed) {
	  if (key == 's') {
	    saveFrame("Frame-##.png");
	  }
	  else
	  {
	  	for (int z=oldPersons.size()-1; z>0; z--)
	    {
	      Person p = oldPersons.get(z);
	      p.drawWaypoints(0,255,0); //inactiveWaypoints color
	    }  
	  }
	}

}

//save
void mouseReleased()
{
  for (int z=0; z<oldPersons.size (); z++)
  {
    Person p = oldPersons.get(z);
    for (int y=0; y<p.waypoints.size (); y++)
    {
      if (y%1 == 0) {
        PVector w = p.waypoints.get(y);

        output.println(p.pID+","+(int) w.x +","+ (int) w.y); // Write the coordinate to the file
      }
    }
  }  
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  bgImage.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  bgImage.save("bgImage.jpg");
  exit();
}

