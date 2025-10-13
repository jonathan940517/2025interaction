void setup() {
  // put your setup code here, to run once:
  pinMode(8,OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  tone(8,780,60);
  delay(333);
  tone(8,320,60);
  delay(333);
}
