%reset -f
%matplotlib inline

import serial

# open a serial port
serial_port = serial.Serial('/dev/ttyACM0',baudrate=9600)  # open serial port
print(serial_port.name)         # check which port was really used
#ser.write(b'hello')     # write a string
#ser.read()

while serial_port.inWaiting > 0:
    char = serial_port.read()
    print char

ser.close()             # close port
