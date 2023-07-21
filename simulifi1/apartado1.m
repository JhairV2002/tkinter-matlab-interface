%Alejandro Villamar - Universidad Israel 2023%
%% ----- Parametros de simulacion red LIFI ----- %%
function apartado1(area1,area2,pled,angle,leds,users)
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
ang_rad = angle; %�ngulo de  radiaci�n LED
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

% Obtener la altura de cada luz LED
altura_LEDs = LED_pos(:, 3);

% Mostrar la altura de cada luz LED
disp(altura_LEDs);

%% Usuarios con un unico fotodiodo apuntando verticalmente
alfa = 0;
beta = 0;

%% Mapa 3D
% Creamos el mapa
grano = 0.05; % define la precision de nuestro mapa de color
% Escenario de tama�o definido por el �rea ingresada
x_min = 0;
x_max = sqrt(A);
y_min = 0;
y_max = sqrt(A);
% Escenario 5m x 5m x 3m
[Ax, Ay] = meshgrid([x_min:grano:x_max], [y_min:grano:y_max]);
SINR_NoCoop = zeros(size(Ax));
SINR_Coop = zeros(size(Ax));

for x = 1:length(Ax)
    for y = 1:length(Ay)
        % Posicion de los usuarios
        pos_usu = [Ax(x, x), Ay(y, y), 0.85];
        for l = 1:L
            h(l) = canal_vlc (LED_pos(l, :), pos_usu, alfa, beta, A, R, m, k, Ts, FoV);
        end
        SINR_NoCoop(x, y) = Pled * max(h.^2) / (Pled * (sum(h.^2) - max(h.^2)) + N);
    end
end


%% Mapas de color

figure(1)
SINR_NoCoop = 10*log10(SINR_NoCoop);
surf(Ax, Ay, real(SINR_NoCoop), real(SINR_NoCoop), 'EdgeColor', 'none')
hold on
scatter3(LED_pos(:,1), LED_pos(:,2), LED_pos(:,3), 'ro', 'filled')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('SINR sin cooperaci�n (dB)')
title('SINR sin cooperaci�n (dB)')
print('SINR_sin_cooperaci�n_(dB)','-dpng')
close

figure(2)
R_NoCoop = log2(1 + SINR_NoCoop * B);
surf(Ax, Ay, real(R_NoCoop), real(R_NoCoop), 'EdgeColor', 'none')
hold on
scatter3(LED_pos(:,1), LED_pos(:,2), LED_pos(:,3), 'ro', 'filled')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Rate sin cooperaci�n (Mbps)')
title('Rate sin cooperaci�n (Mbps)')
print('Rate_sin_cooperaci�n_(Mbps)','-dpng')
close

% Obtener la posici�n en metros de los LEDs en los ejes x y y
LED_pos_x = LED_pos(:, 1);
LED_pos_y = LED_pos(:, 2);

% Crear una superficie que muestra la posici�n de los LEDs en los ejes x y y
figure(3)
surf(Ax, Ay, zeros(size(Ax)), 'EdgeColor', 'none')
hold on
scatter3(LED_pos_x, LED_pos_y, zeros(size(LED_pos_x)), 'ro', 'filled')
view(2)
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Posici�n de los LEDs')
title('Posici�n de los LEDs')
print('Posici�n_de_los_LEDs1','-dpng')
close

% Mostrar el tama�o de la habitaci�n
figure(1)
title(sprintf('Mapa de SINR (Tama�o de la habitaci�n: %.2f m x %.2f m)', x_max, y_max))
close

figure(2)
title(sprintf('Mapa de Rate (Tama�o de la habitaci�n: %.2f m x %.2f m)', x_max, y_max))
close

end
