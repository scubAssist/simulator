class Boei {
  float xpos, ypos;
  PVector pos;
  int id;
  boolean ispinging = false;
  boolean haspinged = false;
  boolean isRecieved = false;
  float startpingtime = 0;
  float pingradius = 0;
  float soundspeed = 1450/1000; // (m/s)/millis
  float distance;
  Diver diver;
  
  Boei(int nr, float x, float y, Diver thediver) {
    xpos = x;
    ypos = y;
    id = nr;
    
    diver = thediver;
    
    pos = new PVector(xpos, ypos, 0);
  }
  
  void updateSoundSpeed(float speed) {
    soundspeed = speed/1000;  // (m/s)/millis
  }
  
  void update(int curid) {
    // Elke cycle kijken we of wij aan de beurt zijn voor een ping
    if (id == curid && !ispinging && !haspinged) {
      // start pinging
      startpingtime = millis();
      pingradius = 0;
      isRecieved = false;
      ispinging = true;
    } 
    
    if (id != curid) {
      haspinged = false;
    }
    
    if (ispinging && (millis() - startpingtime) > 100) {
      ispinging = false;
      haspinged = true;
      isRecieved = false;
    }
    
    PVector dpos = diver.getPos();
    distance = abs(dist(pos.x, pos.y, pos.z, dpos.x, dpos.y, dpos.z));//sqrt(xd*xd+yd*yd+zd*zd);
        
    if (ispinging) {
      if ((distance <= (pingradius)) && !isRecieved) {
        // it collides
        diver.recievePing(id);
        isRecieved = true;
      } 
    }
           
  }
  
  void draw() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    noFill();
    if (ispinging) {
      stroke(0,255,0);
    } else {
      stroke(255);
    }
    sphere(2);
    popMatrix();
    
    if (ispinging) {
      // adjust the radius
      pingradius = (millis() - startpingtime) * soundspeed;
      pushMatrix();
      translate(pos.x, pos.y, pos.z);
      noFill();
      if (isRecieved) {
        stroke(0,255,0);
      } else {
        stroke(255,255,0);
      }
      sphere(pingradius);
      popMatrix();
    }
  }
}