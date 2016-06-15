#include <avr/wdt.h>
boolean WaitForEnd = true;
int timeFirstEnd;

// ------------------------------------------------------------------------------------------------
// Part for the discussion with Octave

// do the actuation asked bu the serial port communication

// note: all ''MUST AGREE'' definitions should be sent by serial during setup loop in further versions

// note: if microsecond used, will overflow after around 70 minutes after last boot (16MHz)
//       if milliseconds used, about 70 days

// time resolution for the control, in microseconds
// must agree with the definition on the control computer
// MUST AGREE DEFINITION
int timeReso = 5000;

// time since of end of setup loop, ie reference time of actuation beginning
// unsigned long ActuationStart;
// time of last change of actuation
unsigned long TimeLastUpdateSP;

// for waiting a bit for new buffer
unsigned long TimeLastBufferRequest;

// time after which new value should be choosen
unsigned long TimeNextRead;

// counter for sending feedback to the computer only each nAct new setpoint change
// ie each nAct time the setup point is changed
#define nAct 1;
int counterAct;

// pins for the control of the Moto shield
// should correspond with the jumpers on the board
int EnablePin = 13;   // pin for shield activation
int PWMPinA   = 11;   // pin for PWM control of out A
int PWMPinB   = 3 ;   // pin for PWM control of out B

// currentValueActuation
uint8_t cVA; 

// ------------------------------------------------------------------------------------------------
// Part for PID loop

// Tests the PID Loop to be used in the Paddle actuator
// done with:
//           - default AnalogRead at around 10 KHz
//           - modified AnalogWrite, reduced prescaler so that 4kHz

#include <PID_v1_custom_v1.h>

// pin on which the analog position is read
#define PIN_INPUT 4
// 'hand made' mean filter type
 int crrt_pos;
 int pre1_pos;
 int pre2_pos;
 int pre3_pos;

// define variables that will be called by pointer
double SetPoint;
double Input;
double Output;

// define the constants to use for PID loop
// note: dummy values for test in this sketch
// note: in a first time, maybe should use only Kd
double Kp = 10; // my advice: this is the main parameter to use in our case
double Ki = 3;  // my advice: this parameter can be used to reduce the time shift
double Kd = 0;  // my advice: do not used Kd, put Kd = 0
                // the frequency of the PID is too high, too much noise from
                // derivation

// define the time resolution at which the loop should run in microseconds
unsigned long TimeResoPID = 2000;

// define the PID instance
// reverse by default with the setup at UiO
PID PID_control(&Input,&Output,&SetPoint,Kp,Ki,Kd,DIRECT,TimeResoPID);
// input: position from sensor
// output: control on actuator
// setpoint: target value

// for debugging
unsigned long NbrLoop = 1;
unsigned long crrtMicros = 0;
unsigned long previousMicros = 0;
#define InitWS 100000

void setup() {

 
  // PART FOR PID LOOP ------------------------------------------------------------------------------
  // change the register value for Timer2 to increase the PWM frequency on pins 3 and 11
  cli();
  TCCR2B = TCCR2B & B11111000 | B00000010;
  sei();
  
  // start serial communication with computer
 Serial.begin(57600);
 delay(100);
 
 // PART FOR OCTAVE COMM AND MOTOSHIELD -------------------------------------------------------------
 // configure the pins for control of the MotoShield
 // Serial.println(F("Conf pins"));
 pinMode(EnablePin,OUTPUT);
 pinMode(PWMPinA  ,OUTPUT);
 pinMode(PWMPinB  ,OUTPUT);
 
 Serial.flush();
 delay(50);
 
 // asks if the computer is ready
 Serial.print("R");
 delay(50);
 char chr_answ = Serial.read();
 
 int inv;
 
 // if the computer is ready, update all values
 if (chr_answ=='Y'){
 // request and receive all the necessary for PID values
 Serial.print("P");
 delay(50);
 double kp10 = Serial.read();
 // Serial.print(kp10);
 Serial.print("Q");
 delay(50);
 double kpn = Serial.read();
 // Serial.print(kpn);
 Kp = pow(10,kp10-5)*kpn; 
 Serial.print(Kp);
 
 Serial.print("I");
 delay(50);
 int ki10 = Serial.read();
 Serial.print("J");
 delay(50);
 int kin = Serial.read();
 Ki = pow(10,ki10-5)*kin; 
 Serial.print(Ki);
 
 Serial.print("D");
 delay(50);
 int kd10 = Serial.read();
 Serial.print("E");
 delay(50);
 int kdn = Serial.read();
 Kd = pow(10,kd10-5)*kdn; 
 Serial.print(Kd);
 
 Serial.print("V");
 delay(50);
 inv = Serial.read();
 Serial.print(inv); // direct 0, reverse 1
 
 // define the PID instance
 // PID PID_control(&Input,&Output,&SetPoint,Kp,Ki,Kd,DIRECT,TimeResoPID);
 // input: position from sensor
 // output: control on actuator
 // setpoint: target value
 // modifies the PID parameters
 PID_control.SetTunings(Kp,Ki,Kd);
 // must be after automatic definition: see later in the code
 // PID_control.SetControllerDirection(inv);
 }
 else{
  delay(10000000); 
 }
 
 // ask the computer for the initial buffer fill
 Serial.print("SR1");
 delay(3500);
 
 // check the size of the rx buffer available
 int nBytesAvail = Serial.available();
 // Serial.println(F("Bytes available from rx:"));
 delay(20);
 // Serial.println(nBytesAvail);
 // Serial.println();
 
 // start the MotoShield
 digitalWrite(EnablePin,HIGH);
 
 // intialize time of last actuation
 TimeLastUpdateSP = micros();
 TimeLastBufferRequest = micros();
 
 // define how often feedback data will be sent to computer
 counterAct = nAct;
 
 // INITIALISATION OF VALUES FOR PID CONTROL ---------------------------------------------------
 
 // Initialize the variables
  Input = analogRead(PIN_INPUT);   // note: when nothing connected, will be random
  crrt_pos = analogRead(PIN_INPUT);
  pre1_pos = analogRead(PIN_INPUT);
  pre2_pos = analogRead(PIN_INPUT);
  pre3_pos = analogRead(PIN_INPUT);
  
 // this set point should be chosen to match last position before shut off, specially when
 // high power actuator. See comment below
 SetPoint = 512;
  
  
  // turn PID on
  PID_control.SetOutputLimits(-255,255); // 511 command levels max
  PID_control.SetMode(AUTOMATIC);
  PID_control.SetControllerDirection(inv);
 
 
 // print the char that indicates end of setup loop
 Serial.println("X");
 
 // NOTE: THEIR MAY BE A JUMP DUE TO INIT OF PID 
 // THIS WILL HAPPEN IF THE SET POSITION IS DIFFERENT FROM THE CURRENT (LAST) POSITION
 // IF USING HIGH POWER ACTUATORS WHERE JUMP IS DANGEROUS, MAKE SURE TO ALWAYS FINISH PROGRAM
 // EXECUTION AT THE POSITION THAT IS GIVEN AS INSTRUCTION AT THE BEGINNING OF NEXT 
 // EXPERIMENT.
 
 TimeNextRead = micros()+timeReso;
  
}

