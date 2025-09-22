void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(8,OUTPUT);
}

void serialEvent(){
  while(Serial.available()){
    Serial.read();
    tone(8,800,200);
  }
}

void loop() {
  // put your main code here, to run repeatedly:

}
