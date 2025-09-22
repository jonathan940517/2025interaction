void setup() {
  // put your setup code here, to run once:
  pinMode(3,OUTPUT);
  pinMode(5,OUTPUT);
  pinMode(7,OUTPUT);
  pinMode(8,OUTPUT);

}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(3,HIGH);
  tone(8,523,200);
  delay(1000);
  digitalWrite(3,LOW);

  digitalWrite(5,HIGH);
  tone(8,659,200);
  delay(1000);
  digitalWrite(5,LOW);

  digitalWrite(7,HIGH);
  tone(8,784,200);
  delay(1000);
  digitalWrite(7,LOW);

}
