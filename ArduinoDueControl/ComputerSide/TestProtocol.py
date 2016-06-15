%reset -f
%matplotlib inline

import serial
import CommunicationSerialBinary
import numpy as np
from tictoc import *
import glob
import time

################################################################################
print "######################### STARTING #########################"
communication_serial = CommunicationSerialBinary.Paddle_Actuator()

################################################################################
# find available port and connect to it
usb_port = communication_serial.connect_to_board()

# simple test by hand
#signal = np.array([1,2,3,4,5,6,7,4094,4095])
signal = np.zeros((5000,))

################################################################################
# for test only set the buffer by hand
signal = np.zeros((64,))
communication_serial.set_buffer(signal)
communication_serial.generate_buffer_as_bytes()
communication_serial.transmit_buffer_bytes_through_serial()

# log during one second (the tic is used to determine one second)
tic()
list_char = []
while toc(print_message=False) < 1:
    if usb_port.inWaiting > 0:
        char = usb_port.read()
        list_char.append(char)

string_log = ''.join(list_char)
print "From Arduino: "
print str(string_log)


################################################################################
# using the library to set a signal
# SET THE PID PARAMETERS
communication_serial.set_PID_parameters(12,345,0.074,1)

# SET THE SIGNAL AND PLOT
communication_serial.set_signal(signal)
#communication_serial.plot_control_signal()
#time.sleep(0.5)
communication_serial.check_signal()

# CHECK THAT EVERYTHING IS READY
communication_serial.check_ready()

# PERFORM SETUP AND START
communication_serial.perform_setup_and_start()

# perform actuation
communication_serial.perform_actuation()


communication_serial.dict_feedback["init_trash"]
communication_serial.dict_feedback["error_msg"]
communication_serial.dict_feedback["post_actuation"]












# end
