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

PrintWriter output;


public void setup()
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
  oldPersons = new ArrayList <Person>();
  detectedPixels = new ArrayList <Integer>();
  f = createFont("Arial", 16, true);
  output = createWriter("positions.txt");
}


public void draw()
{
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  prevFrame.updatePixels();
  video.read();
  newFrame = true;

  if (newFrame)
  {
    newFrame=false;
    motionDetect();
    //rauschCheck();
    blobDetect(); //detect blobs in frame and create/update person instances
    drawBlobsAndEdges(false, false, true); //visualize (drawBoxes, drawContours, drawPath)
    checkPersonStatus();
    displayActivePersons();
    displayOldWaypoints();

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
}

public void displayOldWaypoints()
{
  if (keyPressed == true)
  {
    for (int z=oldPersons.size ()-1; z>0; z--)
    {
      Person p = oldPersons.get(z);
      p.drawWaypoints(0, 255, 0); //inactiveWaypoints color
    }
  }
}

//save
public void mouseReleased()
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

public void blobDetect() 
{
  motionImg.pixels = pixels; //get processed image after motionDetect
  image(video, 0, 0, width, height);
  blurImg.copy(motionImg, 0, 0, video.width, video.height, 0, 0, blurImg.width, blurImg.height);
  fastblur(blurImg, blobBlur); //blur image
  image(blurImg, 0, 0, width, height);
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
        rect(b.xMin*width, b.yMin*height, b.w*width, b.h*height);
      }

      // tracking + draw path
      if (track)
      { 
        if (b.w*width*b.h*height>minA) 
        {
          createUpdate(b.x*width, b.y*height);
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
      float r1 = red(current); 
      float g1 = green(current); 
      float b1 = blue(current); //colorvalues for pixel in this frame
      float r2 = red(previous); 
      float g2 = green(previous); 
      float b2 = blue(previous); //colorvalues for pixel in last frame
      float diff = dist(r1, g1, b1, r2, g2, b2); //colordifference

      // compare to treshold
      if (diff > threshold) 
      { 
        // black
        pixels[loc]=color(0);
        detectedPixels.add(loc); //store data for blur
        if (draw < 4)
        {
          if (draw==0) pCount0++; //store how many pixels are to delete later
          else if (draw==1) pCount1++;
          else if (draw==2) pCount2++;
          else if (draw==3) pCount3++;
        } else pCount3++;
      } else 
      {
        // white 
        pixels[loc] = color(255);
      }
    }
  }

  if (draw > 4)
  {
    for (int z=0; z<detectedPixels.size (); z++) //recolor black pixels from detectedPixels[]
    {
      int x = detectedPixels.get(z);
      pixels[x] = color(0);
    }
  }
  updatePixels();
  for (int z=pCount0-1; z>-1; z--)
  {
    detectedPixels.remove(z);
  }
  pCount0=pCount1;
  pCount1=pCount2;
  pCount2=pCount3;
  pCount3=0;
}

class Person 
{
  int pID; //specific Id
  int timer = 0;
  boolean updated = true;
  boolean isDead = false;
  boolean leftViewport;

  PVector location;

  ArrayList <PVector> waypoints = new ArrayList <PVector>();


  Person(float x, float y, int id)
  {
    location = new PVector(x, y);
    pID = id;
  }


  public void update(float x, float y)
  {
    if (frameCount%5==0)
    {
      waypoints.add(new PVector(location.x, location.y));
    }

    location.x = x;
    location.y = y;
    updated = true;
  }


  public void drawID() 
  {
    textFont(f, 10);
    fill(255, 0, 0);
    text(pID, location.x+20, location.y+20);
  }


  public void display()
  {
    noStroke();
    fill(0, 0, 255);
    ellipse(location.x, location.y, 12, 12);
  }


  public void drawWaypoints(int r, int g, int b)
  {
    for (int i=waypoints.size ()-1; i>1; i--)
    {
      PVector f = waypoints.get(i);
      PVector d = waypoints.get(i-1);
      stroke(r, g, b);
      strokeWeight(2);
      line(f.x, f.y, d.x, d.y);
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
      if (pixels[loc] == color(0)) {
        rauschen = get(x, y, rauschCheckX, rauschCheckY);
        for (int i=0; i<rauschen.pixels.length; i++) {
          if (rauschen.pixels[i] == color(0)) {
            pCount++;
          }
        }
        if (pCount<schwelle) {
          pixels[loc] = color(255);
        } else {
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
  stroke(255, 0, 0);
  rect(width/2, height/2, rauschCheckX, rauschCheckY);
}

public void createUpdate(float x, float y)
{
  ArrayList<Person> peopleInTrackDistance = new ArrayList<Person>();

  for (int p=0; p<activePersons.size (); p++) 
  {
    Person person = activePersons.get(p);
    float d = dist(x, y, person.location.x, person.location.y);
    if (d <= trackDistance) 
    {
      peopleInTrackDistance.add(person);
      //person.update(x, y);
      //p = activePersons.size()-1;
    }
  }
  if (peopleInTrackDistance.size() == 1)
  {
    Person person = peopleInTrackDistance.get(0);
    person.update(x, y);
  } else if (peopleInTrackDistance.size() > 1) {
    Person person = peopleInTrackDistance.get(0);
    person.update(x, y);
    /*
		for (int t = 0; t < peopleInTrackDistance.size(); ++t)
     		{
     			//Size comparison and pick best match if multiple people in peopleInTrackDistance
     		}*/
  } else {
    activePersons.add(new Person(x, y, id));
    id++;
  }
  peopleInTrackDistance.clear();
}


public void checkPersonStatus()
{
  for (int z=activePersons.size ()-1; z>0; z--) 
  {
    Person person = activePersons.get(z);

    if (person.isDead || person.leftViewport)
    {
      oldPersons.add(person);
      activePersons.remove(z);
    } else if (!person.updated)
    {
      person.timer++;
      if (person.location.x < viewportBorder || 
        person.location.x > width-viewportBorder || 
        person.location.y < viewportBorder || 
        person.location.y > height-viewportBorder)
      {
        person.leftViewport = true;
        lwp++;
      }
      if (person.timer == timerLimit)
      {
        person.isDead=true;
      }
    }
    person.updated = false;
  }
}


public void displayActivePersons()
{
  for (int z=activePersons.size ()-1; z>0; z--) 
  {
    Person person = activePersons.get(z);
    person.drawID();
    person.display();
    person.drawWaypoints(255, 0, 255);
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
