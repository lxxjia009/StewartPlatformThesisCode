//===============================  Include libraries  =======================================
#include <Servo.h>                       // Include servo library
//===========================================================================================

//=======================  Inititialisations & Declarations  ================================
Servo servo1;                            // Declare first servo signal
Servo servo2;                            // Declare second servo signal
Servo servo3;                            // Declare third servo signal
Servo servo4;                            // Declare fourth servo signal
Servo servo5;                            // Declare fifth servo signal
Servo servo6;                            // Declare sixth servo signal

int ibyte;                               // stores variable for input byte processing
unsigned long serData;                   // stores current serial data
int mpulse[6] = {1500, 1500, 1500, 1500, 1500, 1500}; //init array
int mnum=0;                              // stores the motor number

float msp_degreeLow = 800/66;            // Init time per degree Lower limit
float msp_degreeHi = 650/72;             // Init time per degree Upper limit
//===========================================================================================


//============================== Setup & Main loop  =========================================
void setup()
{
  servo1.attach(3);                   // Attach first servo signal->pin 3
  servo2.attach(5);                   // Attach second servo signal->pin 5
  servo3.attach(6);                   // Attach third servo signal->pin 6
  servo4.attach(9);                   // Attach fourth servo signal->pin 9
  servo5.attach(10);                  // Attach fifth servo signal->pin 10
  servo6.attach(11);                  // Attach sixth servo signal->pin 11
  Serial.begin(115200);               // Establish serial comms
}

//Main loop
void loop()
{
  if(Serial.available()>0){               // While there's something available
    mnum=getSer();                        // Retrieve serial data and store it as motor number
    mpulse[mnum-1]=getSer();              // Refer to array motor number, and update pulse
  }

  servo1.writeMicroseconds(mpulse[0]);
  servo2.writeMicroseconds(mpulse[1]);
  servo3.writeMicroseconds(mpulse[2]);
  servo4.writeMicroseconds(mpulse[3]);
  servo5.writeMicroseconds(mpulse[4]);
  servo6.writeMicroseconds(mpulse[5]);
  delay(1.5);

}
//===========================================================================================


//Reads and gathers the data, separated by the '/' sign
//===========================================================================================
long getSer()                                           // Declare functon type and name
{                                                       // Uses a long type because of extended bits. (4bytes)
  serData=0;                                            // Init and store data to zero
  while (ibyte != '/')                                  // While number not ended
  {
    ibyte = Serial.read();                              // Store the data in 'ibyte' 
    if (ibyte > 0 && ibyte != '/')                      // while 'ibyte' not empty or end
    {
      serData = serData*10 + ibyte -'0';                // Interprets ascii data as a number
    }                                                   // '0' is number 48 ascii character
  }
  ibyte = 0;                                            // Reset ibyte to zero
  return serData;                                     
}
//===========================================================================================
//================================  CODE END  ===============================================
/* *NOTE:
 * 'int' data types in arduino use 2 bytes
 * On the Arduino Uno (and other ATmega based boards) an int stores a 16-bit (2-byte) value.
 * This yields a range of -32,768 to 32,767 (minimum value of -2^15 and a maximum value of 
 * (2^15) - 1). On the Arduino Due and SAMD based boards (like MKR1000 and Zero), an int 
 * stores a 32-bit (4-byte) value. This yields a range of -2,147,483,648 to 2,147,483,647
 * (minimum value of -2^31 and a maximum value of (2^31) - 1) */
