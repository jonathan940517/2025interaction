void setup() {
  // put your setup code here, to run once:
   pinMode(2,INPUT_PULLUP);
   for(int i=3;i<=13;i++){
    pinMode(i,OUTPUT);
   }
}
int now=3;
void loop() {
  // put your main code here, to run repeatedly:
  if(digitalRead(2)==LOW){
    now = now+1;
    if(now>13)now=3;
    for(int i=3;i<=13;i++){
      digitalWrite(i,LOW);
    }
  }
  digitalWrite(now,HIGH);
  delay(500);
}
