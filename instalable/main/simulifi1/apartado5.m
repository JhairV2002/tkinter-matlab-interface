
% Alejandro Villamar - Universidad Israel %
%% ----- Parametros de simulacion ----- %%
function apartado5(lum, area, leds, users, angle)
% Ancho de banda
B = 20*10^6; % 20 MHz estándar 802.11a
% Area del fotodiodo
A = lum/(area^2); % La intensidad luminosa se mide en 1 [lumen / pie^2] 
% Ruido
No = 10^-21; % A/Hz [Haas]
N = No*B;
% ---.. Transmisor ..--- %
% Potencia optica
Pled_dB = -6:2:14; % dB
Pled = 10.^(Pled_dB*0.1) % unidades naturales
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
FoV = 60*pi/180;
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





% Variable de simulacion
nChannels = 100; % Numero de situaciones distintas (canales) que simulamos
nsim = 100; % Numero de simbolos de la trama
BER1 = zeros(length(Pled_dB),nChannels);
H = zeros(L,K);
for p = 1:length(Pled)
    
    for c = 1:nChannels
        [p length(Pled) c nChannels]
        pos_usu = [(rand(K,2)-0.5)*4+2.5, ones(K,1)*0.85];
        
        
        for l = 1:L
            for usu = 1:K
                % Canal del usuario
                % Fotodiodos apuntando al techo alfa = 0, theta = 0
                H(l,usu) = canal_vlc(LED_pos(l,:), pos_usu(usu,:),0, 0, A, R, m, k, Ts, FoV);
            end
        end

        
        % Canal normalizado en ruido
        H = Pled(p)*H/sqrt(N);
        % h corresponde a un canal 4x4
        
        % Zero Forcing
        Hzf = H';
        [Wzf,S_tot] = ZFCBST(Hzf,L,1,K,1);
        
        
        %Postcoding+
        Udec = inv(Hzf*Wzf);
        Udec = Udec/norm(Udec);
        
        % Symbols 2-PAM
        Npam = 2;
        simb = [0 1];
        % Dado que el canal está normalizado, el ruido tiene una varianza de 1
        simbValue = round(rand(K,nsim)*(Npam-1)+1);
        s = simb(simbValue);
        
        % Symbols 4-PAM
        %         Npam = 4;
        %         simb = [0 1/3 2/3 1];
        %         % Dado que el canal está normalizado, el ruido tiene una varianza de 1
        %         simbValue = round(rand(K,nsim)*(Npam-1)+1);
        %         s = simb(simbValue);
        
        % Symbols 8-PAM
%         Npam = 8;
%         simb = linspace(0,1,Npam);
%         % Dado que el canal está normalizado, el ruido tiene una varianza de 1
%         simbValue = round(rand(K,nsim)*(Npam-1)+1);
%         s = simb(simbValue);

        yd_ZF = zeros(K,nsim);
        for sim = 1:nsim
            % Ruido con varianza 1 porque el canal esta normalizado
            % En cada simulacion un ruido distinto
            z_ZF = randn(K,1);
            
            y = Hzf*Wzf*s(:,sim) + z_ZF;
            
            %Guarda los valores
            yd_ZF(:,sim) = Udec*y;
        end
         
        
        %% User 1
        % Normalizamos al usuario 1
        yd_norm = mean(s(1,:))*yd_ZF(1,:)/mean(yd_ZF(1,:));
        
        % Seleccionamos el usuario 1
        ydist = zeros(Npam, nsim);
        for nSimbPam = 1:Npam
            ydist(nSimbPam,:) = abs(yd_norm - simb(nSimbPam));
        end
        % Calculamos la distancia mas pequena al simbolo
        [Vmin simDec] = min(ydist);
        BER1(p,c) = mean(simDec ~= simbValue(1,:));
        
    end
end


semilogy(Pled_dB,mean(BER1,2),'r')

%% Mapas de color

figure(1)
surf(real(BER1),real(BER1),'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('BER1')
print('ydist','-dpng')
close
end