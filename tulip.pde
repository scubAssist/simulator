class Tulip {
  TulipValue[] vals;
  
  Tulip (TulipValue[] values) {
    vals = values;
  }
  
  PVector calculate(float diverDepth) {
    // Update the distances and remove the depth component
    for (int idx = 0; idx < 3; idx++) {
      float b = pow(vals[idx].measuredDistance,2) - pow(diverDepth,2);
      vals[idx].flatDistance = sqrt(b);
    }
    
    float i1 = vals[0].buoyPosition.x;
    float i2 = vals[1].buoyPosition.x;
    float i3 = vals[2].buoyPosition.x;
    
    float j1 = vals[0].buoyPosition.y;
    float j2 = vals[1].buoyPosition.y;
    float j3 = vals[2].buoyPosition.y;
        
    float d1 = vals[0].flatDistance;
    float d2 = vals[1].flatDistance;
    float d3 = vals[2].flatDistance;
    
    float x = (((pow(d1,2)-pow(d2,2)) + (pow(i2,2)-pow(j1,2)) + (pow(j2,2)-pow(j1,2)))
    * ((2.0*j3) -(2.0*j2))
    - ((pow(d2,2)-pow(d3,2)) + (pow(i3,2) - pow(i2,2)) + (pow(j3,2)-pow(j2,2)))
    * ((2.0*j2)-(2.0*j1)))
    / (((2.0*i2)-(2.0*i3)) * ((2.0*j2)-(2.0*j1)) - ((2.0*i1)-(2.0*i2)) * ((2.0*j3)-(2.0*j2)));
    
    float y = ((pow(d1,2)-(pow(d2,2))) + (pow(i2,2)-pow(i1,2)) + (pow(j2,2)-pow(j1,2)) + x * ((2.0*i1) - (2.0*i2))) / ((2.0*j2) - (2.0*j1));
    
    return new PVector(x,y,-diverDepth);
  }
}

class TulipValue {
  float measuredDistance = 0;
  float flatDistance;
  PVector buoyPosition;
  
  TulipValue (float dist, PVector pos) {
    measuredDistance = dist;
    flatDistance = 0;
    buoyPosition = pos;
  }
}