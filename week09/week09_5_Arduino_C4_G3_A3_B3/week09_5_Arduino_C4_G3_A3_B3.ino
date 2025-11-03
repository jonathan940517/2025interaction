//week09_5_Arduino_C4_G3_A3_B3
#define C4 262
#define G3 196
#define A3 220
#define B3 247

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(8,OUTPUT);
  tone(8,C4,100);
  delay(100);
  tone(8,G3,100);
  delay(100);
}
void serialEvent(){
  while(Serial.available()){
    char now = Serial.read();
    if(now=='R'){
    	tone(8,C4,100);
      	delay(100);
    }else if(now=='L'){
    	tone(8,G3,100);
      	delay(100);
    }else if(now=='U'){
    	tone(8,A3,100);
      	delay(100);
    }else if(now=='D'){
    	tone(8,B3,100);
      	delay(100);
    }
  }
}



void loop() {
  // put your main code here, to run repeatedly:
  
}