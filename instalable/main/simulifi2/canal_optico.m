clc
close all
clear all

% Alejandro Villamar - Universidad Israel %
%% ----- ESCENARIO OPTICO ----- %%
% Ancho de banda
BW = 20*10^6; % 20 MHz
% Area del fotodiodo
A = 15/(1000^2);
% Ruido
No = 10^-22; % A/Hz [Haas]
N = No*BW;

% Responsividad
R = 0.53;

% Ganancia del filtro
n = 1.5; 
fov =  70*pi/180;
Ts = (n^2)/(sin(fov)^2)
% FoV
FoV =  70*pi/180;

% Radiacion (perpendicular al suelo)
Pled_dB = 10; 
Pled = 10^(Pled_dB*0.1)
m= -log(2)/log(cos(60*pi/180));



%% Canal optico LoS
% Posicion del LED
pos_LED = [2.5,2.5,3];
% Posicion usuario
pos_usu = [2.5,2.5,0.85];
% Un solo fotodiodo apuntado verticalmente
alfa = 0;
theta = 0;
% Canal LoS
[h_LOS] = canal_vlc(pos_LED, pos_usu,alfa, theta, A, R, m, Ts, FoV) 


%% Canal optico multi-path
% Area total iluminada
Aroom = 4*(5*3) + 2*(5*5);
% Factor de reflexion
rho = 0.6;
% Calculo del delay 0
At = 8.8*10^-9;
% Frecuencia de corte de la reflexiones [Haas]
fd = 30*10^6; % 30 MHz 
% Valor de las difracciones
eta_diff = (A/Aroom)*(rho/(1-rho))

% Pasos de 10 KHz
% Hasta 100 MHz
f = 1:1e4:1e8;
h_diff = eta_diff*exp(j*2*pi*At)./(1+j*f./fd);

figure(1)
plot((f/10^6),abs(h_diff))
hold on
grid on
xlabel('Frecuencia [MHz]')
ylabel('Contribución multipath H_{diff}')
print('Barplot1co','-dpng')
close

%% Canal del front-end optico
% Frecuencia de corte del front-end optico
fm = 30*10^6; % 30 MHz 
h_m = exp(-f/(1.44*fm));

figure(2)
plot((f/10^6),h_m)
hold on
grid on
xlabel('Frecuencia [MHz]')
ylabel('Contribución del front-end ópticos')
print('Barplot2co','-dpng')
close

%% Canal Optico total total
h_opt = (h_LOS + h_diff).*h_m;
figure(3)
plot((f/10^6),abs(h_opt))
hold on
grid on
xlabel('Frecuencia [MHz]')
ylabel('Canal Óptico')
print('Barplot3co','-dpng')
close

%% Canal temporal sin tener en cuenta los efectos del front-end
t = [0, At];
ht = [h_LOS, eta_diff]
figure(4);
stem(t,ht);
grid on
xlabel('Tiempo [nseg]')
ylabel('Respuesta temporal del canal óptico (NO Front-end)')
print('Barplot4co','-dpng')
close

%% Canal temporal teniendo en cuenta los efecto del front
% Realizamos la ifft del canal
ht_opt = ifft(h_opt);
figure(5);
plot(abs(ht_opt))
grid on
xlabel('Tiempo [nseg]')
ylabel('Respuesta temporal del canal óptico')
print('Barplot5co','-dpng')
close
% La forma debe parecerse al canal impulsivo

%save canal_ofdm h_LOS eta_diff
