void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(8,OUTPUT);
}
int beep=1;
void serialEvent(){
  while(Serial.available()){
    char now = Serial.read();
    if(now==' ')beep=0;
    if(now=='b')beep=1;
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  if(beep){
    tone(8,800,200);
    delay(1000);
  }
}
