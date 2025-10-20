void setup() {
  // put your setup code here, to run once:
  pinMode(11,OUTPUT);
}
int a=0;
void loop() {
  // put your main code here, to run repeatedly:
  analogWrite(11,a);
  a = (a+1)%255;
  delay(100);
}
