void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(8,OUTPUT);
  tone(8,784,100);
  delay(100);
  tone(8,523,100);
  delay(100);
}
void serialEvent(){
  while(Serial.avaliable()){
    char now = Serial.read();
    if(now=='R'){
      tone(8,784,100);
      delay(100);
      tone(8,523,100);
      delay(100);
    }else{
      tone(8,523,100);
      delay(100);
      tone(8,784,100);
      delay(100);
    }
  }
}



void loop() {
  // put your main code here, to run repeatedly:
  
}
