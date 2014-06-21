class Person 
{
	int pID; //specific Id
	int timer = 0;
	int age = 0;
	boolean updated = true;
	boolean isDead = false;
	boolean leftViewport;

	PVector location;

	ArrayList <PVector> waypoints = new ArrayList <PVector>();


Person(float x, float y, int id)
{
	location = new PVector(x,y);
	pID = id;
}


void update(float x, float y)
{
	if(frameCount%5==0)
	{
		waypoints.add(new PVector(location.x,location.y));
		age++;
	}

	location.x = x;
	location.y = y;
	updated = true;
}


void drawID() 
{
	textFont(f,10);
	fill(255,0,0);
	text(pID, location.x+20,location.y+20);
}


void display()
{
	noStroke();
	fill(0,0,255);
	ellipse(location.x,location.y,8,8);
	noFill();
	stroke(0);
	ellipse(location.x, location.y, trackDistance/2, trackDistance/2);
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

