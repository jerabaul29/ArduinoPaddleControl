%reset -f
%matplotlib inline

import serial
import CommunicationSerialBinary
import numpy as np
import tictoc
import glob
import time

################################################################################
print "######################### STARTING #########################"
communication_serial = CommunicationSerialBinary.Paddle_Actuator()

################################################################################
# find available port and connect to it
usb_port = communication_serial.connect_to_board()

################################################################################
# for test only set the buffer by hand
signal = np.zeros((4000,))

################################################################################
# using the library to set a signal
# SET THE PID PARAMETERS: P  |  I  |  D  |  S
communication_serial.set_PID_parameters(12,34005,0.00074,1)

# SET THE SIGNAL AND PLOT ------------------------------------------------------
communication_serial.set_signal(signal)
communication_serial.plot_control_signal()
time.sleep(0.5)

# CHECK THAT EVERYTHING IS READY -----------------------------------------------
communication_serial.check_ready()

# PERFORM SETUP AND START ACTUATION --------------------------------------------
communication_serial.perform_setup_and_start()

# perform actuation
communication_serial.perform_actuation()


# post actuation checks and analysis -------------------------------------------

communication_serial.dict_feedback["init_trash"]
communication_serial.dict_feedback["error_msg"]
communication_serial.dict_feedback["post_actuation"]












# end
