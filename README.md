# PaddleControlSystem

This is the control systems I developed as a side project for building a computer controlled wave paddle. The principle of the control system is described on my webpage: <http://folk.uio.no/jeanra/Microelectronics/PIDController.html>. The key idea is to use a computer to send a pre-determined set point to an Arduino board that is connected to a sensor and a H-bridge and acts as the PID controller. The same code could be used with relevant sensor and actuator to build any computer controlled PID controller.

## Note on Hardware

The code is written for Arduino Uno or Due (depending on version). The sensors used are LVDTs. The H-bridge used is a Moto Shields from Robot Power, either Mega Moto Plus <http://www.robotpower.com/products/MegaMotoPlus_info.html> or Mega Moto GT <http://www.robotpower.com/products/MegaMotoGT_info.html>. The pins connections are indicated in the arduino codes and can be adapted to any other sensor and H-bridge.

## ArduinoUnoControl

This is an old version of the control built using an Arduino Uno. The code is contained in the **/ArduinoUnoControl/Full_Paddle_Software/Actuation** folder.

- The **Actuation.ino** file should be uploaded on an Arduino Uno board, with a modified Arduino Uno core (extended RX buffer), for example: <https://github.com/jerabaul29/ArduinoModifySerialBuffer>.
- The **Actuation.m** file should be run through Octave, with the instrument-control library installed.
- Technical characteristics: set point frequency from the computer 200Hz, PID loop frequency 500Hz, 8 bits set point accuracy. An 8 bit accuracy is used while a 10 bit ADC conversion is available. This is because the set point is transmitted from the computer to the Arduino Uno as one byte, i.e. 8 bits. Therefore, this is not optimal (with some more work, ie using a binary protocol similar to the one used in the Due control version, a 10 bits controller could be implemented on Arduino Uno).
- Comments: while the control system works well, the code is not well written. It is only provided as possible example for the reader, and the Due version should be preferred.

## ArduinoDueControl

This is a newer and cleaner control built using an Arduino Due (but could be adapted to any other Arduino).

- The **/ArduinoDueControl/ArduinoSide/Paddle/** folder contains the **Paddle.ino** code that should be uploaded on the Due board. A modified Due core and variant (extended RX buffer, higher PWM frequency) should be used, for example: <https://github.com/jerabaul29/ArduinoDue>.
- The **/ArduinoDueControl/ComputerSide/** folder contains the Python code to be run on the computer. The **CommunicationSerialBinary.py** file contains the python side of the binary protocol used to communicate from the computer to the Arduino, and a class used to perform the PID control. The **ScriptActuation.py** is the script to be run on the computer to perform controlled actuation.
- Technical characteristics: set point frequency from the computer 500 Hz (could be increased in the kHz range), PID loop frequency 2kHz (could be increased at least up to the 10kHz range), 12 bits set point accuracy. As 12 bits is the maximum ADC resolution on the Arduino Due, this is optimal for the Arduino Due.
