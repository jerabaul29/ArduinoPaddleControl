function TestFunctionCustom (max_time)

% tests for obvious flaws the CustomSetPoint function

% time vector on which to test the function
timeVectorTest = 0:0.005:max_time;

% the function should be vectorialized
res = CustomSetPoint(timeVectorTest);

% and in particular, all input should be between 0 and 1023
max_value = max(res);
min_value = min(res);

if ((max_value>1023)||(min_value<0))
  error('Your custom function is out of bounds!!');
elseif ((max_value>923)||(min_value<100))
  fprintf('Your custom function is valid but');
  fprintf('\n');
  fprintf('you are close to max amplitude');
  fprintf('\n');
  fprintf('(less than 10 percents margin on at');
  fprintf('\n');
  fprintf('least one of the bounds).');
  fprintf('\n');
  fprintf('Be careful!!');
end

end