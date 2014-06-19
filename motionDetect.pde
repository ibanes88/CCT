void motionDetect()
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
			color current = video.pixels[loc]; // current color
			color previous = prevFrame.pixels[loc]; // last frame color
	   
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
