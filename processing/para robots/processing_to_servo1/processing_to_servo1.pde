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


import processing.serial.*;
Serial port;

byte out[] = {0, 0, 0, 0};

PImage logo;
// port.write(out);


void setup() {
  println(Serial.list());
  String portName = Serial.list()[0];
  port = new Serial(this, portName, 9600);
  port.write(out);
  
  logo = loadImage("ispace-art.jpg");
  size(800, 174);
}
void draw() {
  image(logo, 0, 0);
}

void keyPressed() {

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
