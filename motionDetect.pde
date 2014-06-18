void motionDetect()
{
  // Capture video
  //if (video.available()) {
    // Save previous frame for motion detection!!
    //prevFrame.copy(video,0,0,video.width,video.height,0,0,video.width,video.height); // Before we read the new frame, we always save the previous frame for comparison!
    //prevFrame.updatePixels();
    //video.read();
  //}
  
  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();
  
  // loop durch pixel array
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {
      
      int loc = x + y*video.width;            // 1d position
      color current = video.pixels[loc];      // farbe
      color previous = prevFrame.pixels[loc]; // farbe letzter frame
      
      // differenz
      float r1 = red(current); float g1 = green(current); float b1 = blue(current);
      float r2 = red(previous); float g2 = green(previous); float b2 = blue(previous);
      float diff = dist(r1,g1,b1,r2,g2,b2);
      
      // vergleichen mit treshold
      if (diff > threshold) { 
        // black
        pixels[loc] = color(0);
      } else {
        // white gamma, für blur
        //stroke(255,255,255,100);
        //point(x, y);
        //pixels[loc] = color(255);u
      }
    }
  }
  updatePixels();
}
