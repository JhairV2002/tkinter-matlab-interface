%Alejandro Villamar - Universidad Israel 2023%
%% ----- Parametros de simulacion red LIFI ----- %%
function apartado2(area1,area2,alt,lm,pled,angle,leds,users)
lumen = lm;
potencia_watts = pled;
lambda_min = lumen / potencia_watts; %Flujo luminoso por watt
lambda_max = lumen / potencia_watts; %Flujo luminoso por watt
% Establecer los valores m�nimos y m�ximos de las longitudes de onda
lambda_min = lambda_min; % 380nm
lambda_max = lambda_max; % 789nm

% Convertir a metros
lambda_m_min = lambda_min * 1e-9; % Convertir nm a metros
lambda_m_max = lambda_max * 1e-9; % Convertir nm a metros

% Calcular las frecuencias correspondientes
c = 299792458; % Velocidad de la luz en metros por segundo
f_min = c / lambda_m_max; % Frecuencia m�nima en Hz
f_max = c / lambda_m_min; % Frecuencia m�xima en Hz

% Frecuencia promedio
f_promedio = (f_min + f_max) / 2;

% Frecuencia
B = f_promedio; 
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
FoV =  ang_rad*pi/180;
% Respuesta del filtro (Transmisi�n �ptica del filtro)
Ts = (n^2)/(sin(FoV)^2);

%% ----- Escenario ----- %%
% Posicion de las bombillas LED
L = leds; % 4 LEDS bombillas;
K = users; % 1 Usuarios
h = 0.85; % Altura del receptor
% Posicion de los transmisores opticos
LED_pos = [3.5, 3.5, alt; 
           1.5, 3.5, alt; 
           3.5, 1.5, alt; 
           1.5, 1.5, alt];

% Obtener la altura de cada luz LED
altura_LEDs = LED_pos(:, 3);

% Mostrar la altura de cada luz LED
disp(altura_LEDs);

%% Usuarios con un unico fotodiodo apuntando verticalmente
alfa = 0;
beta = 0;

%% Mapa 3D
% Creamos el mapa
grano = 0.01; % define la precision de nuestro mapa de color
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
        pos_usu = [Ax(x,x) Ay(y,y) 0.85];
        for l = 1:L
            h(l) = canal_vlc(LED_pos(l,:), pos_usu,alfa, beta, A, R, m, k, Ts, FoV);
        end
        SINR_Coop(x,y) = Pled * (sum(h.^2) - max(h.^2)) + N;
        
    end
end

%% Mapas de color

figure(1)
SINR_Coop = 10*log10(SINR_Coop);
surf(Ax,Ay,real(SINR_Coop),real(SINR_Coop),'EdgeColor','none')
hold on
scatter3(LED_pos(:,1), LED_pos(:,2), LED_pos(:,3), 'ro', 'filled')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('SINR con cooperaci�n (dB)')
title(sprintf('Mapa de SINR (Tama�o de la habitaci�n: %.2f m x %.2f m)', x_max, y_max));

% Agregar texto con la altura del techo
altura_techo_text = sprintf('Altura del techo: %.2f m', alt);
text(x_max-0.5, y_max-0.5, max(max(real(SINR_NoCoop))), altura_techo_text, 'Color', 'black', 'FontSize', 12, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');

% Primera imagen: Vista desde el �ngulo predeterminado (por ejemplo, 30 grados)
view(30, 30); % Establecer vista (azimut, elevaci�n)
print('SINR_con_cooperaci�n_vista1','-dpng')

% Segunda imagen: Vista desde la parte superior del plano (elevaci�n de 90 grados)
view(0, 90); % Establecer vista (azimut, elevaci�n)
xticks(0:0.5:x_max); % Ajustar marcadores en el eje x
yticks(0:0.5:y_max); % Ajustar marcadores en el eje y
zticks(0:0.00:alt); % Ajustar marcadores en el eje z
axis equal; % Igualar escala de los ejes x, y, z
print('SINR_con_cooperaci�n_vista2','-dpng')
close

figure(2)
R_Coop = log2(1+SINR_Coop);
surf(Ax,Ay,real(R_Coop),real(R_Coop),'EdgeColor','none')
hold on
scatter3(LED_pos(:,1), LED_pos(:,2), LED_pos(:,3), 'ro', 'filled')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
title(sprintf('Mapa de Rate (Tama�o de la habitaci�n: %.2f m x %.2f m)', x_max, y_max));

% Primera imagen: Vista desde el �ngulo predeterminado (por ejemplo, 30 grados)
view(30, 30); % Establecer vista (azimut, elevaci�n)
print('Rate_con_cooperaci�n_vista1','-dpng')

% Segunda imagen: Vista desde la parte superior del plano (elevaci�n de 90 grados) con ejes ajustados
view(0, 90); % Establecer vista (azimut, elevaci�n)
xticks(0:0.5:x_max); % Ajustar marcadores en el eje x
yticks(0:0.5:y_max); % Ajustar marcadores en el eje y
zticks(0:0.5:alt); % Ajustar marcadores en el eje z
axis equal; % Igualar escala de los ejes x, y, z
print('Rate_con_cooperaci�n_vista2','-dpng')
close

% Obtener la posici�n en metros de los LEDs en los ejes x y y
LED_pos_x = LED_pos(:, 1);
LED_pos_y = LED_pos(:, 2);
% Crear una superficie que muestra la posici�n de los LEDs en los ejes x y y
% Obtener el tama�o de la habitaci�n (m�ximos en los ejes x e y)
x_max = max(max(Ax));
y_max = max(max(Ay));
% Obtener el tama�o m�ximo para establecer el l�mite de los ejes
max_room_size = max(x_max, y_max);

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
title(sprintf('Posici�n de los LEDs (Tama�o de la habitaci�n: %.2f m x %.2f m)', x_max, y_max));
axis equal % Esto asegura que los ejes tengan la misma escala
% Establecer los incrementos de 0.5 en ambos ejes
incremento = 0.5;
xticks(0:incremento:max_room_size)
yticks(0:incremento:max_room_size)
xlim([0 max_room_size]) % Establecer l�mite en el eje x
ylim([0 max_room_size]) % Establecer l�mite en el eje y
print('Posici�n_de_los_LEDs2','-dpng')
close

% Mostrar el tama�o de la habitaci�n
figure(1)
title(sprintf('Mapa de SINR (Tama�o de la habitaci�n: %.2f m x %.2f m)', x_max, y_max))
close

figure(2)
title(sprintf('Mapa de Rate (Tama�o de la habitaci�n: %.2f m x %.2f m)', x_max, y_max))
close

end