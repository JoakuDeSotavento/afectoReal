/*
    
 ///////////////////////////////////////////////////////
 Programa: SaxParticles
 Autores: Joaku De Sotavento (Joaquín R. Díaz)
 
 //////////////////////////////////////////////////////
 Instrucciones de instalacion:
 
 Requerimientos para instalar Kinect
 
 Processing v. 3
 https://www.processing.org/download/ 
 
 SimpleOpenNI
 https://code.google.com/archive/p/simple-openni/
 
 En windows:
 Kinect SDK
 https://www.microsoft.com/en-us/download/details.aspx?id=40278
 
 Kinect development toolkits
 https://www.microsoft.com/en-us/download/details.aspx?id=36998
 
 En MAC: no hace falta instalar ningun driver.
 Si no funciona ir a este sitio y bajar instrucciones:
 https://github.com/processing/processing/issues/2201
 https://github.com/kronihias/head-pose-estimation
 
 ///////////////////////////////////////////////////                                                                                                                                                                                                      
 
 Los toggle en la pantalla manejan los diferentes parametros de la visual
 
 profundidad de rastreo, densidad de la nube de puntos, colores en RGB y
 
 La rotacion de la camara virtual
 
 
 */

import controlP5.*;

ControlP5 cp5;

Knob myKnobA;
Knob myKnobB;

Knob myKnobR;
Knob myKnobG;
Knob myKnobBl;

Knob myKnobRot;

import ddf.minim.*;

Minim minim;
AudioInput in;
AudioRecorder recorder;

import processing.opengl.*;
import SimpleOpenNI.*;

SimpleOpenNI camara;

////contrones de camara

float rotX = radians(180);
float rotY = radians(0);
float rotYau = 0.0;
float zoomF = 0.9f;

//resolucion de la nube de puntos "M" Y "N"
int frecP = 4;

// Se controla la profundidad de rastreo con "L" y "K"
int profundidad = 3000;

int rojo = 50;
int verde = 100;
int azul = 150;

int estado = 0;

boolean foto = false;

int fmr = 0;

/// variables para el perlin noise

float ruidoX = 0.00006;
float acumuladorX;
float nuevaX;

float ruidoY = 0.00006;
float acumuladorY;
float nuevaY;

float ruidoZ = 0.00006;
float acumuladorZ;
float nuevaZ;

// variables para la deteccion de usuario

boolean      autoCalib=true;
PVector      com = new PVector();                                   
PVector      com2d = new PVector();                                   
color[]      userClr = new color[] { 
  color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};


void setup() {

  //frameRate(24);
  fullScreen(P3D);
 //size(1024, 768, P3D);

  // pushMatrix();

  //perspective(radians(-45), -(float(width)/float(height)), -10, -150000);
  cp5 = new ControlP5(this);

  myKnobA = cp5.addKnob("knobA")
    .setRange(0, 5000)
    .setValue(3000)
    .setPosition(50, 50)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;

  myKnobB = cp5.addKnob("knobB")
    .setRange(1, 15)
    .setValue(4)
    .setPosition(50, 150)
    .setRadius(30)
    .setNumberOfTickMarks(15)
    .setColorForeground(color(255))
    .setColorBackground(color(0, 160, 100))
    .setColorActive(color(255, 255, 0))
    .setDragDirection(Knob.VERTICAL)
    ;

  myKnobR = cp5.addKnob("knobR")
    .setRange(0, 250)
    .setValue(random(0, 50))
    .setPosition(50, 250)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;

  myKnobG = cp5.addKnob("knobG")
    .setRange(0, 250)
    .setValue(random(0, 100))
    .setPosition(50, 350)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;

  myKnobBl = cp5.addKnob("knobBl")
    .setRange(0, 250)
    .setValue(random(0, 100))
    .setPosition(50, 450)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;
    
  myKnobRot = cp5.addKnob("knobRot")
    .setRange(-0.3, 0.3)
    .setValue(0)
    .setPosition(width - 100, 50)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;
  // popMatrix();
  frameRate(60);
  minim = new Minim(this);

  in = minim.getLineIn();
  // create a recorder that will record from the input to the filename specified
  // the file will be located in the sketch's root folder.
  recorder = minim.createRecorder(in, "myrecording.wav");

  textFont(createFont("Arial", 12));


  pushMatrix();
  camara = new SimpleOpenNI(this);

  if (camara.isInit() == false) {
    println("No se puede abrir el mapa de profundidad, a lo mejor la camra no esta concetada");
    exit();
    return;
  }

  // disable mirror
  camara.setMirror(false);

  // enable depthMap generation 
  camara.enableDepth();

  // enable skeleton generation for all joints
  camara.enableUser();

  stroke(255, 255, 255);
  smooth();  


  //perspective(radians(45), float(width)/float(height), 10, 150000);
  popMatrix();
}

