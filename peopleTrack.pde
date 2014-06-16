Blob p;
ArrayList<person> peopleInTrackDistance;
ArrayList<person> peopleTracked;
int trackDistance = 25;

class person {
	float posX;
	float posY;
	float speed;

	person(float tempX,float tempY){
		posX = tempX;
		posY = tempY;
	}
};

void peopleTrack (){
	peopleInTrackDistance = new ArrayList<person>();
	peopleTracked = new ArrayList<person>();
	//Push people to prevPeople and update people Array
	prevPeople.clear();
	prevPeople = people;
	people.clear();
	for (int n=0 ; n<theBlobDetection.getBlobNb() ; n++){
		p = theBlobDetection.getBlob(n);
		people.add(new person(p.x,p.y));
	}

	println("people.size: " + people.size());

	for (int e = 0; e < prevPeople.size(); ++e) {
		for (int i = 0; i < people.size(); ++i) {
			person p1 = people.get(i);
			person p2 = prevPeople.get(e);
			float d = dist(p1.posX,p1.posY,p2.posX,p2.posY);
			if(d < trackDistance){
				//Push to Array peopleInTrackDistance
				peopleInTrackDistance.add(new person (p1.posX,p1.posY));
			}
		}
		//Check which person in peopleInTrackDistance is most likely the person we track
		if(peopleInTrackDistance.size() == 1){
			//Update Coordinates of person and push to Array drawLines
			person p = peopleTracked.get(e);
			person n = peopleInTrackDistance.get(0);
			p.posX = n.posX;
			p.posY = n.posY;
		}
		else if(peopleInTrackDistance.size() > 1){
			for (int t = 0; t < peopleInTrackDistance.size(); ++t) {
				//Size comparison and pick best match if multiple people in peopleInTrackDistance
			}
		}
		else {
			//Delete person if no match found
			peopleTracked.remove(e);
		}
		peopleInTrackDistance.clear();
	}
	//Display ID of Person
	for (int i = 0; i < peopleTracked.size(); ++i) {
		person p = peopleTracked.get(i);
		textSize(10);
		text("person"+i, p.posX, p.posY);
}