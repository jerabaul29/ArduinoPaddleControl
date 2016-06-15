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
	    end

	    % else, continue computing
	    crrt_value = crrt_value*10+crrt_char;

    end
end

time_vector = 0.005*(1:1:length(value_table));

figure(1)
plot(time_vector,value_table);







