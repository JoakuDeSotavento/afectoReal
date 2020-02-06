import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class processing_to_servo1 extends PApplet {


Serial port;

byte out[] = {0, 0, 0, 0};

// port.write(out);


public void setup() {
  println(Serial.list());
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 9600);
  port.write(out);
}
public void draw() {
}

public void keyPressed() {

  if (key == 'a') {
    out[0] = 10;
    out[1] = 20;
    out[2] = 30;
    out[3] = 50;
    port.write(out);
  } else if (key == 's') {
    out[0] = 20;
    out[1] = 30;
    out[2] = 50;
    out[3] = 80;
    port.write(out);
  } else if (key == 'd') {
    out[0] = 30;
    out[1] = 50;
    out[2] = 80;
    out[3] = 120;
    port.write(out);
  } else {
    out[0] = 0;
    out[1] = 0;
    out[2] = 0;
    out[3] = 0;
    port.write(out);
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "processing_to_servo1" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
