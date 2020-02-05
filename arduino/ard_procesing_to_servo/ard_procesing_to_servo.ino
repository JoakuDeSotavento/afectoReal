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

  Tomado del libro Making Things See de Greg Borestein

*/

#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
// called this way, it uses the default address 0x40
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
//#include <Servo.h>
// declare both servos
//Servo shoulder;
//Servo elbow;
// setup the array of servo positions

#define servoUno 0
#define servoDos 1
#define servoTres 2
#define servoCuatro 3

// Ajuste lo valores minimos y Maximos porque parecia que el maxio rompia el servo
#define USMIN  600 // This is the rounded 'minimum' microsecond length based on the minimum pulse of 150
#define USMAX  2200 // This is the rounded 'maximum' microsecond length based on the maximum pulse of 600
#define SERVO_FREQ 50 // Analog servos run at ~50 Hz updates

int nextServo = 0;
int servoAngles[] = {0, 0, 0, 0};

void setup() {
  // attach servos to their pins
  //shoulder.attach(9);
  //elbow.attach(10);
  Serial.begin(9600);
  Serial.print("iSpace ArtBot presenta: ");
  Serial.println("Virtual E(A)fecto Real y su espejo");

  pwm.begin();
  // In theory the internal oscillator is 25MHz but it really isn't
  // that precise. You can 'calibrate' by tweaking this number till
  // you get the frequency you're expecting!
  pwm.setOscillatorFrequency(27000000);  // The int.osc. is closer to 27MHz
  pwm.setPWMFreq(SERVO_FREQ);  // Analog servos run at ~50 Hz updates

  delay(10);
}

void loop() {
  if (Serial.available()) {
    int servoAngle = Serial.read();
    servoAngles[nextServo] = servoAngle;
    nextServo++;
    if (nextServo > 3) {
      nextServo = 0;
    }
    servoMove(servoUno, servoAngles[0]);
    servoMove(servoDos, servoAngles[1]);
    servoMove(servoTres, servoAngles[2]);
    servoMove(servoCuatro, servoAngles[3]);
  }
}

void servoMove (int _servoNum, int _angle) {
  int pulseLength = map(_angle, 0, 180, USMIN, USMAX);
  pwm.writeMicroseconds(_servoNum, pulseLength);
}