void loop() {
  
  // ------------------------------------------------------------------------------------------------
  // code for receiving setpoint from octave and updating it
  
  // if less than half receive buffer full, ask for new data trunk
  // this must fit with the size of the custom rx buffer
  // note that the board should wait a bit before being allowed to ask again for buffer, since otherwise will ask for buffer before the new one is sent
  // SIZE OF BUFFER MUST AGREE WITH CUSTOM BUFFER SIZE AND OCTAVE SIZE OF SENT BUFFER
  if ((Serial.available()<512)&&((micros()-TimeLastBufferRequest)>5*timeReso)){
    // request new buffer from the computer
    Serial.print('S');
    // set new time for last buffer request
    TimeLastBufferRequest = micros();
  }
  
  // if time time to change setpoint, do it
  // if((micros()-TimeLastUpdateSP)>(timeReso)){
  if((micros())>(TimeNextRead)){
    TimeNextRead = TimeNextRead + timeReso;
    // update the time for change of the requested value
    TimeLastUpdateSP = micros();
    // read the next value for set point
    if (Serial.available()){
    SetPoint = Serial.read();
    }
    else{
     SetPoint = 127;  // value of the set point by default if no input
     if (WaitForEnd){
     timeFirstEnd = millis();
     WaitForEnd = false;
     }
     // finished control: reboot
     if (millis()-timeFirstEnd>10000){
     wdt_enable(WDTO_15MS);
     while(1)
     {
     }
     }
    }
  
  // the set point was given as an 8 bits, but the position measure is 10 bits
  // 'convert' to 10 bits
  SetPoint = SetPoint*4; 
  
      // if time to send feedback, do it
    if (counterAct<1){
       // send some report data to the computer
       Serial.println();
       Serial.print('C');
       Serial.println(int(SetPoint));
       Serial.print('O');
       Serial.println(int(Output+255));
       Serial.print('V');
       Serial.println(int(Input));
       // Serial.println();
       // reset the counter
       counterAct = nAct;
    }
  
  // decrease the counter
  counterAct = counterAct - 1;
  }
  
  // ------------------------------------------------------------------------------------------------
  // code for PID control
  
  // for debugging, look at the frequency of some cycles
//  if ((NbrLoop > InitWS)&&(NbrLoop < InitWS+30)){
//    crrtMicros = micros();
//    Serial.println(crrtMicros);
//    Serial.println(crrtMicros-previousMicros);
//    Serial.println();
//    previousMicros = crrtMicros;
//  }
  
  // core operations, to do at each main loop
  // update the input, ie the position measured by the sensor
  // Input = analogRead(PIN_INPUT);
  pre3_pos = pre2_pos;
  pre2_pos = pre1_pos;
  pre1_pos = crrt_pos;
  crrt_pos = analogRead(PIN_INPUT);
  // Input = (crrt_pos+pre1_pos+2*pre2_pos+2*pre3_pos)/6;
  // default is:
//  Input = (pre2_pos+2*pre1_pos+3*crrt_pos)/6;
  Input = crrt_pos;
  
  // update the output, ie the control to the actuator
  // all is happening by reference
  PID_control.Compute();
  // write the updated output
  // note: should be adapted to the MotoShield way of functionning
  MotoShieldControl(Output);
  
  // counts how many main() loops have been performed
  NbrLoop = NbrLoop + 1;

  
}

void MotoShieldControl(int ControlValue){
  if (ControlValue<0){
       analogWrite(PWMPinA,-ControlValue);
       analogWrite(PWMPinB,0);
  }
  else{
       analogWrite(PWMPinA,0);
       analogWrite(PWMPinB,ControlValue);
  }
 
}

