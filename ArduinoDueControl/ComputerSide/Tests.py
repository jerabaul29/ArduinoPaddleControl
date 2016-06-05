%reset -f
%matplotlib inline

from CommunicationSerialBinary import *
import numpy as np

test_library = Paddle_Actuator()

virtual_port = 1
test_library.set_serial_port(virtual_port)

np.linspace(0,5,6)

signal = np.floor((2**9)*np.sin(np.linspace(0,100,101)/25.*np.pi)+2**9)
test_library.set_signal(signal)

test_library.set_buffer(0)
test_library.generate_buffer_as_bytes()

test_library.control_signal.shape
test_library.add_end_signal()
test_library.add_end_signal()
test_library.check_signal()
test_library.plot_control_signal()
