function PrintInfoPort (PortName)

% function that prints the informations about the port PortName

% first get the info structure about the port
PortInfo = get(PortName);

fprintf("\n");
fprintf("\n");
fprintf("----- Print infos about port -----");
fprintf("\n");

% admissible value and selected value to check with arduino
% admissible arduino: ex: 9600 57600 115200
% admissible instrument-control: ex: idem
fprintf("Baud rate: ");
BaudRateValue = PortInfo.baudrate;
disp(BaudRateValue);

% admittible values 5, 6, 7, 8
fprintf("Bytesize: ");
BytesizeValue = PortInfo.bytesize;
disp(BytesizeValue);

% time out value, in particular for srl_read in tenth of seconds
% -1 is no timeout
fprintf("Timeout: ");
TimeoutValue = PortInfo.timeout;
disp(TimeoutValue);

fprintf("----- Print infos about port -----");
fprintf("\n");
fprintf("\n");

end
