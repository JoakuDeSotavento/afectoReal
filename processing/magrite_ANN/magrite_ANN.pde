/*
 `..`         ```
 /yyys.     ./osyss`                                                                                                     .ooooo           :oooo+                           :oooo+
 /syys.   `+yyyyyyy`                                                                                                     -yyyyy           /yyyys                           /yyyyo
 .-::-`   +yyyyyyso`     `.---.``        ``.---.`          `.---.`         `.----.`                `.---.``         `.----yyyyy.``        /yyyys`---.`        ``.---.`     /yyyys``
 yyyyy-   syyyyy+     `:osyyyyyyo/`    ./syyyyyyyo:`    `:oyyyyyyyo:`    .+syyyyyys+.           `:oyyyyyyys/`     -oyyyys-yyyyyyy:        /yyyys-yyyys+.    ./syyyyyys+-   /yyyyyyy.
 yyyyy-   :yyyyyy-   `oyyyyyyyyyyys-  -yyyyyyyyyyyyo`  .syyyyyyyyyyyo`  /yyyyyoosyyyy/         .syyyyyyyyyyys.   :yyyyyys-yyyyyyy:.:::::: /yyyys-yyyyyyy:  :yyyyyyyyyyyy+  /yyyyyyy.
 yyyyy-    /yyyyyy-  /yyyys-.-oyyyys `yyyyy+-.:yyyyy:  oyyyys-.-/////. -yyyyy.//+yyyyy.        oyyyys-.-syyyyo   syyyyo---yyyyy//./yyyyyy /yyyys`../yyyyy.`yyyyy+..:yyyyy: /yyyyy//`
 yyyyy-  ``.syyyyy+  oyyyy+` `/yyyyy``yyyyy:   oyyyy+  syyyy+` `:////: :yyyyy`/+++++++.        syyyy+`  :yyyys   yyyyy:  .yyyyy:``.:::::: :yyyyy.  -yyyyy-.yyyyy-  `syyyy/ :yyyyy-`
 yyyyy-  sssyyyyyy:  oyyyy//osyyyyy/  +yyyyyoo-+yyyy+  :yyyyysosyyyyy- `syyyyo::+-             :yyyyyso/:yyyys   yyyyy-   +yyyyys/        `syyyysooyyyyyo  oyyyyyoosyyyys. `syyyyys-
 yyyyy-  yyyyyyys:   oyyyy//yyyyys:   `/syyyyy:+yyyy+   -oyyyyyyyyyo-   `+yyyyyyyyo`            :syyyyy+:yyyys   yyyyy-   `/syyyy/         `+yyyyyyyyys/`  `/syyyyyyyyy+.   `+yyyyy-
 /++++.  +oooo+-`    oyyyy/:oo+/.`      `-/+oo-:++++:    `.:++o++:.       `-/+oo+/-`             `.:++o/-++++/   /++++.     `-/+o:           `-/+oo+/-`      `-/+oo+/:`       .:/+o.
 ``        oyyyy/
 oyyyy/
 `....`

 Colectivo artistito conformado por: Sylvia Molina & Joaku De Sotavento
 Contacto:
 http://www.sylviamolina.net/
 https://arterobotico.com/

 ///////////////////////////////////////////////////////
 Programa: Este programa esta hecho para entrenar Wekinator con la nube de puntos
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

// declaraciones de la comunicacion OscP5
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation, myRemoteArduino, myRemoteReso, remoteWekiAudio;

// declataciones de la interfaz gráfica
import controlP5.*;
ControlP5 cp5;
Knob depth;
Knob depth2;
Knob density;
Knob myKnobR;
Knob myKnobG;
Knob myKnobBl;
Knob rotation;

// declaraciones de la kinect
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
int profundidad2 = 80;

// colores del fondo
int rojo = 50;
int verde = 100;
int azul = 150;

// estado unicial de la visualizacion
int estado = 0;


void setup() {
  // inicializaciiones basicas
  //fullScreen(P3D);
  size(1024, 768, P3D);
  frameRate(60);
  // estos son las delcaraciones de la GUI
  cp5 = new ControlP5(this);
  depth = cp5.addKnob("depth")
    .setRange(profundidad2 + 50, 5000)
    .setValue(3000)
    .setPosition(50, 50)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;

  cp5 = new ControlP5(this);
  depth2 = cp5.addKnob("depth2")
    .setRange(80, profundidad - 50)
    .setValue(80)
    .setPosition(130, 50)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;

  density = cp5.addKnob("density")
    .setRange(1, 20)
    .setValue(4)
    .setPosition(50, 150)
    .setRadius(30)
    .setNumberOfTickMarks(20)
    .setColorForeground(color(255))
    .setColorBackground(color(0, 160, 100))
    .setColorActive(color(255, 255, 0))
    .setDragDirection(Knob.VERTICAL)
    ;

  myKnobR = cp5.addKnob("myKnobR")
    .setRange(0, 250)
    .setValue(random(0, 50))
    .setPosition(50, 250)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;

  myKnobG = cp5.addKnob("myKnobG")
    .setRange(0, 250)
    .setValue(random(0, 100))
    .setPosition(50, 350)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;

  myKnobBl = cp5.addKnob("myKnobBl")
    .setRange(0, 250)
    .setValue(random(0, 100))
    .setPosition(50, 450)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;

  rotation = cp5.addKnob("rotation")
    .setRange(-0.3, 0.3)
    .setValue(0)
    .setPosition(width - 100, 50)
    .setRadius(30)
    .setDragDirection(Knob.VERTICAL)
    ;
  textFont(createFont("Arial", 12));

  // inicializaciones de la kinect
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
  stroke(255, 255, 255);
  smooth();
  //perspective(radians(45), float(width)/float(height), 10, 150000);
}

void draw() {
    // update de los datos de la kinect
  camara.update();
  background(0);
  // ajuste de perspectiva de la kinect
  pushMatrix();
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY+=rotYau);
  scale(zoomF);

  PVector[] depthPoint = camara.depthMapRealWorld();
  int[]     userMap = camara.userMap();
  PVector   lastPoint = depthPoint[0];
  PVector   thirtdPoint = depthPoint[1];
  int       index;


  //PVector realWorldPoint;
  translate(0, 0, -1000);  // set the rotation center of the scene 1000 infront of the camera
  pushMatrix();
  translate(-50, 380, 1000);  // set the rotation center of the scene 1000 infront of the camera
  rotateX(radians(180));
  fill(255, 0, 255);
  textSize(28);
  text("Cantidad de puntos de la nube " + depthPoint.length, 0, 0);
  popMatrix();
  // diferentes visualizaciones de la nubbe de puntos

  ArrayList<PVector> cloudSlice = new ArrayList<PVector>();

  switch(estado)
  {
  case 0:

  for (int i = 0; i < depthPoint.length; i += frecP){
    PVector currentPoint = depthPoint[i];
    //if (currentPoint.z < profundidad && currentPoint.z > profundidad2) {
      cloudSlice.add(currentPoint);
      stroke(rojo, verde, azul);
      point(currentPoint.x, currentPoint.y, currentPoint.z);
    //}
  }
  pushMatrix();
  translate(-50, 350, 1000);  // set the rotation center of the scene 1000 infront of the camera
  rotateX(radians(180));
  fill(255, 0, 255);
  textSize(28);
  text("Puntos a enviar " + cloudSlice.size(), 0, 0);
  popMatrix();
  break;

  case 1:

  for (int i = 0; i < depthPoint.length; i += frecP){
    PVector currentPoint = depthPoint[i];
    if (currentPoint.z < profundidad && currentPoint.z > profundidad2) {
      cloudSlice.add(currentPoint);
      stroke(rojo, verde, azul);
      point(currentPoint.x, currentPoint.y, currentPoint.z);
    }
  }
  pushMatrix();
  translate(-50, 350, 1000);  // set the rotation center of the scene 1000 infront of the camera
  rotateX(radians(180));
  fill(255, 0, 255);
  textSize(28);
  text("Puntos a enviar " + cloudSlice.size(), 0, 0);
  popMatrix();
  break;

  default:

  break;
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
  if (key == 'z') {
    zoomF += 0.02f;
  }
  if (key == 'Z') {
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

  }

  if (key == '0') {
    estado = 0;
  }

  if (key == '1') {
    estado = 1;
  }

  if (key == '2') {
    estado = 2;
  }

  if (key == '3') {
    estado = 3;
  }
}

void depth(int theValue) {
  profundidad = theValue;
  println("a knob event. setting background to "+theValue);
}

void depth2(int theValue) {
  profundidad2 = theValue;
  println("a knob event. setting background to "+theValue);
}

void density(int theValue) {
  frecP = theValue;
  println("a knob event. setting background to "+theValue);
}

void myKnobR(int theValue) {
  rojo = theValue;
  println("a knob event. setting background to "+theValue);
}

void myKnobG(int theValue) {
  verde = theValue;
  println("a knob event. setting background to "+theValue);
}

void myKnobBl(int theValue) {
  azul = theValue;
  println("a knob event. setting background to "+theValue);
}

void rotation(float theValue) {
  rotYau = theValue;
  println("a knob event. setting background to "+theValue);
}
