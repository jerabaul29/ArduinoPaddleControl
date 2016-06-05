%reset -f
%matplotlib inline

import serial
import CommunicationSerialBinary
import numpy as np
from tictoc import *
import glob
import time

print "######################### STARTING #########################"
communication_serial = CommunicationSerialBinary.Paddle_Actuator()

# find available port
port = CommunicationSerialBinary.look_for_available_ports()
print "Using port: "+str(port[0])
usb_port = serial.Serial(port[0],baudrate=57600)

# Toggle DTR to reset Arduino
usb_port.setDTR(False)
time.sleep(1)
# toss any data already received, see
# http://pyserial.sourceforge.net/pyserial_api.html#serial.Serial.flushInput
usb_port.flushInput()
usb_port.setDTR(True)
time.sleep(1)

communication_serial.set_serial_port(usb_port)

signal = np.arange(0,20,1)

# this should be used to pre load a big signal put trunk by trunk in the buffer later

# for test only set the buffer by hand
print "Set buffer"
communication_serial.set_buffer(signal)
print "Generate buffer as bytes"
communication_serial.generate_buffer_as_bytes()
print "Transmit one buffer"
communication_serial.transmit_buffer_bytes_through_serial()

tic()
list_char = []
print "Receive from Arduino"
usb_port.flushInput();
while toc(print_message=False) < 1:
    if usb_port.inWaiting > 0:
        char = usb_port.read()
        list_char.append(char)

string_log = ''.join(list_char)
print "From Arduino: "
print str(string_log)
