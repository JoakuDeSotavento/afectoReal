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

*/


import SimpleOpenNI.*;
SimpleOpenNI kinect;

import processing.serial.*;
Serial port;

void setup() {

  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);

  println(Serial.list());
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 9600);
}

void draw() {
  kinect.update();
  PImage depth = kinect.depthImage();
  image(depth, 0, 0);

  IntVector userList = new IntVector();
  kinect.getUsers(userList);
  if (userList.size() > 0) {
    int userId = userList.get(0);
    if ( kinect.isTrackingSkeleton(userId)) {

      ///////////////////////////////////////////////////////////
      // This function obtains the angle between three joints
      float myElbow = giveMeAngle(userId, SimpleOpenNI.SKEL_RIGHT_HAND, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
      float myShoulder = giveMeAngle(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_HIP);
      float myknee = giveMeAngle(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_HIP);
      float myHip = giveMeAngle(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_SHOULDER);


      //////////////////////////////////////////////////////////////
      byte out[] = new byte[4];
      out[0] = byte(int(myknee));
      out[1] = byte(int(myHip));
      out[2] = byte(int(myShoulder));
      out[3] = byte(int(myElbow));
      port.write(out);
      /////////////////////////////////////////////////////////////
      // show the angles on the screen for debugging

      fill(255, 0, 0);
      scale(3);
      text("my knee: " + int(myknee) + "\n" +
          " my hip: " + int(myHip) + "\n" +
          " my shoulder: " + int(myShoulder) + "\n" +
          " my elbow: " + int(myElbow), 20, 20);
    }
  }
}

// you need three points
float giveMeAngle(int _user, int _one, int _two, int _three){
// getting the Vector 3D of three axis
  PVector firstPoint = new PVector();
  kinect.getJointPositionSkeleton(_user, _one, firstPoint);
  PVector secondPoint = new PVector();
  kinect.getJointPositionSkeleton(_user, _two, secondPoint);
  PVector thirdPoint = new PVector();
  kinect.getJointPositionSkeleton(_user, _three, thirdPoint);
// diminiss 3D vectors to random2D
  PVector firstPoint2D = new PVector(firstPoint.x, firstPoint.y);
  PVector secondPoint2D = new PVector(secondPoint.x, secondPoint.y);
  PVector thirdPoint2D = new PVector(thirdPoint.x, thirdPoint.y);
// calculate the axes against which we want to measure our angles
  PVector axis = PVector.sub(secondPoint, thirdPoint);
// calculate the angles between our joints
// first point, second point and the orientation
  float theAngle = angleOf(firstPoint2D, secondPoint2D, axis);
  return theAngle;
}

float angleOf(PVector one, PVector two, PVector axis) {
  PVector limb = PVector.sub(two, one);
  return degrees(PVector.angleBetween(limb, axis));
}


// -----------------------------------------------------------------
// SimpleOpenNI user events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  kinect.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}
