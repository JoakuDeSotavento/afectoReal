import processing.opengl.*;
import SimpleOpenNI.*;

SimpleOpenNI kinect;

PImage userImage;
int userID;
int[] userMap;
PImage depthImage;
PImage rgbImage;
PImage vacio;

void setup() {
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableUser(); 
  vacio = loadImage("behemoth_blackhole.jpg");
}

void draw() {
  //background(0);  
  kinect.update();  
  depthImage = kinect.depthImage();
  rgbImage = kinect.rgbImage();
  // prepare the Depth pixels 
  //depthImage.loadPixels();
  rgbImage.loadPixels();
  // if we have detected any users
  if (kinect.getNumberOfUsers() > 0) {  
    // find out which pixels have users in them
    userMap =kinect.userMap();  
    // populate the pixels array
    // from the sketch's current contents
    //loadPixels();  
    for (int i = 0; i < userMap.length; i++) {  
      // if the current pixel is on a user
      if (userMap[i] != 0) {
      //pixels[i] = depthImage.pixels[i];
      // make it green
      rgbImage.pixels[i] = vacio.pixels[i];  
      }
    }
     // display the changed pixel array
    rgbImage.updatePixels();  
   }
   image(rgbImage, 0, 0);
}
void onNewUser(int uID) {
  userID = uID;
  println("tracking");
}