void draw() {

  camara.update();

  background(0);

  pushMatrix();
  
  translate(width/2, height/2, 0);


  rotateX(rotX);
  rotateY(rotY+=rotYau);


  scale(zoomF);


  PVector[] depthPoint = camara.depthMapRealWorld();
  int[]   userMap = camara.userMap();
  PVector lastPoint = depthPoint[0];
  PVector thirtdPoint = depthPoint[1];

  int     index;
  //PVector realWorldPoint;

  translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera

  switch(estado)
  {


  case 0:

    //beginShape(POINTS);

    for (int i = 0; i < depthPoint.length; i += frecP) {
      int sax = int (map(i, 0, depthPoint.length, 1, in.bufferSize() - 1));

      index = i;
      PVector currentPoint = depthPoint[i];

      if (currentPoint.z < profundidad && currentPoint.z > 80) {


        // draw the projected point
        if (userMap[index] == 0)
        {
          stroke(rojo, verde, azul);
        } else 
        {
          stroke(userClr[ (userMap[index] - 1) % userClr.length ]);  

          float deformador = (abs(in.right.get(sax))) * 2000;

          currentPoint.z = currentPoint.z  +  deformador;
          currentPoint.x = currentPoint.x  +  deformador;
          currentPoint.y = currentPoint.y  +  deformador;
          //currentPoint.z = currentPoint.z  *  deformador;     

          // println(deformador);


          //point(currentPoint.x, currentPoint.y, currentPoint.z);
        }
        //curveVertex(currentPoint.x, currentPoint.y, currentPoint.z);
        //currentPoint.mult(in.left.get(sax));
        //curveVertex(currentPoint.x, currentPoint.y, currentPoint.z  * (abs(in.right.get(sax))));
        point(currentPoint.x, currentPoint.y, currentPoint.z);
        //line(currentPoint.x, currentPoint.y, currentPoint.z, lastPoint.x, lastPoint.y, lastPoint.z);
        //lastPoint = currentPoint;
      }
    }
    //endShape();

    break;

  case 3:
    //beginShape(LINES);

    for (int i = 0; i < depthPoint.length; i += frecP) {
      int sax = int (map(i, 0, depthPoint.length, 1, in.bufferSize() - 1));

      index = i;
      PVector currentPoint = depthPoint[i];


      if (currentPoint.z < profundidad && currentPoint.z > 80) {


        // draw the projected point
        if (userMap[index] == 0)
        {
          stroke(rojo, verde, azul);
        } else 
        {
          stroke(userClr[ (userMap[index] - 1) % userClr.length ]);  

          float deformador = (abs(in.right.get(sax))) * 2000;

          currentPoint.z = currentPoint.z  +  deformador;
          currentPoint.x = currentPoint.x  +  deformador;
          currentPoint.y = currentPoint.y  +  deformador;
          //currentPoint.z = currentPoint.z  *  deformador;     

          // println(deformador);


          //point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
        }
        point(currentPoint.x, currentPoint.y, currentPoint.z);
        //currentPoint.mult(in.left.get(sax));
        //curveVertex(currentPoint.x, currentPoint.y, currentPoint.z  * (abs(in.right.get(sax))));
        //curveVertex(currentPoint.x, currentPoint.y, currentPoint.z);
        pushStyle();
        strokeWeight(2.0);
        strokeCap(ROUND);
        line(currentPoint.x, currentPoint.y, currentPoint.z, lastPoint.x, lastPoint.y, lastPoint.z);
        popStyle();
        lastPoint = currentPoint;
      }
    }
    // endShape();

    break;

  case 4:

    //beginShape(RECT);

    for (int i = 0; i < depthPoint.length; i += frecP) {
      int sax = int (map(i, 0, depthPoint.length, 1, in.bufferSize() - 1));

      index = i;
      PVector currentPoint = depthPoint[i];

      if (currentPoint.z < profundidad && currentPoint.z > 80) {
        // draw the projected point
        if (userMap[index] == 0)
        {
          stroke(rojo, verde, azul);
        } else 
        {
          stroke(userClr[ (userMap[index] - 1) % userClr.length ]);  

          float deformador = (abs(in.right.get(sax))) * 2000;

          currentPoint.z = currentPoint.z  +  deformador;
          currentPoint.x = currentPoint.x  +  deformador;
          currentPoint.y = currentPoint.y  +  deformador;
          //currentPoint.z = currentPoint.z  *  deformador;     

          // println(deformador);


          //point(realWorldPoint.x, realWorldPoint.y, realWorldPoint.z);
        }
        point(currentPoint.x, currentPoint.y, currentPoint.z);
        //currentPoint.mult(in.left.get(sax));
        //curveVertex(currentPoint.x, currentPoint.y, currentPoint.z  * (abs(in.right.get(sax))));
        //curveVertex(currentPoint.x, currentPoint.y, currentPoint.z);
        //line(currentPoint.x, currentPoint.y, currentPoint.z, lastPoint.x, lastPoint.y, lastPoint.z);
        triangle(currentPoint.x, currentPoint.y, lastPoint.x, lastPoint.y, thirtdPoint.x, thirtdPoint.y);
        lastPoint = currentPoint;
        thirtdPoint = lastPoint;
      }
    }
    //endShape();

    break;

  default:

    break;
  }


  if (foto) {

    if (fmr >= 5) {

      saveFrame("saxo-########.jpg");
      fmr = 0;
    }
    fmr++;

    //noFill();
    //stroke(50, 200, 20);
    //sphere(200);
  }

  popMatrix();
}

