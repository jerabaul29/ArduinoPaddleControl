clear all;
close all;

% should be tested with an Arduino board plugged by USD, executing for example the enclosed
% .ino file
% The board should be an Arduino with Custom defined Buffer, to select in the Arduino IDE
% This program will send to the board a sinusoidal signal that will be sent to a PWM pin
% to be used for example for driving a paddle
% Designed for MegaMoto shield. Instruction sent is 1 byte
% byte 0 is -12V
% byte 255 is +12 V (if 12 V is power supply to the MotoShield)

% the default octave policy is to wait program execution to display
% to see fprintf output real time, add next command
more off;

% load all packages
% package should include instrument-control
% check by running CheckPackages if necessary
pkg load all

% open the port using instrument-control functions
speed = 57600;
ttyPort = "/dev/ttyACM0";
sl = serial(ttyPort,speed);

% display infos about the port
% fprintf("\n");
% fprintf("Port info");
% fprintf("\n");
PrintInfoPort(sl);

% change the timeout of the srl_read to avoid hanging
% value given as tenth of seconds, max 255
% note: it seems unfortunately that not possible with less than 1/10 sec... :(
fprintf("\n");
fprintf("Change timeout");
fprintf("\n");
set(sl,'timeout',1);
PrintInfoPort(sl);

% flush the buffer to avoid consequences from previous communciation
srl_flush(sl);

% read and display the output from the setup loop on Arduino
fprintf("\n");
fprintf("Read for timeWait ouput from setup loop on Arduino -----");
fprintf("\n");
fprintf("\n");

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
% history for storing serial received data
indHistory = 1;
while (WaitForComm) 
        
	% read the next bytes from setup loop and translate to char
	char_serial = char(srl_read(sl,nBytes));
	fprintf(char_serial);
	if (toc>timeWait)
	    WaitForComm = false;
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
HalfBufferSize = 512;

% print status connection from serial loop
if ((history_char_serial(end-2)=='S')&&((history_char_serial(end-1)=='R'))&&(history_char_serial(end)=='1'))
  fprintf("\n");
  fprintf("Done reading setup loop successfully");
  fprintf("\n");
  fprintf("Initialize the Arduino buffer");
  fprintf("\n");
  % the Arduino buffer gets initialized with a vector of zeros
  % initialize the full buffer, ie twice the half buffer
  % note: how is a vector transmitted by serial? are there some separators?
  BufferInit = 127*ones(HalfBufferSize,1,"uint8")-150;
  srl_write(sl,BufferInit);
  BufferInit = 127*ones(HalfBufferSize,1,"uint8")-150;
  srl_write(sl,BufferInit);
else
  fprintf("\n");
  error("Problem reading setup loop");
end
fprintf("\n");
% note: other basic commands of interest
% srl_write(sl,TO_WRITE);

fprintf("\n");
fprintf("Entering main loop");
fprintf("\n");

fprintf("\n");
fprintf("Change timeout");
fprintf("\n");
set(sl,'timeout',-1);
PrintInfoPort(sl);


% maximum time during which main loop will run
MaxTimeMainLoop = 20;
% initialize beginning of main loop time
tic;
% boolean to wait for first call from Arduino
% first call from the Arduino will be the beginning of the true signal
WaitForBeginning = true;
% Reference time with respect to last tic corresponding for Arduino first call for signal 
RefTimeFirstCall = 0;
% time resolution of the instruction vector sent to Arduino
TimeReso = 5000*0.000001;
TimeReso
% store the current time for the beginning of next buffer
BeginningTimeNextBuffer = 0;
% is next buffer ready?
NextBufferReady = false;

% pre allocation of next time vector and next buffer for speed optimization
NextTimeVector = zeros(HalfBufferSize,1);
NextBuffer = zeros(HalfBufferSize,1,"uint8");

% for test: simply generate a sinusoidal signal
PeriodSignal = 1;
Amplitude = 100;
Mean = 600;
RelAmpl = 1;

while(toc<MaxTimeMainLoop)

        % receive from the Arduino a value
        % read the next bytes from setup loop and translate to char
	char_serial = char(srl_read(sl,nBytes));
	fprintf(char_serial);

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
		
		% code to use for PID
		% here, transmitted as 8 bits (0 to 255), but for a 10 bits position (0 1023)
		% value1024 = Amplitude*sin(NextTimeVector*2*pi/PeriodSignal)+Mean;
		% value256 = floor(value1024/4);
		% value256 = max(0,value256);
		% value256 = min(255,value256);
		% NextBuffer = uint8(value256);

		% code to use for test
                NextBuffer = uint8(floor(127+RelAmpl*127*sin(NextTimeVector*2*pi/PeriodSignal)));

		%NextBuffer

		% update the time beginning for next buffer
		BeginningTimeNextBuffer = BeginningTimeNextBuffer + HalfBufferSize*TimeReso;

		% the next buffer is now ready
		NextBufferReady = true;

	end

	% if calling for new buffer, send it
	if (char_serial=='S')
		% send buffer
		%size(NextBuffer)
		fprintf("\n");
		srl_write(sl,NextBuffer);
                fprintf("Serve buffer");
                fprintf("\n");
		% now we should compute the next buffer
		NextBufferReady = false;

	end

	% store the received characters sequence	

	if (not(isempty(char_serial)))
	   history_char_serial(indHistory) = char_serial;
	   indHistory = indHistory + 1;
        end
 
end

fprintf("\n");
fprintf("\n");
fprintf("End of instruction signal");
fprintf("\n");

% print post programm information

% reconstruct the table and plot
ind_reconstruct = 1;
crrt_value = 0;
wait_next_nbr = false;
for i=1:1:length(history_char_serial)-10
    crrt_char = str2double(history_char_serial(i));
    if (isnan(crrt_char))
	    % if NaN, save the current value and put flag for waiting for next value
	    wait_next_nbr = true;
	    value_table(ind_reconstruct)=crrt_value;
    else
	    % it is a number
	    % if it is the first, initialize and go to next indice
	    if (wait_next_nbr)
		    wait_next_nbr = false;
		    crrt_value = crrt_char;
		    ind_reconstruct = ind_reconstruct + 1;
	    else
	    % else, continue computing
	    crrt_value = crrt_value*10+crrt_char;
            end

    end
end

time_vector = 1*(1:1:length(value_table));

figure(1)
plot(time_vector,value_table);
xlabel('Sample point');
ylabel('Position read sensor (8bits)');
title('Test sensor');
