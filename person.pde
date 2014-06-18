class Person {
PVector location;
PVector velocity;
int id;
PVector locationOld;
int range=10;

Person(float x, float y,int id_){
   location = new PVector(x,y);
   velocity = new PVector(0,0);
   id = id_;
   
}

void update(){
  location.add(velocity);
}

void trackPath() {
  stroke(255,255,0);
  if (locationOld!=null && location!=null){
  line(locationOld.x,locationOld.y,location.x,location.y);
  }
}

void printId() {
  textFont(f,10);
  fill(255,0,0);
  //text("X: " + location.x + "Y: " + location.y,location.x*width+20,location.y*height+20);
  text("ID =" + id, location.x+20,location.y+20);
}

void updateId() {
  for (int i=oldPersons.size()-1;i>0;i--){
    Person person = oldPersons.get(i);
    float x_ = person.location.x;
    float y_ = person.location.x;
    int id_ = person.id; 
    if (x_-range<location.x && x_+range>location.x && y_-range<location.y && y_+range>location.y){
      id=id_;
      locationOld = person.location;
      return;
    }
    }
}

void display(){
          fill(255,0,0);
          ellipse(location.x,location.y,10,10);
}
}
