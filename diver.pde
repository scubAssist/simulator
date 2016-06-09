  
import java.util.Map;

class Diver {
  PVector pos; 
  boolean recievedIdx = false;
  int lastrecievedIdx = 0;
  float zero = 0;
  float boeiInterval = 1000;
  float soundspeed = 1450/1000; // (m/s)/millis
  int aantalBoeien = 5;
  float[] distances = new float[aantalBoeien];
  
  
  Diver(float xpos, float ypos, float zpos) {
    pos = new PVector(xpos, ypos, zpos);
  }
  
  void updateSoundSpeed(float speed) {
    soundspeed = speed/1000;  // (m/s)/millis
  }
  
  void setPos(float xpos, float ypos, float zpos) {
    pos = new PVector(xpos, ypos, zpos);
  }
  
  void resetTimerZero(float mils, int boei) {
    if (!recievedIdx) {
      // disregard value
      distances[boei] = 0;
    }
    zero = mils;
    recievedIdx = false;
  }
  
  void update()
  {
    
  }
  
  void draw() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    noFill();
    if (recievedIdx) {
      stroke(0, 255, 0);
    } else {
      stroke(255, 0, 0);
    }
    sphere(1);
    

    popMatrix();
  }
  
  void recievePing(int idx) {
    recievedIdx = true;
    lastrecievedIdx = idx;
    float del = millis() - zero;
    float dist = soundspeed * del;
    distances[lastrecievedIdx] = dist;
  }
      
  PVector getPos() {
    return pos;
  }
}