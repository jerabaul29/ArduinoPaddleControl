clear all;
close all;

% clear the terminal
clc;

% prints a few informations that should be reminded to the user
% fprintf('\n');
% fprintf('\n');
fprintf('------------------------------------------------------------');
fprintf('\n');
fprintf('-     Paddle actuator v1.0     -');
fprintf('\n');
fprintf('Code written for Linux, Octave and');
fprintf('\n');
fprintf('Arduino by J. Rabault, PhD student UiO');
fprintf('\n');
fprintf('Please contact me before using, sharing');
fprintf('\n');
fprintf('or modifying the code');
fprintf('\n');
fprintf('------------------------------------------------------------');
fprintf('\n');
fprintf('\n');

% fprintf('------------------------------');
% fprintf('\n');
% fprintf('Before starting the code');
% fprintf('\n');
% fprintf('check that the must agree');
% fprintf('\n');
% fprintf('definitions are the same');
% fprintf('\n');
% fprintf('between octave and arduino');
% fprintf('\n');
% fprintf('------------------------------');
% fprintf('\n');
% fprintf('\n');

fprintf('Press any key to start!');
fprintf('\n');
fprintf('\n');

pause; 

fprintf('Control program start');
fprintf('\n');
% fprintf('\n');

goForOneMore = true;

while (goForOneMore)

clear all;
clc;
goForOneMore = true;

% each time the script is run, the arduino board will reboot. This is the expected and wished
% behaviour. This means each time the script is run, a new run is starting

% should be tested with an Arduino board plugged by USD, executing for example the enclosed
% .ino file
% The board should be an Arduino with Custom defined Buffer, to select in the Arduino IDE
% This program will send to the board a signal generated from a function that will be sent to
% the PID control loop, ie the data sent to the microcontroller should be the instruction in
% position to be fullfilled by the PID control loop

% the default octave policy is to wait program execution to display
% to see fprintf output real time, add next command
more off;

% load all packages
% package should include instrument-control
% check by running CheckPackages if necessary
pkg load all

% load the PID parameters
load('PID_parameters.mat');

% choose the way to select input signal
fprintf('\n');
fprintf('Selection of input signal.');
fprintf('\n');
fprintf('Sine, press 1;');
fprintf('\n');
fprintf('Sine*tanh, press 2;');
fprintf('\n');
fprintf('Modulated sine, press 3;');
fprintf('\n');
fprintf('Custom function, press 4;');
fprintf('\n');
fprintf('To change PID parameters, press 0;');
fprintf('\n');
fprintf('Default fast function, press 5;');
fprintf('\n');
fprintf('\n');
select_signal = input('Press 0 to 5 and enter: ');
fprintf('\n');

if (select_signal==0)

fprintf('You asked to change PID parameters');
fprintf('\n');
fprintf('Be careful, this may damage your');
fprintf('\n');
fprintf('system');
fprintf('\n');
fprintf('For transmission to arduino as bytes,');
fprintf('\n');
fprintf('values must be given as:');
fprintf('\n');
fprintf('numeric_value*10^(power of 10)');
fprintf('\n');

fprintf('Your current values are: ');
fprintf('\n');
fprintf('Power of 10 Kp  : %f',p10Kp(end));
fprintf('\n');
fprintf('Numeric value Kp: %f',nmKp(end));
fprintf('\n');
fprintf('Power of 10 Ki  : %f',p10Ki(end));
fprintf('\n');
fprintf('Numeric value Ki: %f',nmKi(end));
fprintf('\n');
fprintf('Power of 10 Kd  : %f',p10Kd(end));
fprintf('\n');
fprintf('Numeric value Kd: %f',nmKd(end));
fprintf('\n');
fprintf('Invert / direct : %f',invParam(end));
fprintf('\n');
fprintf('\n');

