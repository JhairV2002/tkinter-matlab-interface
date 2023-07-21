%Alejandro Villamar - Universidad Israel 2023%
%% ----- Parametros de simulacion red LIFI ----- %%
% Rango del espectro de luz - %Est�ndar 802.15.7 de la IEEE
lambda = [475]; % Rango (380 - 789) de longitud de onda en nan�metros (nm)
% Convertir a metros
lambda_m = lambda * 1e-9; % Convertir nm a metros
% Calcular las frecuencias correspondientes
c = 299792458; % Velocidad de la luz en metros por segundo
f = c ./ lambda_m; % Frecuencias en Hz
% Frecuencia
B = f; 
% Area del fotodiodo (m�)
A = 5*5;
% Nivel de Ruido (Potencia de la se�al y se mide en unidades de amperios por hertz)
No = 10^-22; % A^2/Hz (Densidad espectral de potencia de ruido)
N = No*B; % Densidad espectral de ruido

%% ---.. Transmisor ..--- %
% Potencia optica
Pled_dB = 15; %Potencia �ptica del LED
Pled = 10^(Pled_dB*0.1)
% Angulo de radiacion
ang_rad = 60; %�ngulo de  radiaci�n LED
m = -log(2)/log(abs(cos(ang_rad*pi/180))); %Distribuci�n de intensidad angular Lambert-Beer
k = 1.4738; %Relaci�n de ganancia de la antena receptora
%% ---.. Fotodiodo ..--- %
% Responsividad (capacidad de eficiencia de conversi�n de la luz en se�al el�ctrica)
R = 0.62; 
% Orden del filtro (filtra la se�al el�ctrica producida por el fotodiodo, elimina el ruido y otras interferencias)
n = 1.5;
% FoV (Campo de visi�n) (�ngulo s�lido del sensor de la c�mara)
FoV =  70*pi/180;
% Respuesta del filtro (Transmisi�n �ptica del filtro)
Ts = (n^2)/(sin(FoV)^2);


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
ylabel('Contribuci�n multipath H_{diff}')
print('Contribuci�n_multipath_H_{diff}','-dpng')
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
ylabel('Contribuci�n del front-end �pticos')
print('Contribuci�n_del_front_end_�pticos','-dpng')
close

%% Canal Optico total total
h_opt = (h_LOS + h_diff).*h_m;
figure(3)
plot((f/10^6),abs(h_opt))
hold on
grid on
xlabel('Frecuencia [MHz]')
ylabel('Canal �ptico')
print('Canal_�ptico','-dpng')
close

%% Canal temporal sin tener en cuenta los efectos del front-end
t = [0, At];
ht = [h_LOS, eta_diff]
figure(4);
stem(t,ht);
grid on
xlabel('Tiempo [nseg]')
ylabel('Respuesta temporal del canal �ptico (NO Front-end)')
print('Respuesta_temporal_del_canal_�ptico_(NO_Front-end)','-dpng')
close

%% Canal temporal teniendo en cuenta los efecto del front
% Realizamos la ifft del canal
ht_opt = ifft(h_opt);
figure(5);
plot(abs(ht_opt))
grid on
xlabel('Tiempo [nseg]')
ylabel('Respuesta temporal del canal �ptico')
print('Respuesta_temporal_del_canal_�ptico','-dpng')
close
% La forma debe parecerse al canal impulsivo

%save canal_ofdm h_LOS eta_diff
