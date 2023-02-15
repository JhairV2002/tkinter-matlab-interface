
% Alejandro Villamar - Universidad Israel %
%% ----- Parametros de simulacion ----- %%
function apartado4(lum, area, leds, users, angle)
% Ancho de banda
B = 20*10^6; % 20 MHz estándar 802.11a
% Area del fotodiodo
A = lum/(area^2); % La intensidad luminosa se mide en 1 [lumen / pie^2] 
% Ruido
No = 10^-22; % A/Hz [Haas]
N = No*B;
% ---.. Transmisor ..--- %
% Potencia optica
Pled = 10;
% Angulo de radiacion
ang_rad = angle;
m= -log(2)/log(abs(cos(ang_rad*pi/180)));
k = 1.4738;
% ---.. Fotodiodo ..--- %
% Responsividad (capacidad de respuesta)
R = 0.53;
% Orden del filtro
n = 1.5; 
% FoV (Campo de visión)
FoV = 80*pi/180;
% Respuesta del filtro
Ts = (n^2)/(sin(FoV)^2);


%% ----- Escenario ----- %%
% Posicion de las bombillas LED
L = leds; % 4 LED bombillas;
K = users, % 1 usuarios
h = 0.85;
% Posicion de los transmisores opticos
LED_pos = [3.5, 3.5, 3; 
           1.5, 3.5, 3; 
           3.5, 1.5, 3; 
           1.5, 1.5, 3]

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
        
        % Block Diagonalization % Diagonalización de bloques
        [W,S_tot] = ZFCBST(h,L,1,1,Np);
        R_BD(x,y) = sum(log2(1+S_tot.*Pled));
        
        % Zero Forcing % Tasa de forzamiento cero
        [W,S_tot] = ZFCBST(h,L,1,Np,1);
        R_ZF(x,y) = sum(log2(1+S_tot.*Pled));
    end
end

%% Mapas de color

figure(1)
surf(Ax,Ay,real(R_BD),real(R_BD),'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Rate Block Diagonalization')
print('Rate Block Diagonalization','-dpng')
close

figure(2)
surf(Ax,Ay,real(R_ZF),real(R_ZF),'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Rate Zero Forcing')
print('Rate Zero Forcing','-dpng')
close
end
