% Alejandro Villamar - Universidad Israel %
%% ----- Parametros de simulacion ----- %%

% Posicion del LED
LED_pos = [2.5, 2.5, 3]
% Angulo de irradiación
Tr_ang = 60;
% Area de deteccion 1 cm2
A = 150/(1000^2);
% Directividad del FoV
k = 1.4738;
% Responsividad (capacidad de respuesta)
R = 0.53; %(0.53 A/W)
% Perdidas del filtro receptor
Ts = 1;

%% Ruido
% Ancho de banda
BW = 20e6;
% Variacion de ruido (A/Hz [Haas])
No = 10^-20;
% potencia de ruido
N = No*BW;

% Numero de usuarios
K = 2



% Parametros del sistema
% Longitud de la secuencia a enviar
lenSec = 1000;
Pled_dB = -2:2:18
Pled =10.^(Pled_dB*0.1);
Nsim = 100;
BER1 = zeros(Nsim, length(Pled_dB));
BER2 = zeros(Nsim, length(Pled_dB));
BER1_noma= zeros(Nsim, length(Pled_dB));
BER2_noma = zeros(Nsim, length(Pled_dB));
for p = 1:length(Pled_dB)
    p
    for n = 1:Nsim
        
        % Establecemos la posicion de los usuarios
        % Usuarios en la misma posicion con una pequena variacion de medio metro
                 pos_usu(1,:) = [rand(1,2)*5,0.85];
                 pos_usu(2,:) = pos_usu(1,:)*rand*0.5;
        
        % Usuarios con un canal muy diferente
        % OJO: El canal con el peor canal debe ser el primero
        pos_usu(1,:) = [1, 1, 0.85]; % Usuario en una esquina
        pos_usu(2,:) = [2.5, 2.5, 0.85]; % Usuario en centro del escenario
        
        
        % Canal del usuario 1
        h1 = channel_vlc(LED_pos,pos_usu(1,:),0,0,A,R,k,Tr_ang,Ts);
        h2 = channel_vlc(LED_pos,pos_usu(2,:),0,0,A,R,k,Tr_ang,Ts);
        
        % Dado que el canal está normalizado, el ruido tiene una varianza de 1
        h1 = h1/sqrt(N);
        h2 = h2/sqrt(N);
        
        
        % 2-PAM
        Npam = 2;
        simb = [0 1];
        
        % 4-PAM
          Npam = 4;
          simb = [0 1/3 2/3 1];
        
        % 8-PAM
          Npam = 8;
          simb = linspace(0,1,Npam);
        
        % Genereamos la señal de acuerdo a la modulacion M-PAM seleccionada
        simbValue = round(rand(K,lenSec)*(Npam-1)+1);
        s = simb(simbValue);
        DC = mean(simb);
        
        %%  ------------------------------ TRADITIONAL NOMA ---------------------------  %%
        h1_noma = h1;
        h2_noma = h2;
        
        a1 = sqrt(h2_noma/(h1_noma+h2_noma));
        a2 = sqrt(h1_noma/(h1_noma+h2_noma));
        
        %% ---------  USER 1 --------- %%
        y_1 = (s(1,:)*a1+ s(2,:)*a2)*h1_noma*Pled(p) + randn(1,lenSec);
        % Importante, normalizas la señal recibida
        y_1_norm = DC*y_1/mean(y_1);
        
        % El usuario 1 trata la interferencia como ruido
        % Calculas el simbolo mas cercano dentro de l a PAM
        for nSimbPam = 1:Npam
            % Calculo de la distancia a cada punto de la costelacion M-PAM
            ydist(nSimbPam,:) = abs(y_1_norm - simb(nSimbPam));
        end
        [Vmin simDec] = min(ydist);
        BER1_noma(n,p) = mean(simDec ~= simbValue(1,:));
        
        %% ---------- User 2 ---------- %%
        y_2 = (s(1,:)*a1 + s(2,:)*a2)*h2_noma*Pled(p)+randn(1,lenSec);
        y_2_norm = DC*y_2/mean(y_2);
        
        % Calculas el simbolo a partir de la senal todal, el cual debe obtener el
        % del usuario 1
        for nSimbPam = 1:Npam
            % Calculo de la distancia a cada punto de la costelacion M-PAM
            ydist(nSimbPam,:) = abs(y_2_norm - simb(nSimbPam));
        end
        [Vmin simDec] = min(ydist);
        s1_dec = simb(simDec);
        
        % SIC
        interferencia_1 = s1_dec*a1*Pled(p);
        y_2_noma = y_2 - h2_noma*interferencia_1;
        % Volvemosa a normalizar la senal NOMA
        y_2_noma_norm = DC*y_2_noma/mean(y_2_noma);
        
        % Calculas el simbolo a partir de la senal todal, el cual debe obtener el
        % del usuario 1
        for nSimbPam = 1:Npam
            % Calculo de la distancia a cada punto de la costelacion M-PAM
            ydist(nSimbPam,:) = abs(y_2_noma_norm - simb(nSimbPam));
        end
        [Vmin simDec] = min(ydist);
        s2_dec = simb(simDec);
        BER2_noma(n,p) = mean(simDec ~= simbValue(2,:));
    end
end

BER1_noma_plot = mean(BER1_noma)
BER2_noma_plot = mean(BER2_noma)


semilogy(Pled_dB,BER1_noma_plot,'-.b')
hold on
grid on
semilogy(Pled_dB,BER2_noma_plot,'-.r')
legend('Usuario 1', 'Usuario 2')
print('semilogyBER','-dpng')
close




