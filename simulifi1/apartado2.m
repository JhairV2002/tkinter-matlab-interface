
% Alejandro Villamar - Universidad Israel %
%% ----- Parametros de simulacion ----- %%
function apartado2(lum, area, leds, users, angle)
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
FoV =  70*pi/180;
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

%% Usuarios con un unico fotodiodo apuntando verticalmente
alfa = 0;
beta = 0;

%% Mapa 3D
% Creamos el mapa
grano = 0.05; % define la precision de nuestro mapa de color
% Escenario 5m x 5m x 3m
[Ax,Ay] = meshgrid([0:grano:5]);
SINR_NoCoop = zeros(size(Ax));
SINR_Coop = zeros(size(Ax));


for x = 1:length(Ax)
    for y = 1:length(Ay)
        % Posicion de los usuarios
        pos_usu = [Ax(x,x) Ay(y,y) 0.85];
        for l = 1:L
            h(l) = canal_vlc(LED_pos(l,:), pos_usu,alfa, beta, A, R, m, k, Ts, FoV);
        end
        SINR_Coop(x,y) = Pled*sum(h.^2)/N;
        
    end
end

%% Mapas de color

SINR_Coop = 10*log10(SINR_Coop);
figure(1)
surf(Ax,Ay,real(SINR_Coop),real(SINR_Coop),'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('SINR con cooperacion')
print('SINR_Coop','-dpng')
close

R_Coop = log2(1+SINR_Coop);
figure(2)
surf(Ax,Ay,real(R_Coop),real(R_Coop),'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Rate con cooperacion')
print('Rate_Coop','-dpng')
close
end