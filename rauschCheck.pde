int xRausch, yRausch, lTest, schwelle;
PImage rauschen;
int rauschCheckX = 5;
int rauschCheckY = 10;
int pCount=0;

void rauschCheck() {
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
          } else {
          pixels[loc] = color(0);
        }
         // println(pCount);
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
