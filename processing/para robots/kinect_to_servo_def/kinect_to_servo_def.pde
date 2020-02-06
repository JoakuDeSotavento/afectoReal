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

int segmentLength;

PVector shoulder;
PVector elbow;
PVector target;

void setup() {
  size(1200, 800);

  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);

  segmentLength = 400;

  shoulder = new PVector();
  elbow = new PVector();
  target = new PVector();

  shoulder.x = 0;
  shoulder.y = height/2;

  println(Serial.list());
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 9600);
}

void draw() {
  background(255);
  kinect.update();

  image(kinect.depthImage(), 300, 100);

  IntVector userList = new IntVector();

  kinect.getUsers(userList);

  if (userList.size() > 0) {
    int userId = userList.get(0);

    if ( kinect.isTrackingSkeleton(userId)) {
      PVector head = new PVector();
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD,
        head);
      kinect.convertRealWorldToProjective(head, head);

      head.y = head.y + 100;
      head.x = head.x + 300;
      fill(0, 255, 0);
      ellipse(head.x, head.y, 20, 20);

      target.x = head.x;
      target.y = head.y;

      // begin complex inverse kinematics math
      PVector difference = PVector.sub(target, shoulder);
      float distance = difference.mag();

      // sides of the main triangle
      float a = segmentLength;
      float b = segmentLength;
      float c = min(distance, segmentLength + segmentLength);

      // angles of the main triangle
      float B = acos((a*a + c*c - b*b)/(2*a*c));
      float C = acos((a*a + b*b - c*c)/(2*a*b));

      // C is also the elbow angle
      float D = atan2(difference.y, difference.x);

      // angle of the shoulder joint
      float E = D + B + C - PI; // Pi is 180 degrees in rad
      float F = D + B;

      // use SOHCAHTOA to find rise and run from angles
      elbow.x = (cos(E) * segmentLength) + shoulder.x;
      elbow.y = (sin(E) * segmentLength) + shoulder.y;

      target.x = (cos(F) * segmentLength) + elbow.x;
      target.y = (sin(F) * segmentLength) + elbow.y;

      // adjust angles based on orientation of hardware
      float shoulderAngle = constrain(degrees(PI/2 - E), 0, 180);
      float elbowAngle = degrees(PI - C);

      fill(255, 0, 0);
      textSize(20);
      text("shoulder: " + int(shoulderAngle) +
        "\nelbow: " + int(elbowAngle), 20, 20);
      //

      byte out[] = new byte[2];
      out[0] = byte(int(shoulderAngle));
      out[1] = byte(int(elbowAngle));
      port.write(out);

      fill(255, 0, 0);
      ellipse(shoulder.x, shoulder.y, 10, 10);
      ellipse(elbow.x, elbow.y, 8, 8);
      ellipse(target.x, target.y, 6, 6);
      stroke(0, 255, 0);
      strokeWeight(5);
      line(shoulder.x, shoulder.y, elbow.x, elbow.y);
      line(elbow.x, elbow.y, target.x, target.y);
    }
  }
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
