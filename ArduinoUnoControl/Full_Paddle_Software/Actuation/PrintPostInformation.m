close all;

time_vector = 1*(1:1:size(value_table,1));
% depends on the arduino PID frequency and the output frequency
factor_scale_time = 0.005*1;
time_vector = time_vector*factor_scale_time-5.12;

ListIndices = 10:1:(length(time_vector)-10);

% the points shift between command and uptdating, see explanations lower down in the code
points_shift = 3;

figure(1)
plot(time_vector(ListIndices),value_table(ListIndices,1),'r');
hold on;
plot(time_vector(ListIndices),value_table(ListIndices,2)-255,'b');
plot(time_vector(ListIndices),value_table(ListIndices+points_shift,3),'k');
xlabel('Time (s)');
ylabel('Data summary');
legend('set point','output to actuator','input from sensor','location','eastoutside');
% stringName = strcat('Summary frequency',{' '},num2str(frq_user),'Hz, amplitude',{' '},num2str(ampl_user),'/1024, minimum duration',{' '},num2str(time_user),'s');
stringName = 'Signal and actuation summary';
title(stringName);
%xlim([0 plot_sup]);

% list of indices that are in the signal, to analyze
ListSignalPoints = 1024:1:(size(value_table,1)-1024*3);

% there is a small, constant time shift between instruction and value
% the origin of it is due to:
%                     -- the moment in the main loop when the position is read compared
%                       to the moment when the new set point is chosen, 
%                     -- the smoothing filter used to take away sensor noise
% Since it is a constant, it is just translation in time of the signal, the translation in 
% time is choosen equal to points-shift

% for a reason I do not understand, xcorr is not able to find this shift
% determine this shift
% [r,lags_r] = xcorr(value_table(ListSignalPoints,1),value_table(ListSignalPoints,3));
% [max_r,ind_max_r] = max(r);
% delay_pts = lags_r(ind_max_r);

% look if saturated command to the actuator
% absolute value of the output to actuator
absCmd = abs(value_table(ListSignalPoints,2)-255);
% thereshold for saturated command
thrsld = 250;
% list of times when saturated command
saturatedCmd = find(absCmd>thrsld);
% proportion of saturated commands
PropSaturated = length(saturatedCmd)/length(absCmd);

if (PropSaturated>0.1)
fprintf('Proportion saturated commands: %f',PropSaturated);
fprintf('\n');
fprintf('A high proportion of saturated commands may');
fprintf('\n');
fprintf('correspond to too high amplitude for the actuator');
fprintf('\n');
fprintf('power. Reduce amplitude or frequency!!');
fprintf('\n');
end

%% note: the error calculation part do not work
%  I am working on a new one.

% look at the relative error assigned value vs obtained value of position
% error = sum(abs(value_table(ListSignalPoints,3)-value_table(ListSignalPoints,1)));
list_abs_error = abs(value_table(ListSignalPoints,3)-value_table(ListSignalPoints,1));
% first part of the outliers: those with far too big error
% I = (abs(list_abs_error) > 3*std(list_abs_error));
I1 = (abs(list_abs_error) > 3*std(list_abs_error));
% second part of the outliers: those that are really outside the means of the neighbours
values_mean_err = abs((value_table(ListSignalPoints+1,3)+value_table(ListSignalPoints-1,3))/2-value_table(ListSignalPoints,3));
I2 = (abs(values_mean_err) > 2*std(values_mean_err));
Itot = I1+I2;
I = (Itot>0);

num = sum(I);
denom = length(list_abs_error);
prop_outliers = num/denom;

% fprintf('Proportion of outliers due to sensor noise (without shift correction): %f',prop_outliers);
% fprintf('\n');

list_abs_error = abs(value_table(ListSignalPoints+points_shift,3)-value_table(ListSignalPoints,1));
% I = (abs(list_abs_error) > 3*std(list_abs_error));
I1 = (abs(list_abs_error) > 5.0*std(list_abs_error));
% second part of the outliers: those that are really outside the means of the neighbours
values_mean_err = ((value_table(ListSignalPoints+1+points_shift,3)+value_table(ListSignalPoints-1+points_shift,3))/2-value_table(ListSignalPoints+points_shift,3));
values_mean_err = values_mean_err - mean(values_mean_err);
I2 = (abs(values_mean_err) > 2.0*std(values_mean_err));
Itot = I1+I2;
I = (Itot>0);
num = sum(I);
denom = length(list_abs_error);
prop_outliers = num/denom;

% fprintf('Proportion of outliers due to sensor noise (with shift correction): %f',prop_outliers);
% fprintf('\n');

figure(2)
plot(time_vector(ListSignalPoints),value_table(ListSignalPoints,1),'r');
hold on;
plot(time_vector(ListSignalPoints(not(I))),value_table(ListSignalPoints(not(I))+points_shift,3),'*k');
% plot(time_vector(ListSignalPoints(I)),value_table(ListSignalPoints(I)+points_shift,3),'*g');
% legend('Set point','Sensor output','Sensor outliers','location','eastoutside');
hl = legend('Set point','Sensor output','location','eastoutside');
plot(time_vector(ListSignalPoints),value_table(ListSignalPoints,1),'*r');
% plot(time_vector(ListSignalPoints),list_abs_error*10,'g')
hx = xlabel('Time (s)');
hy = ylabel('Data');
ht = title('Data used for quality analysis');
FormatFigures;

error = sum(list_abs_error(not(I)));
abs_signal = sum(abs(value_table(ListSignalPoints,1)));
rel_error = error/abs_signal;

% fprintf('Mean relative error without sensor outliers: %f',rel_error);
% fprintf('\n');

% spectrum of the signal can be interesting to look at
PlotPSD(value_table(ListSignalPoints,1),1/0.005,3,'Power Spectral Density overview','r');
PlotPSD(value_table(ListSignalPoints,3),1/0.005,3,'Power Spectral Density overview','k');
figure(3)
hl = legend('Set point','Sensor value');
FormatFigures;

fprintf('\n');