new_p10Kp = input('New Power of 10 Kp (-4 to 5)    : ');
new_nmKp =  input('New numeric value Kp (0 to 255) : ');
new_p10Ki = input('New Power of 10 Ki (-4 to 5)    : ');
new_nmKi =  input('New numeric value Ki (0 to 255) : ');
new_p10Kd = input('New Power of 10 Kd (-4 to 5)    : ');
new_nmKd =  input('New numeric value Kd (0 to 255) : ');
new_invParam = input('New inversion parameter (0 direct or 1 reverse): ');

if (not((new_invParam==0)||(new_invParam==1)))
  error('Inv parameter must be 0 or 1!!');
end

p10Kp = [p10Kp new_p10Kp];
nmKp  = [nmKp  new_nmKp ];
p10Ki = [p10Ki new_p10Ki];
nmKi  = [nmKi  new_nmKi ];
p10Kd = [p10Kd new_p10Kd];
nmKd  = [nmKd  new_nmKd ];
invParam = [invParam new_invParam];

save("-mat-binary", 'PID_parameters.mat');

fprintf('\n');
fprintf('Update done!');
fprintf('\n');
fprintf('Those are your new default values.');
fprintf('\n');
fprintf('All values are archived in: ');
fprintf('\n');
fprintf('PID_parameters.mat');
fprintf('\n');

% giving again the choice for the signal
fprintf('\n');
fprintf('Selection of input signal.');
fprintf('\n');
fprintf('Sine, press 1;');
fprintf('\n');
fprintf('Sine*tanh, press 2;');
fprintf('\n');
fprintf('Modulated sine, press 3;');
fprintf('\n');
fprintf('Custom function, press 4;');
fprintf('\n');
fprintf('Default fast function, press 5;');
fprintf('\n');
fprintf('\n');
select_signal = input('Press 1 to 5 and enter: ');
fprintf('\n');

end


% user defined parameters
if (select_signal == 1)

global PeriodSignal;
global AmplitudePos;
global MeanPos;
fprintf('Using sinusoidal signal');
fprintf('\n');
frq_user =  input("Enter signal frequency (Hz)       : ");
ampl_user = input("Enter signal amplitude (0 to 1023): ");
time_user = input("Enter signal duration (s)         : ");
fprintf('\n');
PeriodSignal = 1/frq_user;
AmplitudePos = ampl_user/2;
MeanPos = 510;

elseif (select_signal == 2)

global PeriodSignal;
global AmplitudePos;
global MeanPos;
global timecsst_user;
fprintf('Using tanh*sine signal');
fprintf('\n');
frq_user =      input("Enter signal frequency (Hz)                 : ");
ampl_user =     input("Enter signal amplitude (0 to 1023)          : ");
time_user =     input("Enter signal duration (s)                   : ");
timecsst_user = input("Enter time constant for tanh development (s): ");
fprintf('\n');
PeriodSignal = 1/frq_user;
AmplitudePos = ampl_user/2;
MeanPos = 510;

elseif (select_signal == 3)

global PeriodSignal;
global AmplitudePos;
global MeanPos;
global modulation_user;
fprintf('Using modulated sinusoidal signal');
fprintf('\n');
frq_user =        input("Enter signal frequency (Hz)             : ");
ampl_user =       input("Enter signal amplitude (0 to 1023)      : ");
time_user =       input("Enter signal duration (s)               : ");
modulation_user = input("Enter modulation indice (typically 0.05): ");
fprintf('\n');
PeriodSignal = 1/frq_user;
AmplitudePos = ampl_user/2;
MeanPos = 510;

elseif (select_signal == 4)
fprintf('Custom function mode');
fprintf('\n');
fprintf('Define an Octave / Matlab function');
fprintf('\n');
fprintf('of name CustomSetPoint in a separate');
fprintf('\n');
fprintf('file. The function must take in argument');
fprintf('\n');
fprintf('a list of times (in seconds) and');
fprintf('\n');
fprintf('return the coresponding list of set');
fprintf('\n');
fprintf('points.');
fprintf('\n');
fprintf('Set points must be between 0 and 1023 for all times!!');
fprintf('\n');
fprintf('(range of Arduino ADC). Keep a little bit');
fprintf('\n');
fprintf('of margin!!');
fprintf('\n');
fprintf('Press enter when your function is ready');
fprintf('\n');

