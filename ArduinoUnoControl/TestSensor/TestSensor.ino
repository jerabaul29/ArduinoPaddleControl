// do the actuation asked bu the serial port communication

// note: all ''MUST AGREE'' definitions should be sent by serial during setup loop in further versions

// note: if microsecond used, will overflow after around 70 minutes after last boot (16MHz)
//       if milliseconds used, about 70 days

// time resolution for the control, in microseconds
// must agree with the definition on the control computer
int timeReso = 5000;

// time since of end of setup loop, ie reference time of actuation beginning
// unsigned long ActuationStart;
// time of last change of actuation
unsigned long TimeLastActuation;

// for waiting a bit for new buffer
unsigned long TimeLastBufferRequest;

// counter for sending feedback to the computer only each nAct new actuation
#define nAct 2;
int counterAct;

// pins for the control of the Moto shield
// should correspond with the jumpers on the board
int EnablePin = 13;   // pin for shield activation
int PWMPinA   = 11;   // pin for PWM control of out A
int PWMPinB   = 3 ;   // pin for PWM control of out B

// read analog position
#define pinAnalogPos 4
int ValueP;

// currentValueActuation
uint8_t cVA; 

void setup() {
 
 Serial.begin(57600);
 delay(100);
 
 // configure the pins
 Serial.println(F("Conf pins"));
 pinMode(EnablePin,OUTPUT);
 pinMode(PWMPinA  ,OUTPUT);
 pinMode(PWMPinB  ,OUTPUT);
 
 Serial.print("SR1");
 delay(3500);
 
 // check the size of the rx buffer available
 int nBytesAvail = Serial.available();
 Serial.println(F("Bytes available from rx:"));
 delay(20);
 Serial.println(nBytesAvail);
 Serial.println();
 
 // intialize the time for the control
 // ActuationStart = millis();
 
 // start
 digitalWrite(EnablePin,HIGH);
 SetControl(0,0);
 
 // intialize time of last actuation
 TimeLastActuation = micros();
 TimeLastBufferRequest = micros();
 
 counterAct = nAct;
}

void loop() {
  
  // if less than half receive buffer full, ask for new data trunk
  // this must fit with the size of the custom rx buffer
  // note that the board should wait a bit before being allowed to ask again for buffer, since otherwise will ask for buffer before the new one is sent
  if ((Serial.available()<512)&&((micros()-TimeLastBufferRequest)>5*timeReso)){
    Serial.print('S');
    delay(5);
    TimeLastBufferRequest = micros();
  }
  
  // if time time to change output on the PWM, do it
  if((micros()-TimeLastActuation)>(timeReso)){
    TimeLastActuation = micros();
    if (Serial.available()){
    cVA = Serial.read();
    }
    else{
     cVA = 127; 
    }
    if (cVA<128){
     SetControl(255-2*cVA,0);
    }
    else{
     SetControl(0,2*cVA-256); 
    }
    
    if (counterAct<1){
       // send some report data to the computer
        // sends back by serial buffer data for checking
  ValueP = analogRead(pinAnalogPos);
  delay(1);
       Serial.println(ValueP);
       delay(1);
       counterAct = nAct;
    }
  
  counterAct = counterAct - 1;
  
  }
  
}

void SetControl(int VlA, int VlB){
 
 // set controls on PWM for A and B
 // PWM is between 0 and 255
 // cycle duty     0     100  
 // each pin controls one output
 // 0 255 is 0V and 12V ie +12V (or any other value given as input voltage to the board)
 // 255 0 is 12V and 0V ie -12V ( ''                                                   )
 analogWrite(PWMPinA,VlA);
 analogWrite(PWMPinB,VlB);
  
}

