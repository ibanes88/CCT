void createUpdate(float x, float y)
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


void checkPersonStatus()
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


void displayActivePersons()
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

