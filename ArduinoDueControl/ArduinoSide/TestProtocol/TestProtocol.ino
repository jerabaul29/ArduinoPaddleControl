#include <Arduino.h>

// the most significant bit of a byte
#define NBIT 7

// the default value to output if bug; take 2^(NBR_BITS_DATA_INT-1) if zero position paddle
// if 12 bits resolution: 2^(11) = 2048
#define DEFAULT_VALUE 2048

// the number of bits of the int sent by serial
// not used for simple protocol (only one data sent, no more for example to distinguish several sensors
// or modes). If used must agree with the Python definition
//#define NBR_BITS_DATA_INT 10

// debug mode
#define DEBUG_MODE true

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// NOTES:

// check how fast ADC
// check how fast PWM (frequency and multiplicator)
// check resolution PWM

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void setup() {

  // open serial port on native USB; baud rate must be the same as in Python
  Serial.begin(115200);

  // change the resolution to 12 bits and read A0 (12 bits ADC on Arduino Due)
  analogReadResolution(12);

}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void loop() {

  assemble_bytes_protocol();

}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// function for decoding protocol
// tries to read on Serial port each time called
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int assemble_bytes_protocol(){
  // assemble byte1 and byte2 according to the protocol to
  // compute an int

  // the bytes that will be read
  byte byte1;
  byte byte2;

  // initialize the assembled value to return -----------------------------------------------------------------
  int value_assembled = 0;

  // check that enough bytes available and that it is well a packet -------------------------------------------
  // read if 2 bytes or more available
  if(Serial.available()>1){

    // read first byte; Wait to read second, so that if error and not start of a packet
    // next time assemble_bytes_protocol is called it will be the beginning of a packet
    byte1 = Serial.read();

    // if not the start of a packet, stop here
    // next call will hopefully start at the beginning of a packet!
    if (bitRead(byte1,NBIT)==0){
      Serial.println(F("Error: not start of a packet!"));

      // try to read next
      Serial.println(F("Try to read next"));

      int result_next = assemble_bytes_protocol();
      return(result_next);
    }

    // if it was the start of a packet, read byte 2
    byte2 = Serial.read();
    // and check it is the continuation of a packet; otherwise, break
    if (bitRead(byte2,NBIT)==1){
      Serial.println(F("Error: not continuation of a packet!"));

      // try to read next
      Serial.println(F("Try to read next"));

      int result_next = assemble_bytes_protocol();
      return(result_next);
    }

    // now we know that everything is OK! ---------------------------------------------------------------------
    // do the recombination -----------------------------------------------------------------------------------

    // second byte is low weight bits
    value_assembled = int(byte2);

    // first part is high weight bits
    // note: the following approach only works for simple protocol with only start stop and messsage
    int high_value = int(byte1) - 128;
    value_assembled += high_value*128;

    // for debugging
    #if DEBUG_MODE
      Serial.print("Protocol deciphered: ");
      Serial.println(value_assembled);
    #endif

    // final result
    return(value_assembled);

  }

  // if no 2 bytes or more to read, say it and return DEFAULT_VALUE!
  else{
    // comment when debugging
    //SerialUSB.println(F("Error: empty SerialUSB buffer!"));
    return(DEFAULT_VALUE);
  }

}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
