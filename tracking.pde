void createUpdate(float x, float y)
{
	boolean isNear=false;
	for (int z=0; z<newPersons.size(); z++) 
	{
		Person person = newPersons.get(z);
		if (x-range<person.location.x && x+range>person.location.x && y-range<person.location.y && y+range>person.location.y) 
    	{
			isNear=true;
			person.update(x, y);
			z=newPersons.size()-1;
		}
	}
  	if (!isNear) 
	{
		newPersons.add(new Person(x, y));
	}

	isNear=false; 
}


void personDead()
{
	for (int z=newPersons.size()-1;z>0; z--) 
	{
		Person person = newPersons.get(z);
		if(person.isDead)
		{
			oldPersons.add(person);
			newPersons.remove(z);
		} else if (!person.hasBeenUpdated)
		{
        	person.isDead=true;
		}
		person.hasBeenUpdated=false;
	}

}


void visualize()
{
	for (int z=newPersons.size()-1;z>0; z--) 
	{
		Person person = newPersons.get(z);
		//person.id = z;
		person.printId();
		person.display();
		person.drawPath(255,0,255);
		//println("ID : "+person.id+" ist : " + "x : " + person.location.x + " y : " + person.location.y);
		//println(newPersons[z].id);
	}
}
        