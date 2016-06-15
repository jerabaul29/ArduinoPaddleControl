function [res] = SignalGeneratingFunction(input, ref)

% generates set point for the wave paddle, based on:
% input: the time vector for next buffer
% ref: the descriptor of the signal

if (ref==1)
% sinusoidal signal
global PeriodSignal;
global AmplitudePos;
global MeanPos;
res = MeanPos + AmplitudePos*sin(input*2*pi/PeriodSignal);

elseif (ref==2)
% tanh*sin signal
global PeriodSignal;
global AmplitudePos;
global MeanPos;
global timecsst_user;
res = MeanPos + AmplitudePos*tanh(input/timecsst_user).*sin(input*2*pi/PeriodSignal);

elseif (ref==3)
% modulated signal
global modulation_user;
global PeriodSignal;
global AmplitudePos;
global MeanPos;
res = MeanPos + AmplitudePos*(sin(input*2*pi/PeriodSignal*(1+modulation_user))+sin(input*2*pi/PeriodSignal*(1-modulation_user)))/2;

elseif (ref==4)
% custom function
res = CustomSetPoint(input);

else
% by default, send zero signal
res = zeros(size(input));
end

end