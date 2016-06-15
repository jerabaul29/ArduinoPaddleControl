function [res] = CustomSetPoint (input)

% define your custom function here!
% input: vector (in seconds)
% res: set point sent to Arduino
% MUST BE BETWEEN 0 and 1023, KEEP SOME MARGIN!!

% tips:
% -- you should write a vectorialized function for speed, do not forget
%    the .* ./ if you need some!

% example>
% res = 512 + 300*sin(2*pi/1*input);
% res = 512;

% put to extremities
% if (input(1)<30)
%         res = 1000;
% else 
% 	res = 100;
% end

res = 512;

end
