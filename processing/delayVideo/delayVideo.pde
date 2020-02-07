import processing.video.*;

Capture cam;
PImage[] buffer;
int w = 640;
int h = 360;
int nFrames = 60;
int iWrite = 0, iRead = 1;

void setup(){
  size(640, 360);
  cam = new Capture(this, w, h);
  cam.start();
  buffer = new PImage[nFrames];
}

void draw() {
  if(cam.available()) {
    cam.read();
    buffer[iWrite] = cam.get();
    if(buffer[iRead] != null){
      image(buffer[iRead], 0, 0);
    }
    iWrite++;
    iRead++;
    if(iRead >= nFrames-1){
      iRead = 0;
    }
    if(iWrite >= nFrames-1){
      iWrite = 0;
    }
  }       
}
