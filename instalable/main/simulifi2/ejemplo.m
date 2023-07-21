clc
clear
close all

P = 8;
        


s = [1+j, 1-j, -1+j, -1-j, 1+j, -1+j, -1-j, 1+j]
x = ifft(s)



s_sym = [0 s(1) s(2) s(3) s(4) 0 conj(s(4)) conj(s(3)) conj(s(2)) conj(s(1)) ]
x_sym = ifft(s_sym)



% 
% NFFT = 128
% x = randn(NFFT,1);
% H = zeros(NFFT,1);
% H(10:20) = 1;
% H(end-20+2:end-10+2) = 1;    % Other half
% y = ifft(H.*fft(x));
% 
