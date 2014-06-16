import processing.video.*;
import blobDetection.*;

//Capture video;
Movie video;
BlobDetection theBlobDetection;
PImage prevFrame, motionImg, blurImg;
boolean newFrame = false;
ArrayList<person> people;
ArrayList<person> prevPeople;


String PATH = "test.mov";
float threshold = 20;
int blobBlur = 1;
float blobTreshold = 0.2f;
PVector bCenter, bDirection;
int minA=300;
//int W = 540; //abbey.mp4
//int H = 360;
//int W = 960; //crowd.mp4
//int H = 720;
//int W = 320; //abbey_low.mov
//int H = 240;
int W = 641; //test.mov
int H = 361;


void setup()
{
	size(W, H);
  people = new ArrayList<person>();
  prevPeople = new ArrayList<person>();
	video = new Movie(this, PATH);
        video.play();
        video.loop();
        video.volume(0);
        prevFrame = createImage(W,H,RGB);
        lTest = rauschCheckX*rauschCheckY;
        schwelle = int(lTest*0.7);
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

void draw()
{
  motionDetect();
  tint(255,120);
  blobDetect();
  rauschCheck();
  drawBlobsAndEdges(false, false, true);
  peopleTrack();
}
