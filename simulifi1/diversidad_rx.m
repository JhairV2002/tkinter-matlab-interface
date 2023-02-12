clear
close all
clear all

% Alejandro Villamar - Universidad Israel %
%% ----- Parametros de simulacion ----- %%
% Ancho de banda
B = 20*10^6; % 20 MHz
% Area del fotodiodo
A = 15/(1000^2);
% Ruido
No = 10^-21; % A/Hz [Haas]
N = No*B;
% ---.. Transmisor ..--- %
% Potencia optica
Pled_dB = -6:2:14; % dB
Pled = 10.^(Pled_dB*0.1) % unidades naturales
% Angulo de radiacion
ang_rad = 70;
m= -log(2)/log(abs(cos(ang_rad*pi/180)));
k = 1.4738;
% ---.. Fotodiodo ..--- %
% Responsividad
R = 0.53;
% Orden del filtro
n = 1.5;
% FoV
FoV = 60*pi/180;
% Respuesta del filtro
Ts = (n^2)/(sin(FoV)^2);


%% ----- Escenario ----- %%
% Posicion de las bombillas LED
L = 4; % 4 LED bombillas;
K = 1, % 1 usuarios
h = 0.85;
% Posicion de los transmisores opticos
LED_pos = [3.5, 3.5, 3;
    1.5, 3.5, 3;
    3.5, 1.5, 3;
    1.5, 1.5, 3]

function [Ldiv,P, w] = diversidad_rx(H,tipo,Pled, N)

%% Parametros de entrada

%% Parametros de salida

[Ltotal(4), Ptotal (1)] = size(H);
if tipo == 1
    %% EGC seleccion el valor maximo de toda la matrix de canal
    [Vector_led_max Legc] = max(H);
    [Hegc, Pegc] = max(Vector_led_max);
    Ldiv = Legc(Pegc);
    P = Pegc;
    w = 1;
elseif tipo == 2
    %% Selecciona el transmisor LED que mayor ganancia ofrece
    [Vmax Legc] = max(sum(H,2));
    Ldiv = Legc;
    P = 1:Ptotal;
    w = 1;
elseif tipo == 3
    % Utilizamos el LED mas potente
    [Vmax Lmrc] = max(sum(H,2));
    Ldiv = Lmrc;
    P  = 1:Ptotal;    
    w = zeros(1,Ptotal);
    for pd = 1:Ptotal
        w(pd) = ((Pled*H(Lmrc,pd))^2)/( (Pled*(sum(H(:,pd))-H(Lmrc,pd)))^2 + N);
    end
    % Normalizamos los pesos
    w = w/norm(w);
else
    Ldiv = 0;
    P = 0;
    w = 0;
    error = 1
end

end

