//week02_3_myMusic_serial
#define NOTE_C5 523
#define NOTE_Cu5 554
#define NOTE_D5 587
#define NOTE_Du5 622
#define NOTE_E5 659
#define NOTE_F5 698
#define NOTE_Fu5 740
#define NOTE_G5 784
#define NOTE_Gu5 831
#define NOTE_A5 880
#define NOTE_Au5 932
#define NOTE_B5 988
#define NOTE_C6 1047
#define NOTE_D6 1175

#define BUTTON 2
#define BUZZER 8

int melody[] = {
  NOTE_G5, NOTE_G5,NOTE_A5, NOTE_G5,NOTE_C6, NOTE_B5, NOTE_G5,NOTE_G5, NOTE_A5,NOTE_G5, NOTE_D6,NOTE_C6,NOTE_G5,NOTE_G5,1568,1319,NOTE_C6,NOTE_B5,NOTE_A5,1397,1397,1319,NOTE_C6,NOTE_D6,NOTE_C6
};

int noteDurations[] = {
  300, 100, 400, 400, 400, 800, 300, 100, 400, 400, 400, 800, 300, 100, 400, 400, 400, 400, 800, 300, 100, 400 ,400 ,400, 1600
};

int pin;
int ledArrayHigh;
int ledArrayLow;
boolean mode = false;
boolean buttonPressed = false;

void setup()
{
  delay(1000);
  Serial.begin(9600);
  pinMode(BUTTON, INPUT_PULLUP);
  for (pin = 3; pin < 14; pin++) { 
    pinMode(pin, OUTPUT);
  }

  for (int thisNote = 0; thisNote <25 ; thisNote++) {
    int noteDuration = noteDurations[thisNote];
    tone(BUZZER, melody[thisNote], noteDuration);
    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);
    noTone(BUZZER);
  }
}

void mymusic()
{
  delay(1000);
  
  pinMode(BUTTON, INPUT_PULLUP);
  for (pin = 3; pin < 14; pin++) { 
    pinMode(pin, OUTPUT);
  }

  for (int thisNote = 0; thisNote <25 ; thisNote++) {
    int noteDuration = noteDurations[thisNote];
    tone(BUZZER, melody[thisNote], noteDuration);
    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);
    noTone(BUZZER);
  }
}
void serialEvent(){
  while(Serial.available()){
    Serial.read();
    mymusic();
  }
}

void loop()
{
  for (pin = 0; pin < 5; pin++) {
    if (digitalRead(BUTTON) == LOW &&
        buttonPressed == false) {
      mymusic();
      buttonPressed = true;
      mode = !mode;
      pin = 0;
      if (mode == false) {
        tone(BUZZER, NOTE_C5, 100);
        delay(100);
        tone(BUZZER, NOTE_G5, 100);
        delay(100);
        noTone(BUZZER);
      }
      else if (mode == true) {
        tone(BUZZER, NOTE_G5, 100);
        delay(100);
        tone(BUZZER, NOTE_C5, 100);
        delay(100);
        noTone(BUZZER);
      }
    }

    if (mode == false) {
      ledArrayHigh = 13 - pin;
      ledArrayLow = 7 - pin;
    }
    else if (mode == true) {
      ledArrayHigh = 9 + pin;
      ledArrayLow = 3 + pin;
    }
    digitalWrite(ledArrayHigh, HIGH);
    digitalWrite(ledArrayLow, HIGH);
    delay(100);
    digitalWrite(ledArrayHigh, LOW);
    digitalWrite(ledArrayLow, LOW);
    if (pin == 4) delay(100);
  }

  if (buttonPressed == true) {
    buttonPressed = false;
  }
}