void keyPressed() {

  //controles de la nube de puntos

  // resolucion
  if (key == 'M') {
    frecP++;
  } 

  if (key == 'N') {
    if (frecP<=3) {
      frecP = 3;
    }

    frecP--;
  }

  //PROFUNDIDAD DEL RASTREO DE PUNTOS

  if (key == 'L') {
    profundidad =  profundidad+= 100;
  }
  if (key == 'K') {
    profundidad =  profundidad-= 100;
  }


  //controles de camara

  // zoom
  if (key == '1') {
    zoomF += 0.02f;
  } 

  if (key == '2') {

    zoomF -= 0.02f;
    if (zoomF < 0.01)  zoomF = 0.01;
  }


  switch(key) {

  case 'D':
    rotY += 0.1f;
    break;

  case 'A':
    rotY -= 0.1f;
    break;


  case 'W':
    rotX+=0.05;
    break;

  case 'S':
    rotX-=0.05;
    break;

  case 'R':
    rojo+=20;
    break;

  case 'r':
    rojo-=20;
    break;

  case 'G':
    verde+=20;
    break;

  case 'g':
    verde-=20;
    break;

  case 'B':
    azul+=20;
    break;

  case 'b':
    azul-=20;
    break;

  case 'F':
    foto =! foto;
    break;
  }

  if (key == '0') {
    estado = 0;
  }

  if (key == '3') {
    estado = 3;
  }

  if (key == '4') {
    estado = 4;
  }
}

void knobA(int theValue) {
  profundidad = theValue;
  println("a knob event. setting background to "+theValue);
}


void knobB(int theValue) {
  frecP = theValue;
  println("a knob event. setting background to "+theValue);
}

void knobR(int theValue) {
  rojo = theValue;
  println("a knob event. setting background to "+theValue);
}

void knobG(int theValue) {
  verde = theValue;
  println("a knob event. setting background to "+theValue);
}

void knobBl(int theValue) {
  azul = theValue;
  println("a knob event. setting background to "+theValue);
}

void knobRot(float theValue) {
  rotYau = theValue;
  println("a knob event. setting background to "+theValue);
}

// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  camara.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}
