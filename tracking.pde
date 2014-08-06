float dn = 2;

void createUpdate(float x, float y, float w, float h)
{
<<<<<<< HEAD
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
=======
	ArrayList<Person> peopleInTrackDistance = new ArrayList<Person>();
	PVector blob = new PVector(x,y);
	boolean personFound = false;

	//Check for inactivePersons
	/*
	for (int ip=0; ip<inactivePersons.size(); ip++) 
	{
		Person person = inactivePersons.get(ip);
		float dal = dist(x, y, person.assumedLocation.x, person.assumedLocation.y);
		if (dal <= trackDistance) 
    {
			if((person.averageWidth-person.averageWidth/dn)<w&&w<(person.averageWidth+person.averageWidth/dn)||(person.averageHeight-person.averageHeight/dn)<h&&h<(person.averageHeight+person.averageHeight/dn))
			{
				person.update(x,y,w,h);
				person.age = 0;
				person.assumedWaypoints.clear();
				activePersons.add(person);
				inactivePersons.remove(ip);
				personFound = true;
				break;
			}
		}
	}
	*/

	//Check for activePersons
	/*
	if(!personFound)
	{
	*/
		for (int ap=0; ap<activePersons.size(); ap++) 
		{
			//Push all activePersons within the trackDistance radius into the "peopleInTrackDistance" array
			Person person = activePersons.get(ap);
			float d = dist(x, y, person.location.x, person.location.y);
			if (d <= trackDistance) 
	    {
	    	peopleInTrackDistance.add(person);
			}
		}

		if(peopleInTrackDistance.size() == 1)
		{
			//If just one person in trackDistance: Update if blob is at viewportBorder, else check size and update
			Person person = peopleInTrackDistance.get(0);
			if((viewportBorder>(x-w/2))||((x+w/2)>width-viewportBorder)||(viewportBorder>(y-h/2))||((y+h/2)>height-viewportBorder))
			{
				person.update(x,y,w,h);
				personFound = true;
			}
			else
			{
				if((person.averageWidth-person.averageWidth/dn)<w&&w<(person.averageWidth+person.averageWidth/dn)||(person.averageHeight-person.averageHeight/dn)<h&&h<(person.averageHeight+person.averageHeight/dn))
				{
					person.update(x,y,w,h);
					personFound = true;
				}
			}
		}
		else if(peopleInTrackDistance.size() > 1)
		{
			//If more than one person in trackDistance:
			for (int t = 0; t < peopleInTrackDistance.size(); ++t)
			{
				Person person = peopleInTrackDistance.get(t);
				//If person is not at viewportBorder: Check size and heading and update
				if((viewportBorder<(x-w/2))||((x+w/2)<width-viewportBorder)||(viewportBorder<(y-h/2))||((y+h/2)<height-viewportBorder))
				{
					if((person.averageWidth-person.averageWidth/dn)< w&&w<(person.averageWidth+person.averageWidth/dn)||(person.averageHeight-person.averageHeight/dn)<h&&h<(person.averageHeight+person.averageHeight/dn))
					{
						if(person.waypoints.size() > 2)
						{
							PVector wp1 = person.waypoints.get(person.waypoints.size()-1);
							PVector wp2 = person.waypoints.get(person.waypoints.size()-2);
							PVector wpVector = PVector.sub(wp2,wp1); wpVector.normalize();
							PVector dirVector = PVector.sub(wp1,blob); dirVector.normalize();
							int minDiff = int(degrees(wpVector.heading())-fieldOfVision/2);
							int maxDiff = int(degrees(wpVector.heading())+fieldOfVision/2);
							int dirHeading = int(degrees(dirVector.heading()));
							if(minDiff < dirHeading && dirHeading < maxDiff)
							{
								person.update(x,y,w,h);
								t = peopleInTrackDistance.size();
								personFound = true;
							}
						}
					}
				}
				//If person is at viewportBorder: Check heading and update
				else 
				{
					if(person.waypoints.size() > 2)
					{
						PVector wp1 = person.waypoints.get(person.waypoints.size()-1);
						PVector wp2 = person.waypoints.get(person.waypoints.size()-2);
						PVector wpVector = PVector.sub(wp2,wp1); wpVector.normalize();
						PVector dirVector = PVector.sub(wp1,blob); dirVector.normalize();
						int minDiff = int(degrees(wpVector.heading())-fieldOfVision/2);
						int maxDiff = int(degrees(wpVector.heading())+fieldOfVision/2);
						int dirHeading = int(degrees(dirVector.heading()));
						if(minDiff < dirHeading && dirHeading < maxDiff)
						{
							person.update(x,y,w,h);
							t = peopleInTrackDistance.size();
							personFound = true;
						}
					}
				}
			}
		}
	/*
	}
	*/

	//If blob cannot find an old person instance within the trackDistance
	if(!personFound)
	{
		//Update if person is not at viewportBorder
		if((viewportBorder<(x-w/2))||((x+w/2)<width-viewportBorder)||(viewportBorder<(y-h/2))||((y+h/2)<height-viewportBorder))
		{
			activePersons.add(new Person(x,y,w,h,id));
			++id;
		}
	}
>>>>>>> edc622d0478bbdce81bdef47ba326249aa6962d1
}


void checkPersonStatus()
{
  for (int z=activePersons.size ()-1; z>0; z--) 
  {
    Person person = activePersons.get(z);

<<<<<<< HEAD
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

=======
		if(person.isDead)
		{
			if (person.waypoints.size() > 4) {
				oldPersons.add(person);
				activePersons.remove(z);
				person.updated = true;
			}
			else{
				activePersons.remove(z);
			}
		}

		else if (!person.updated)
		{
			/*
			if(person.atViewportBorder)
			{
				*/
				person.isDead=true;
				/*
				++lwp;
			}
			else
			{
				boolean isGhost = false;
				for (int ap = activePersons.size()-1; ap > 0; ap--)
				{
					Person thisPerson = activePersons.get(ap);
					float d = PVector.dist(person.location, thisPerson.location);
					if(d < checkIfGhostDistance)
					{
						if(thisPerson.waypoints.size() == 0)
						{
							if(thisPerson.pWidth > person.pWidth || thisPerson.pHeight > person.pHeight)
							{
								isGhost = true;
								person.assumedLocation = person.location;
								inactivePersons.add(person);
								activePersons.remove(z);
								break;
							}
						}
					}
				}
				if(!isGhost)
				{
					person.isDead=true;
				}
			}
			*/
		}

		else if (person.updated) {
			person.drawID();
			person.display();
			person.drawWaypoints(255,0,255);
		}
		person.updated = false;
	}

	/*
	for (int z=inactivePersons.size()-1;z>0; z--) 
	{
		Person person = inactivePersons.get(z);
		if(person.ghostAge > maxAge)
		{
			if (person.waypoints.size() > 4) {
				oldPersons.add(person);
				inactivePersons.remove(z);
			}
			else{
				inactivePersons.remove(z);
			}
		}
		else 
		{
			person.ghost();
		}
	}
	*/
}
>>>>>>> edc622d0478bbdce81bdef47ba326249aa6962d1
