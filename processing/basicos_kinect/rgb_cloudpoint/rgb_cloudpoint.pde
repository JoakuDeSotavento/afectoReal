import processing.opengl.*;
import SimpleOpenNI.*;
SimpleOpenNI kinect;
float rotation = 0;

int frecP = 1;

float        zoomF =0.3f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
// the data from openni comes upside down
float        rotY = radians(0);

void setup() {
  size(1024, 768, OPENGL);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  // access the color camera
  kinect.enableRGB(); 
  
    // tell OpenNI to line-up the color pixels
  // with the depth data
  kinect.alternativeViewPointDepthToImage(); 
  
}
void draw() {
  background(0); 
  
  kinect.update();

  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
  PImage rgbImage = kinect.rgbImage(); 

    
  //rotation++;
  PVector[] depthPoints = kinect.depthMapRealWorld();
  // don't skip any depth points
  for (int i = 0; i < depthPoints.length; i+=frecP) {
    PVector currentPoint = depthPoints[i];
    // set the stroke color based on the color pixel
    stroke(rgbImage.pixels[i]); 

      point(currentPoint.x, currentPoint.y, currentPoint.z);
  }
}



void keyPressed()
{
  switch(key)
  {
  case ' ':
    kinect.setMirror(!kinect.mirror());
    break;
  }

  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if (keyEvent.isShiftDown())
      zoomF += 0.02f;
    else
      rotX += 0.1f;
    break;
  case DOWN:
    if (keyEvent.isShiftDown())
    {
      zoomF -= 0.02f;
      if (zoomF < 0.01)
        zoomF = 0.01;
    }
    else
      rotX -= 0.1f;
    break;
    
     case ENTER:
    
    frecP++;
    
    if(frecP > 20)frecP = 1;
    
    break;
    
        case TAB:
    
    frecP--;
        if(frecP < 2)frecP = 2;
    
    break;
  }
}

void mousePressed(){
 
  save("meh-####.bmp");
  
}
