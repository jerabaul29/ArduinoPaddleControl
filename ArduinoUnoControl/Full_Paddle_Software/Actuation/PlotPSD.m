function PlotPSD(x,fs,indFig,title_PSD,color)

x = x-mean(x);

%L=length(x);	 	 
%NFFT = L;
%X=fft(x);	 	 
%Px=X.*conj(X)/(NFFT*L); %Power of each freq components	 	 
%fVals=fs*(0:floor(L/2)-1)/L;	
%figure(indFig) 	
%plot(fVals,Px(1:1:floor(NFFT/2)),'b','LineWidth',1);	

N = length(x);
xdft = fft(x);
psdx = (1/(2*pi*N^2)) * abs(xdft).^2;
freq = 0:(2*pi)/N:2*pi-(2*pi)/N;
freq = freq*fs/2/pi;

% psdx
% freq

figure(indFig)
plot(freq,psdx,color);
hold on; 	 
ht = title(title_PSD);	 	 
hx = xlabel('Frequency (Hz)');
hy = ylabel('PSD');
hl = legend(' ');
xlim([0 5]);
FormatFigures;

end
