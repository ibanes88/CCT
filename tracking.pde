void createUpdate(float x, float y)
{
	boolean isNear=false;
	for (int z=0; z<activePersons.size(); z++) 
	{
		Person person = activePersons.get(z);
		if (x-range<person.location.x && x+range>person.location.x && y-range<person.location.y && y+range>person.location.y) 
    	{
			isNear=true;
			person.update(x, y);
			z=activePersons.size()-1;
		}
	}
  	if (!isNear) 
	{
		activePersons.add(new Person(x, y));
	} 
}


void checkPersonStatus()
{
	for (int z=activePersons.size()-1;z>0; z--) 
	{
		Person person = activePersons.get(z);
		if(person.isDead)
		{
			oldPersons.add(person);
			activePersons.remove(z);
		} else if (!person.hasBeenUpdated)
		{
        	person.isDead=true;
		}
		person.hasBeenUpdated=false;
	}

}


void displayActivePersons()
{
	for (int z=activePersons.size()-1;z>0; z--) 
	{
		Person person = activePersons.get(z);
		//person.id = z;
		person.drawID();
		person.display();
		person.drawWaypoints(255,0,255);
		//println("ID : "+person.id+" ist : " + "x : " + person.location.x + " y : " + person.location.y);
		//println(activePersons[z].id);
	}
}