class Person 
{
	int pID; //specific Id
	int age = 1;
	int ghostAge = 0;
	//int timer = 0;
	boolean updated = true;
	boolean isDead = false;
	boolean atViewportBorder;

	float pWidth;
	float pHeight;
	float averageWidth;
	float averageHeight;
	float widthCounter;
	float heightCounter;

	PVector location;
	float velocity; //average velocity in px/frame
	PVector direction; //average direction as normalized PVector

	PVector assumedLocation;
	PVector assumedMovement;

	ArrayList <PVector> waypoints = new ArrayList <PVector>();
	ArrayList <PVector> assumedWaypoints = new ArrayList <PVector>();


Person(float x, float y, float w, float h, int id)
{
	location = new PVector(x,y);
	direction = new PVector(0,0);
	assumedLocation = new PVector(0,0);
	assumedMovement = new PVector(0,0);
	pWidth = w;
	pHeight = h;
	widthCounter = w;
	heightCounter = h;
	averageWidth = w;
	averageHeight = h;
	pID = id;
}


void update(float x, float y, float w, float h)
{
	if(frameCount%4 == 0)
	{
		waypoints.add(new PVector(location.x,location.y));

		if(this.waypoints.size() == 2)
		{
			//Assign direction and velocity
			PVector wp1 = this.waypoints.get(this.waypoints.size()-1);
			PVector wp2 = this.waypoints.get(this.waypoints.size()-2);
			PVector wpVector = PVector.sub(wp1,wp2);
			velocity = wpVector.mag();
			direction = wpVector;
		}
		if(this.waypoints.size() > 2)
		{
			//Calculate direction
			PVector wp1 = this.waypoints.get(this.waypoints.size()-1);
			PVector wp2 = this.waypoints.get(this.waypoints.size()-2);
			PVector wpVector = PVector.sub(wp1,wp2);
			direction.add(wpVector);

			//Calculate average velocity
			float magnitudes = 0;
			for (int i = 1; i < waypoints.size(); ++i) {
				PVector wpThis = waypoints.get(i);
				PVector wpLast = waypoints.get(i-1);
				PVector thisWpVector = PVector.sub(wpThis,wpLast );
				float wpVelocity = thisWpVector.mag();
				magnitudes += wpVelocity;
			}
			magnitudes /= (waypoints.size()-1);
			velocity = magnitudes;
		}
	}

	++age;
	widthCounter += w;
	heightCounter += h;
	averageWidth = widthCounter/((float)age);
	averageHeight = heightCounter/((float)age);

	location.x = x;
	location.y = y;
	pWidth = w;
	pHeight = h;

	if(this.location.x < viewportBorder || this.location.x > width-viewportBorder || 
		this.location.y < viewportBorder || this.location.y > height-viewportBorder)
	{
		this.atViewportBorder = true;
	}
	else
	{
		this.atViewportBorder = false;
	}

	updated = true;
}

/*
void ghost()
{
	assumedMovement = PVector.mult(direction,velocity);

	//Update ghost
	if(frameCount%5 == 0)
	{
		assumedLocation.add(assumedMovement);
		assumedWaypoints.add(new PVector(assumedLocation.x,assumedLocation.y));
		++ghostAge;
	}

	//Display ghost
	noStroke();
	fill(150);
	ellipse(assumedLocation.x,assumedLocation.y,8,8);
	//Display ghost trackDistance
	noFill();
	stroke(150);
	ellipse(assumedLocation.x, assumedLocation.y, trackDistance*2, trackDistance*2);
	//Display ids
	textFont(f,10);
	fill(150);
	text(pID, assumedLocation.x+30,assumedLocation.y+30);

	//Draw assumedWaypoints
	for (int i=assumedWaypoints.size()-1;i>1;i--)
	{
		PVector f = assumedWaypoints.get(i);
		PVector d = assumedWaypoints.get(i-1);
		stroke(150);
		strokeWeight(2);
		line(f.x,f.y,d.x,d.y);
	}
}
*/

void drawID() 
{
	textFont(f,10);
	fill(255,0,0);
	text(pID, location.x+30,location.y+30);
}


void display()
{
	//Display Person instance
	noStroke();
	fill(0,0,255);
	ellipse(location.x,location.y,8,8);
	//Display trackDistance
	noFill();
	stroke(255);
	ellipse(location.x, location.y, trackDistance*2-4, trackDistance*2-4);
	stroke(0);
	ellipse(location.x, location.y, trackDistance*2, trackDistance*2);
}


void drawWaypoints(int r, int g, int b)
{
	for (int i=waypoints.size()-1;i>1;i--)
	{
		PVector f = waypoints.get(i);
		PVector d = waypoints.get(i-1);
		stroke(r,g,b);
		strokeWeight(2);
		line(f.x,f.y,d.x,d.y);
	}
}
};

