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

String PATH = "StPeter_2.mp4";

float threshold = 50; //difference treshold in motionDetect.pde
float blobTreshold = 0.9f; //treshold for blobDetection

int blobBlur = 1; //blur ratio used on blurImg for computeBlobs
int minA = 250; //min area in pixels for Blob to be treated as a person
int trackDistance = 30; //trackDistance for person.update
//int checkIfGhostDistance = trackDistance*3;
//int maxAge = 8;
int viewportBorder = 15; //border thickness in which leftViewport will be detected
float fieldOfVision = 90; //search field (in Degrees) of lastWaypoint for blobs
int timerLimit = 30;

int pCount0=0;
int pCount1=0;
int pCount2=0;
int pCount3=0;
int pCount4=0;
int pCount5=0;

int W = 1200; 
int H = 674;

ArrayList <Person> activePersons; //contains persons active in current frame
//ArrayList <Person> inactivePersons; //contains inactive persons in current frame
ArrayList <Person> oldPersons; //contains "dead" persons
ArrayList <Integer> detectedPixels;

PFont f;

PrintWriter output;
PrintWriter speedData;
PrintWriter finalFrameCount;


void setup()
{
  size(W, H);
  video = new Movie(this, PATH);
  video.loop();
  prevFrame = createImage(W, H, RGB);
  bgImage = createImage(W, H, RGB);
  lTest = rauschCheckX*rauschCheckY; //for rauschCheck
  schwelle = int(lTest*0.6);         //for rauschCheck

  video.speed(1);
  frameRate(24);

  blurImg = new PImage(600, 337); //small copy of camera frame for blobDetection
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
  speedData = createWriter("speed.txt");
  finalFrameCount = createWriter("framecount.txt");
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
    drawBlobsAndEdges(false, false, true); //visualize (drawBoxes, drawContours, drawPath)
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
  finalFrameCount.println(frameCount);
  finalFrameCount.flush();
  finalFrameCount.close();
  for (int z=0; z<oldPersons.size (); z++)
  {
    Person p = oldPersons.get(z);
    for (int y=0; y<p.waypoints.size (); y++)
    {
      if (y%1 == 0) {
        PVector w = p.waypoints.get(y);

        output.println(p.pID+","+(int) w.x +","+ (int) w.y +","+ (int) w.z); // Write the coordinate to the file
      }
    }
  }  
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file
  for (int z=0; z<oldPersons.size (); z++)
  {
    Person p = oldPersons.get(z);
    for (int y=0; y<p.speedpoints.size (); y++)
    {
      if (y%1 == 0) {
        PVector w = p.speedpoints.get(y);

        speedData.println(p.pID+","+(int) w.x +","+ (int) w.y +","+ (int) w.z); // Write the coordinate to the file
      }
    }
  }
  speedData.flush(); // Writes the remaining data to the file
  speedData.close(); // Finishes the file
  bgImage.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  bgImage.save("bgImage.jpg");
  exit();
}

