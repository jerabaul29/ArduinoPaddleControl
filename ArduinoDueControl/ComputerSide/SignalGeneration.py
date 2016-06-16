"""class for generation of the signal
"""

import numpy as np

class signal_generation(object):

    def generate_time_base(self,duration, scan_rate=500):
        """generate time base"""

        self.time_base = np.linspace(0,duration,duration*scan_rate+1)

        return(self.time_base)

    def generate_sinusoidal_signal(self,amplitude,frequency,mean):
        """generate sinusoidal signal on the time base"""

        self.signal = amplitude*np.sin(2*np.pi*frequency*self.time_base) + mean

        return(self.signal)

    def generate_modulated_signal(self,amplitude,frequency,mean,modulation=0.05):
        """generate modulated signal on the time base"""

        self.signal = amplitude*np.sin(2*np.pi*(frequency-modulation)*self.time_base)/2.0 + amplitude*np.sin(2*np.pi*(frequency+modulation)*self.time_base)/2.0 + mean

        return(self.signal)

    def return_signal(self):
        """return the signal"""

        return(self.signal)
