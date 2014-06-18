// - Super Fast Blur v1.1 by Mario Klingemann <http://incubator.quasimondo.com>
// - BlobDetection library

import processing.video.*;
import blobDetection.*;

//Capture video;
Movie video;
BlobDetection theBlobDetection;
PImage prevFrame;
PImage motionImg, blurImg;
boolean newFrame=false;
float threshold = 40;
String PATH = "innenhof_3.mov";
int blobBlur = 1;
float blobTreshold = 0.5f;
PVector bCenter, bDirection;
int minA=200;
ArrayList <Person> newPersons;
ArrayList <Person> oldPersons;
int W = 700; //innenhof_3.mov
int H = 394;
//int W = 960; //crowd.mp4
//int H = 720;
//int W = 320;
//int H = 240;
//int W = 641; //test.mov
//int H = 361;
//int W = 352;
//int H = 288;
PFont f;
int blobNb = 0;
int draw=0;


void setup()
{
	size(W, H);
	video = new Movie(this, PATH);
        //video.play();
        video.loop();
        //video.volume(0);
        prevFrame = createImage(W,H,RGB);
        lTest = rauschCheckX*rauschCheckY;
        schwelle = int(lTest*0.6);
        //println(schwelle);
        //video.start();
        //video.speed(1);
        frameRate(15);
	// BlobDetection
	// blurImg which will be sent to detection (a smaller copy of the cam frame);
	blurImg = new PImage(120,90);
        motionImg = new PImage(W,H);
	theBlobDetection = new BlobDetection(blurImg.width, blurImg.height);
	theBlobDetection.setPosDiscrimination(true);
	theBlobDetection.setThreshold(blobTreshold); // will detect bright areas whose luminosity > 0.2f;
        newPersons = new ArrayList <Person>();
        oldPersons = new ArrayList <Person>();
        f = createFont("Arial",16,true);
}


// captureEvent()
void movieEvent(Movie video)
{
        prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height); // Before we read the new frame, we always save the previous frame for comparison!
        prevFrame.updatePixels();
	video.read();
        newFrame = true;
}

void draw()
{
  if (newFrame)
  {
    newFrame=false;
    draw++;
    noStroke();
    fill(255,255,255,75);
    rect(0,0,width,height);
    motionDetect();
    //tint(255,120);
    //rauschCheck();
    blobDetect(); // hier: []oldP == []newP / newP.clear()
    drawBlobsAndEdges(true, true, true);
    textFont(f,10);
    fill(255,0,0);
    text("draw :" + draw,width-80,40);
    text("frame :" + frameCount,width-80,80);
  }
}
