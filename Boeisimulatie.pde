/* Human swimming 1m/s max */


/*
http://www.engineeringtoolbox.com/sound-speed-water-d_598.html
Temperature C  Speed of Sound m/s
0              1,403
5              1,427
10             1,447
20             1,481
30             1,507
40             1,526
50             1,541
60             1,552
70             1,555
80             1,555
90             1,550
100            1,543

Kies een water temperatuur en de snelheid word daar op aangepast.

*/

import peasy.*;
import controlP5.*;

DropdownList tempList;
PeasyCam cam;
ControlP5 p5;
Boei[] boeien;
Diver diver = new Diver(50, 50, -40);
int aantalBoeien = 5;
float milliInterval = 500;
float lastBoei = 0;
int currentBoeiIdx = 0;
float diverSpeed = 0.5;

PVector calculatedPos = new PVector(0,0,0);

void setup() {
  size(1024,768,P3D);
  smooth();
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(500);
  
  p5 = new ControlP5(this);
  p5.addButton("colorA")
     .setValue(0)
     .setPosition(100,100)
     .setSize(200,19)
     .setLabel("Dit is een test")
     ;
     
  tempList = p5.addDropdownList("myList-d1")
          .setPosition(10, 100)
          ;
  //tempList.label().set("temperature");
  tempList.addItem("0 C", 0.0);
  tempList.addItem("5 C", 5.0);
  tempList.addItem("10 C", 10.0);
  tempList.addItem("20 C", 20.0);
  tempList.addItem("30 C", 30.0);
     
  p5.setAutoDraw(false);
    
  boeien = new Boei[aantalBoeien];

  boeien[0] = new Boei(0, 0, 0, diver);
  boeien[1] = new Boei(1, 100.1, 1, diver);
  boeien[2] = new Boei(2, 2, 98.5, diver);
  boeien[3] = new Boei(3, 99.9, 99.7, diver);
  boeien[4] = new Boei(4, 75.1, 45.3, diver);
  
  lastBoei = millis();
  diver.resetTimerZero(lastBoei, 0);
}


void draw() {
  background(0);
  if ((millis() - lastBoei) > milliInterval) {
    lastBoei = millis();
    diver.resetTimerZero(lastBoei, currentBoeiIdx);
    currentBoeiIdx++;
    

    if (currentBoeiIdx >= aantalBoeien) {
      currentBoeiIdx = 0;
    }
  }
    
  for (int idx = 0; idx < aantalBoeien; idx++) {
    boeien[idx].draw();
    boeien[idx].update(currentBoeiIdx);
  }
  
  diver.draw();
  
  
  // Na alle boeien!
  if (currentBoeiIdx == 0) {
    // Nu kunnen we de positie bepalen met TULIP
    // Als er minimaal 3 correcte waarden zijn gemeten
    // Pak de 3 kleinste waarden, die zijn het dichtsbij en dus waarschijnlijk het meest correct
    // de waarden zijn afstanden inc hoogteverschil, haal het hoogteverschil er uit (pythagoras)
    // Bereken dan de 2 dimensionale coordinaten en voeg de diepte weer toe
    float[] sorted = sort(diver.distances);
    float[] selvals = new float[3];
    int selidx = 0;
    for (int idx = 0; idx < sorted.length; idx++) {
      if (sorted[idx] > 0) {
        if (selidx < 3) {
          selvals[selidx] = sorted[idx];
          selidx++;
        }
      }
    }
    
    int valIdx = 0;
    TulipValue[] vals = new TulipValue[3];
    if (selidx == 3) {
      for (int idx = 0; idx < aantalBoeien; idx++) {
        if (valIdx < 3) {
          if (inArray(selvals, diver.distances[idx])) {
            vals[valIdx] = new TulipValue(diver.distances[idx], boeien[idx].pos);
            valIdx++;
          }
        }
      }    
    }
    
    if (valIdx == 3) {
      // We kunnen een TULIP poging gaan doen
      Tulip tulp = new Tulip(vals);
      calculatedPos = tulp.calculate(abs(diver.pos.z));
      
    }
  }
   
  pushMatrix();
  translate(calculatedPos.x,calculatedPos.y, calculatedPos.z);
  noFill();
  stroke(255, 255, 100);
  sphere(4);
  popMatrix();
  
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  p5.draw();
  for (int idx =0; idx < aantalBoeien; idx++) {
    fill(0, 102, 153);
    text(diver.distances[idx], 10, 10 + (10 * idx));
    fill(100, 0, 153);
    text(boeien[idx].distance, 70, 10 + (10 * idx));
    fill(100, 0, 10);
    text(abs(diver.distances[idx] - boeien[idx].distance), 130, 10 + (10 * idx));
    fill(100, 0, 10);
    text((abs(diver.distances[idx] - boeien[idx].distance) / diver.distances[idx]) * 100, 190, 10 + (10 * idx));
  }

  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

boolean inArray(float[] arr, float val) {
  for (int idx=0; idx<arr.length; idx++) {
    if (arr[idx] == val) {
      return true;
    }
  }
  return false;
}

void keyPressed() {
  
  PVector dpos = diver.getPos();
  if (key == 'a') {
    diver.setPos(dpos.x - diverSpeed, dpos.y, dpos.z);
  }
  if (key == 'd') {
    diver.setPos(dpos.x + diverSpeed, dpos.y, dpos.z);
  }
  if (key == 'w') {
    diver.setPos(dpos.x , dpos.y - diverSpeed, dpos.z);
  }
  if (key == 's') {
    diver.setPos(dpos.x, dpos.y + diverSpeed, dpos.z);
  }
  if (key == 'q') {
    diver.setPos(dpos.x , dpos.y, dpos.z + diverSpeed);
  }
  if (key == 'e') {
    diver.setPos(dpos.x, dpos.y, dpos.z - diverSpeed);
  } 
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  /*
0              1,403
5              1,427
10             1,447
20             1,481
30             1,507
  */

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    switch((int)theEvent.getGroup().getValue()) {
      case 0: 
        updateSoundSpeed(1403);
        break;
      case 1: 
        updateSoundSpeed(1427);
        break;        
      case 2: 
        updateSoundSpeed(1447);
        break;
      case 3: 
        updateSoundSpeed(1481);
        break;
      case 4: 
        updateSoundSpeed(1507);
        break;        
    }
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
        switch((int)theEvent.getController().getValue()) {
      case 0: 
        updateSoundSpeed(1403);
        break;
      case 1: 
        updateSoundSpeed(1427);
        break;        
      case 2: 
        updateSoundSpeed(1447);
        break;
      case 3: 
        updateSoundSpeed(1481);
        break;
      case 4: 
        updateSoundSpeed(1507);
        break;        
    }
  }
}

void updateSoundSpeed(float speed) {
  for (int idx = 0; idx < aantalBoeien; idx++) {
    if (boeien[idx] != null) {
      boeien[idx].updateSoundSpeed(speed);
    }
  }
  
  if (diver != null) {
    diver.updateSoundSpeed(speed);
  }
}