pause;

time_user = input("Enter signal duration (s): ");
fprintf('\n');

fprintf('Testing your function for obvious flaws now...');
fprintf('\n');
% write a TestFunctionCustom for testing the user function from obvious flaws
TestFunctionCustom(time_user);
fprintf('Seems successfull!');
fprintf('\n');

elseif (select_signal == 5)
fprintf('Default fast function');
fprintf('\n');
fprintf('Sine, 2Hz, amplitude 400, 5 seconds');
fprintf('\n');

select_signal = 1;

global PeriodSignal;
global AmplitudePos;
global MeanPos;
frq_user =  2;
ampl_user = 400;
time_user = 5;
fprintf('\n');
PeriodSignal = 1/frq_user;
AmplitudePos = ampl_user/2;
MeanPos = 510;

else
error('Invalid signal source!!');
end

% if one of the input signal with amplitude from the user, check that in admissible range
 if (select_signal<4)
 if ((ampl_user>1023)||(ampl_user<0))
  error('You asked for too high amplitude!!');
 elseif (ampl_user>900)
  fprintf('You asked for a valide but close');
  fprintf('\n');
  fprintf('to maximum (less than 10 percents');
  fprintf('\n');
  fprintf('margin) amplitude');
  fprintf('\n');
  fprintf('Be carefull!!');
  fprintf('\n');
  fprintf('\n');
 end
 end

fprintf('Establish serial connection');
fprintf('\n');
fprintf('If fails, check that the USB is')
fprintf('\n');
fprintf('connected and try again in a few seconds');
% fprintf('\n');

% open the port using instrument-control functions
speed = 57600;
% note: the name of the port may change between computers / plugs and unplugs on the same 
% computer. Check this by typing in terminal, for example: ls /dev/ | grep ttyACM
% the name of the port should correspond to the arduino board to control
try
 ttyPort = "/dev/ttyACM0";
 sl = serial(ttyPort,speed);
 srl_flush(sl);
 catch
  try
  ttyPort = "/dev/ttyACM1";
  sl = serial(ttyPort,speed);
  srl_flush(sl);
  catch
   ttyPort = "/dev/ttyACM2";
   sl = serial(ttyPort,speed);
   srl_flush(sl);
    try
    ttyPort = "/dev/ttyACM2";
    sl = serial(ttyPort,speed);
    srl_flush(sl);
    catch
    fprintf('Arduino board not available!!');
    fprintf('\n');
    fprintf('Check that the board is connected and blinking');
    fprintf('\n');
    fprintf('If so try again in a few seconds!');
    fprintf('\n');
    end
  end
end
% display infos about the port
% fprintf("\n");
% fprintf("Port info");
% fprintf("\n");
% PrintInfoPort(sl);

