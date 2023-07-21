%Alejandro Villamar - Universidad Israel 2023%
%% ----- Parametros de simulacion red LIFI ----- %%
function apartado4(area1,area2,pled,angle,leds,users)
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
A = area1*area2;
% Nivel de Ruido (Potencia de la se�al y se mide en unidades de amperios por hertz)
No = 10^-22; % A^2/Hz (Densidad espectral de potencia de ruido)
N = No*B; % Densidad espectral de ruido
%% ---.. Transmisor ..--- %
% Potencia optica
Pled_dB = pled; %Potencia �ptica del LED
Pled = 10^(Pled_dB*0.1)
% Angulo de radiacion
ang_rad = angle; %�ngulo de  radiaci�n LED en radianes
m = -log(2)/log(abs(cos(ang_rad*pi/180))); %Distribuci�n de intensidad angular Lambert-Beer
k = 1.4738; %Relaci�n de ganancia de la antena receptora
% ---.. Fotodiodo ..--- %
% Responsividad (capacidad de eficiencia de conversi�n de la luz en se�al el�ctrica)
R = 0.62; 
% Orden del filtro (filtra la se�al el�ctrica producida por el fotodiodo, elimina el ruido y otras interferencias)
n = 1.5;
% FoV (Campo de visi�n) (�ngulo s�lido del sensor de la c�mara)
FoV =  80*pi/180;
% Respuesta del filtro (Transmisi�n �ptica del filtro)
Ts = (n^2)/(sin(FoV)^2);

%% ----- Escenario ----- %%
% Posicion de las bombillas LED
L = leds; % 4 LEDS bombillas;
K = users; % 1 Usuarios
h = 0.85; % Altura del receptor
% Posicion de los transmisores opticos
LED_pos = [3.5, 3.5, 3; 
           1.5, 3.5, 3; 
           3.5, 1.5, 3; 
           1.5, 1.5, 3];

%% Usuarios con P fotodidodos distribuidos mediante geometria piramidal
Np = 4;
alfa = linspace(0,2*pi-pi/Np,Np);
theta = 5*pi/180;

%% Mapa 3D
% Creamos el mapa
grano = 0.2; % define la precision de nuestro mapa de color
% Escenario 5m x 5m x 3m
[Ax,Ay] = meshgrid([0.1:grano:4.9]);
% Guardmaos la variable rate de Block Diagonalization
R_BD= zeros(size(Ax));
R_ZF= zeros(size(Ax));

for x = 1:length(Ax)
    x
    for y = 1:length(Ay)
        % Posicion de los usuarios
        pos_usu = [Ax(x,x) Ay(y,y) 0.85];
        
        for l = 1:L
            for n = 1:Np
                h(l,n) = canal_vlc(LED_pos(l,:), pos_usu,alfa(n), theta, A, R, m, k, Ts, FoV);
            end
        end
        % Canal normalizado en ruido
        h = h/sqrt(N);
        % h corresponde a un canal 4x4
        
        % Block Diagonalization % Diagonalizaci�n de bloques
        [W,S_tot] = ZFCBST(h,L,1,1,Np);
        R_BD(x,y) = sum(log2(1+S_tot.*Pled));
        
        % Zero Forcing % Tasa de forzamiento cero
        [W,S_tot] = ZFCBST(h,L,1,Np,1);
        R_ZF(x,y) = sum(log2(1+S_tot.*Pled));
    end
end

%% Mapas de color 3D

figure(1)
surf(Ax,Ay,real(R_BD),real(R_BD),'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Rate Block Diagonalization')
title('Rate Block Diagonalization')
print('Rate_Block_Diagonalization','-dpng')
close

figure(2)
surf(Ax,Ay,real(R_ZF),real(R_ZF),'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Rate Zero Forcing')
title('Rate Zero Forcing')
print('Rate_Zero_Forcing','-dpng')
close

end


