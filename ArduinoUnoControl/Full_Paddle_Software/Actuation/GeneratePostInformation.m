% generates the post information from the buffer history

% reconstruct the table of feedback values
ind_reconstruct = 1;
% current value of the indice (line)
crrt_value = 0;
% wait for start of next number
wait_next_nbr = false;
% wait for the char indicating beginning of loop
% wait_char_endSetup = true;
% save different kinds of data: c (set point, first column),
% o (output, second), v (value from analogRead)
crrt_dataSaved = 1;
for i=1:1:length(history_char_serial)-10
    crrt_char = str2double(history_char_serial(i));
     % if (wait_char_endSetup)
     %	    if (history_char_serial(i)=='X')
     %		    wait_char_endSetup = false;
     %	    end

     % else
    if (isnan(crrt_char))
	    % if NaN, check which char it is.
	    % save at current position 
	    % if one of the command char, go to the corresponding column
	    wait_next_nbr = true;
	    value_table(ind_reconstruct,crrt_dataSaved)=crrt_value;

	    if (history_char_serial(i)=='C')
		    % we received a C
		    % write in column 1
		    crrt_dataSaved = 1;
		    % and write in the next line
		    ind_reconstruct = ind_reconstruct+1;
	    elseif(history_char_serial(i)=='O')
		    % we received a O
		    % write in column 2
		    crrt_dataSaved = 2;
	    elseif(history_char_serial(i)=='V')
		    % we received a V
		    % write in column 3
		    crrt_dataSaved = 3;

	    end
    else
	    % it is a number
	    % if it is the first, initialize and go to next indice
	    if (wait_next_nbr)
		    wait_next_nbr = false;
		    crrt_value = crrt_char;
%		    ind_reconstruct = ind_reconstruct + 1;
	    else
	    % else, continue computing
	    crrt_value = crrt_value*10+crrt_char;
            end

    % end
     end
end
