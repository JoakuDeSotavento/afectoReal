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

#include <Servo.h>
// declare both servos
Servo shoulder;
Servo elbow;
// setup the array of servo positions
int nextServo = 0;
int servoAngles[] = {0, 0};

void setup() {
  // attach servos to their pins
  shoulder.attach(9);
  elbow.attach(10);
  Serial.begin(9600);
}

void loop() {
  if (Serial.available()) {
    int servoAngle = Serial.read();
    servoAngles[nextServo] = servoAngle;
    nextServo++;
    if (nextServo > 1) {
      nextServo = 0;
    }
    shoulder.write(servoAngles[0]);
    elbow.write(servoAngles[1]);
  }
}
