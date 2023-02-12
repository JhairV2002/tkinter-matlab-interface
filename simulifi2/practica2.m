clc
clear all 
close all

% Alejandro Villamar - Universidad Israel %
%% ----- Parametros de simulacion ----- %%
% Ancho de banda
BW = 100*10^6; % 20 MHz
% Area del fotodiodo
A = 15/(1000^2);
% Ruido
No = 10^-21; % A/Hz [Haas]
Pn = No*BW; % P noise
Pled = 10; % 1W de potencia

% Numero de subportadoras        
N = 64;
% Longitud del prefijo ciclico
lenCP = 16;

%% Modulacion por simbolo
% % ----- BPSK ----- %
% S = 2;
% constelacion = [-1, 1];
% % ----- QPSK ----- %
S = 4;
constelacion = [1+j, 1-j, -1-j, -1+j];
% % ----- 8-QPSK ----- %
% S = 8;
% psk8 = linspace(0,2*pi-2*pi/8, 8)
% constelacion = exp(j.*psk8)


%% Simetrico Hermetico
% Nota: Solo podemos utilizar N/2-1 subportadoras
posSimb = round(rand(1,N/2-1)*(S-1))+1;
% Generamos la senal
senal_ofdm = constelacion(posSimb);
% Hermitiano simetrico
s_sym = [0 senal_ofdm 0 conj(flip(senal_ofdm))];

%% IFFT
x_ifft = ifft(s_sym)

x = [x_ifft(end-lenCP+1:end) x_ifft];
% Representacion %
figure(1);
plot(x);
grid on
hold on
ylabel('Señal temporal');
xlabel('Número de portadoras')

figure(2)
pwelch(x);

% Relación de potencia máxima a media
Vmax =  max(abs(x));
Vmedio = abs(mean(x));
PAPR = 10*log10(Vmax/Vmedio)

% Senñal recortada %
x_rec = x;
x_rec(x<0)=0;

figure(3)
plot(x_rec)
hold on 
grid on

% Senal con Ibias %
% El valor minimo determina el valor de BIAS
V_ofdm_min = min(x); 
x_bias = x + abs(V_ofdm_min);

figure(4)
plot(x_bias)
hold on 
grid on


%% ----- CANAL OFDM ------
load canal_ofdm.mat
n_simb_delay = 1;
z_ruido = randn(1, length(x));
%%  Canal sin multipath
%y = sqrt(Pled)*(h_LOS/sqrt(Pn))*x + z_ruido;
%% Canal con mutipath de 1 muestra
y = sqrt(Pled)*(h_LOS/sqrt(Pn))*x + sqrt(Pled)*(eta_diff/sqrt(Pn))*[x(2:end) zeros(1,n_simb_delay)] + z_ruido;



%% Receptor OFDM
y_cp = y(lenCP+1:end)

Y = fft(y_cp)

% Decodifiacion QPSK
simb_dec = (real(Y(2:N/2)>0)*2-1) + j*((imag(Y(2:N/2))>0)*2-1)
SER = mean(simb_dec~=senal_ofdm)