% change the timeout of the srl_read to avoid hanging
% value given as tenth of seconds, max 255
% note: it seems unfortunately that not possible with less than 1/10 sec... :(
% fprintf("\n");
% fprintf("Change timeout");
% fprintf("\n");
set(sl,'timeout',1);
PrintInfoPort(sl);

% flush the buffer to avoid consequences from previous communciation
srl_flush(sl);

% read and display the output from the setup loop on Arduino
% fprintf("\n");
% fprintf("Read for timeWait ouput from setup loop on Arduino -----");
% fprintf("\n");
% fprintf("\n");

% set the number of bytes to read at a time
nBytes = 1;

% read the setup loop
% expected communication from setup loop
WaitForComm = true;
% time to wait before connection ended, must match final delay setup loop
% note: should be little less than the delay at the end of the arduino setup loop to avoid problems
% due to clocks imprecisions etc
% note: I put this in the initialization so that the sketch has the time to initialize, load, reboot etc
timeWait = 3; 
% initialize counter
tic;
% history_char_serial stores the history of the serial received data
% start writing in the history at the first indice of the table 
% note: dynamically allocated since do not know how much comm to expect
% from arduino. This is not ideal, but works fine enough
indHistory = 1;
% set(sl,'timeout',-1);
while (WaitForComm) 
        
	% read the next bytes from setup loop and translate to char
	char_serial = char(srl_read(sl,nBytes));
	% print it on octave
	% fprintf(char_serial);
	% when the time during which we want to monitor Arduino comm is over,
	% end the loop
	if (toc>timeWait)
	    WaitForComm = false;
  end
  
  if (char_serial == 'R')
    srl_write(sl,'Y');
  elseif (char_serial == 'P')
    srl_write(sl,uint8(p10Kp(end)+5));
  elseif(char_serial == 'Q')
    srl_write(sl,uint8(nmKp(end)));
  elseif(char_serial == 'I')
    srl_write(sl,uint8(p10Ki(end)+5));
  elseif(char_serial == 'J')
    srl_write(sl,uint8(nmKi(end)));
  elseif(char_serial == 'D')
    srl_write(sl,uint8(p10Kd(end)+5));
  elseif(char_serial == 'E')
    srl_write(sl,uint8(nmKd(end)));
  elseif(char_serial == 'V')
    srl_write(sl,uint8(invParam(end)));
  end

	% store the corresponding sequence, so that not lost if timeout srl_read
	% (timed out srl_read sends back void into the output)
	
	if (not(isempty(char_serial)))
	   history_char_serial(indHistory) = char_serial;
	   indHistory = indHistory + 1;
        end

end

% size of the half serial buffer on the Arduino
% to be chosen in agreement with the Arduino sketch
% NEED TO AGREE
HalfBufferSize = 512;

% print status connection from serial loop
% if the Arduino has sent the SR1 answer, all setup loop went fine and the initialization buffer should be
% sent
if ((history_char_serial(end-2)=='S')&&((history_char_serial(end-1)=='R'))&&(history_char_serial(end)=='1'))
  % fprintf("\n");
  % fprintf("Done reading setup loop successfully");
  % fprintf("\n");
  % fprintf("Initialize the Arduino buffer");
  % fprintf("\n");
  % the Arduino buffer gets initialized with a vector of zeros
  % initialize the full buffer, ie twice the half buffer
  % note: how is a vector transmitted by serial? are there some separators?
  BufferInit = 127*ones(HalfBufferSize,1,"uint8");
  srl_write(sl,BufferInit);
  BufferInit = 127*ones(HalfBufferSize,1,"uint8");
  srl_write(sl,BufferInit);
else
  % if not, some error happened
  fprintf("\n");
  error("Problem reading setup loop");
end
fprintf("\n");

% entering the main loop on both arduino and octave
fprintf("\n");
fprintf("Starting...");
fprintf("\n");

% change timeout to no timeout, in order to wait for arduino feedback
% and buffer requests
% fprintf("\n");
% fprintf("Change timeout");
% fprintf("\n");
% set(sl,'timeout',-1);
% PrintInfoPort(sl);

% maximum time during which main loop will run
% in seconds
MaxTimeMainLoop = time_user;
% initialize beginning of main loop time
tic;
% boolean to wait for first call from Arduino
% first call from the Arduino will be the beginning of the true signal
% beginning of the true signal will be beginning of the real time series
% to send
WaitForBeginning = true;
% Reference time with respect to last tic corresponding for Arduino first call for signal 
RefTimeFirstCall = 0;
% time resolution of the instruction vector sent to Arduino
% MUST AGREE WITH THE ARDUINO
TimeReso = 5000*0.000001; % in seconds
% TimeReso
% store the current time for the beginning of next buffer
BeginningTimeNextBuffer = 0;
% is next buffer ready?
NextBufferReady = false;

% pre allocation of next time vector and next buffer for speed optimization
NextTimeVector = zeros(HalfBufferSize,1);
NextBuffer = zeros(HalfBufferSize,1,"uint8");

% for test: simply generate a sinusoidal signal
% give the instruction as position to the paddle

% list of parameters 1
% PeriodSignal = 1;
% nice for tests, list parameters 1
% AmplitudePos = 550/2;
% MeanPos = 475;

% list of parameters 2
% PeriodSignal = 1/frq_user;
% AmplitudePos = ampl_user/2;
% MeanPos = 510;

history_char_serial_initialization = history_char_serial;
% history_char_serial = [];
% indHistory = 1;
ind_init_signal = indHistory;

% tic;
% take into account that at the beginning, using internal buffer equal to 0
MaxTimeMainLoop = MaxTimeMainLoop + 5.5;
% toc

while(toc<MaxTimeMainLoop)

        % receive from the Arduino a value
        % read the next bytes from setup loop and translate to char
	char_serial = char(srl_read(sl,nBytes));
	% fprintf(char_serial);

	% if the character indicates call for the first time, store the toc time for further reference if necessary
	if ((char_serial=='S')&&(WaitForBeginning))
            RefTimeFirstCall = toc;
	end

	% if next buffer not ready, compute it in advance to be ready to send it as quick as the call for new buffer is made
	if (not(NextBufferReady))
		% compute the next time vector
		NextTimeVector = BeginningTimeNextBuffer:TimeReso:(BeginningTimeNextBuffer+(HalfBufferSize)*TimeReso);
		%size(NextTimeVector)

		% compute the next buffer to send
		% this is the signal that will be used as set point in the PID
		% can be from a function, a table etc 
		% for example, use a sinus with a smoothing beginning
		% NextBuffer = uint8(127+127*sin(NextTimeVector*2*pi/PeriodSignal));
		% NextBuffer
		% since the serial port sends byy 8 bits, convert to 8 from 10 
		% loose in precision, improve here later!!
                Buffer10 = SignalGeneratingFunction(NextTimeVector,select_signal);
		% Buffer10 = MeanPos + AmplitudePos*sin(NextTimeVector*2*pi/PeriodSignal);
		% Buffer10 = MeanPos + AmplitudePos*(sin(NextTimeVector*2*pi/PeriodSignal*(1+fctmdl))+sin(NextTimeVector*2*pi/PeriodSignal*(1-fctmdl)))/2;
		NextBufferRed = (floor(Buffer10'/4));
		NextBufferRed = max(NextBufferRed,0);
		NextBufferRed = min(NextBufferRed,255);
		NextBuffer = uint8(NextBufferRed)';

		% update the time beginning for next buffer
		BeginningTimeNextBuffer = BeginningTimeNextBuffer + HalfBufferSize*TimeReso;

		% the next buffer is now ready
		NextBufferReady = true;

	end

	% if calling for new buffer, send it
	if (char_serial=='S')
		% send buffer
		% size(NextBuffer)
		% fprintf("\n");
		srl_write(sl,NextBuffer);
                % fprintf("Serve buffer");
                % fprintf("\n");
		% now we should compute the next buffer
		NextBufferReady = false;

	end

	% store the received characters sequence	
	if (not(isempty(char_serial)))
	   history_char_serial(indHistory) = char_serial;
	   indHistory = indHistory + 1;
        end
 
end

% beginning time damping signal
TimeBeginningExpDecay = BeginningTimeNextBuffer;
% exponential decay constant
ExpDecayCsst = 1.5;

% smoothly send back the signal to the reference point
while(toc<MaxTimeMainLoop+15)

        % receive from the Arduino a value
        % read the next bytes from setup loop and translate to char
	char_serial = char(srl_read(sl,nBytes));
	% fprintf(char_serial);

	% if the character indicates call for the first time, store the toc time for further reference if necessary
	if ((char_serial=='S')&&(WaitForBeginning))
            RefTimeFirstCall = toc;
	end

	% if next buffer not ready, compute it in advance to be ready to send it as quick as the call for new buffer is made
	if (not(NextBufferReady))
		% compute the next time vector
		NextTimeVector = BeginningTimeNextBuffer:TimeReso:(BeginningTimeNextBuffer+(HalfBufferSize)*TimeReso);
		%size(NextTimeVector)

		% compute the next buffer to send
		% this is the signal that will be used as set point in the PID
		% can be from a function, a table etc 
		% for example, use a sinus with a smoothing beginning
		% NextBuffer = uint8(127+127*sin(NextTimeVector*2*pi/PeriodSignal));
		% NextBuffer
		% since the serial port sends byy 8 bits, convert to 8 from 10 
		% loose in precision, improve here later!!
                Buffer10 = (SignalGeneratingFunction(NextTimeVector,select_signal)-512).*exp(-(NextTimeVector-TimeBeginningExpDecay)/ExpDecayCsst)+512;
		
	        % after 10 seconds, just put 512 ie middle position
		if (toc>MaxTimeMainLoop+10)
			Buffer10 = 512*ones(HalfBufferSize,1); 
		end

		% Buffer10 = MeanPos + AmplitudePos*sin(NextTimeVector*2*pi/PeriodSignal);
		% Buffer10 = MeanPos + AmplitudePos*(sin(NextTimeVector*2*pi/PeriodSignal*(1+fctmdl))+sin(NextTimeVector*2*pi/PeriodSignal*(1-fctmdl)))/2;
		NextBufferRed = (floor(Buffer10'/4));
		NextBufferRed = max(NextBufferRed,0);
		NextBufferRed = min(NextBufferRed,255);
		NextBuffer = uint8(NextBufferRed)';

		% update the time beginning for next buffer
		BeginningTimeNextBuffer = BeginningTimeNextBuffer + HalfBufferSize*TimeReso;

		% the next buffer is now ready
		NextBufferReady = true;

	end

	% if calling for new buffer, send it
	if (char_serial=='S')
		% send buffer
		% size(NextBuffer)
		% fprintf("\n");
		srl_write(sl,NextBuffer);
                % fprintf("Serve buffer");
                % fprintf("\n");
		% now we should compute the next buffer
		NextBufferReady = false;

	end

	% store the received characters sequence	
	if (not(isempty(char_serial)))
	   history_char_serial(indHistory) = char_serial;
	   indHistory = indHistory + 1;
        end
 
end



% toc;

% fprintf("\n");
% fprintf("\n");
% fprintf("End of instruction signal, still logs the messages from Arduino for a few seconds");
% fprintf("\n");

timeWait = 1.5; 
% initialize counter
tic;
% history for storing serial received data
% indHistory = 1;
while (toc<timeWait) 
        
	% read the next bytes from setup loop and translate to char
	char_serial = char(srl_read(sl,nBytes));
	% fprintf(char_serial);

	% store the corresponding sequence, so that not lost if timeout srl_read
	
	if (not(isempty(char_serial)))
	   history_char_serial(indHistory) = char_serial;
	   indHistory = indHistory + 1;
        end

end


fprintf('\n');
fprintf('Actuation successfull!');
fprintf('\n');
fprintf('\n');

fprintf('Do you want a post actuation analysis?');
fprintf('\n');
fprintf('This may take some time if the actuation');
fprintf('\n');
fprintf('duration was large');
fprintf('\n');

postActuation_analysis = input('Post actuation analysis: y(yes) / n(no): ','s');

if(postActuation_analysis=='y')
fprintf('Analyzing feedback data...');
fprintf('\n');
fprintf('\n');

% generates the post information data
GeneratePostInformation;
% print post programm information
PrintPostInformation;
else
fprintf('\n');
fprintf('\n');
end

GFOM = input('Go for one more run? y(yes), n(no): ','s');
goForOneMore = (GFOM =='y');


end

fprintf('\n');
fprintf('Do you want to save all data?');
fprintf('\n');
fprintf('If no type n');
fprintf('\n');
fprintf('If yes type file name (with .mat extension)');
fprintf('\n');

postActuation_save = input('save data? : ','s');

if(not(postActuation_save=='n'))
fprintf('Save all data in your file...');
fprintf('\n');
fprintf('\n');

% serial cannot be saved
clear sl;
% save all data to file
save ("-mat-binary", postActuation_save);

else
fprintf('\n');

end

fprintf('Gracefully finishing!');
fprintf('\n');

