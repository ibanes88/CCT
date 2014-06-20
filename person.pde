class Person 
{
	int id; //specific Id
	boolean hasBeenUpdated = true;
	boolean isDead = false;

	PVector location;
	PVector locationOld;

	ArrayList <PVector> way = new ArrayList <PVector>();


Person(float x, float y)
{
	location = new PVector(x,y);
}


void update(float x, float y)
{
	if(frameCount%5==0)
	{
		way.add(new PVector(location.x,location.y));
	}

	location.x = x;
	location.y = y;
	hasBeenUpdated = true;
}


void drawID() 
{
	textFont(f,10);
	fill(255,0,0);
	text(id, location.x+20,location.y+20);
}


void display()
{
	noStroke();
	fill(0,0,255);
	ellipse(location.x,location.y,12,12);
}


void drawWaypoints(int r, int g, int b)
{
	for (int i=way.size()-1;i>1;i--)
	{
		PVector f = way.get(i);
		PVector d = way.get(i-1);
		stroke(r,g,b);
		strokeWeight(2);
		line(f.x,f.y,d.x,d.y);
    }
}
};

