function [freq_cyclespermm,amplitude] = fftMTF(x_mm,counts)




deltaX_mm = abs(diff(x_mm(1:2)));             % Sampling period       
Fs=1/deltaX_mm;                                  % Sampling frequency
L = numel(counts);                           % Length of signal
freq_cyclespermm = Fs*(0:(L/2))/L;


M=abs(fft(counts));
M = M(1:L/2+1);
amplitude=M/M(1);

end