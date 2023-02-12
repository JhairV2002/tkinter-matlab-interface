clear
close all
clear all

% Alejandro Villamar - Universidad Israel %
%% ----- Parametros de simulacion ----- %%
% Ancho de banda
BW = 20*10^6; % 20 MHz estándar 802.11a
% Area del fotodiodo
A = 15/(1000^2); % La intensidad luminosa se mide en 1 [lumen / pie^2] 
% Ruido
No = 10^-22; % A/Hz [Haas]
N = No*BW;

% ---.. Transmisor ..--- %
% Potencia optica
Pled = 10;
% Angulo de radiacion
ang_rad = 100;
m= -log(2)/log(abs(cos(ang_rad*pi/180)));
k = 1.4738;
% ---.. Fotodiodo ..--- %
% Responsividad (capacidad de respuesta)
R = 0.53;

% Ganancia del filtro
n = 1.5; 
% FoV (Campo de visión)
fov =  70*pi/180;
% Respuesta del filtro
Ts = (n^2)/(sin(fov)^2)

% Radiacion (perpendicular al suelo)
Pled_dB = 10; 
Pled = 10^(Pled_dB*0.1)
m= -log(2)/log(cos(60*pi/180));
k = 1.4738;

% Posicion de las bombillas LED
L = 4; % 4 LED bombillas;
K = 1, % 4 usuarios
h = 0.85;
LED_pos = [3.5, 3.5, 3;
    1.5, 3.5, 3;
    3.5, 1.5, 3;
    1.5, 1.5, 3]



% vector de irradiación
U = [0 0 1];

% Fotodetector piramidal
alfa = [45 135 225 315]*(pi/180);
beta = 45*(pi/180);


% Creamos el mapa
grano = 0.05; % define la precision de nuestro mapa de color
[Ax,Ay] = meshgrid([0:grano:5]);
H = zeros(L);

% Rate variables
R_bia = zeros(size(Ax));
R_egc = zeros(size(Ax));
R_rmc = zeros(size(Ax));
R_opc = zeros(size(Ax));
R_mmse = zeros(size(Ax));
R_bia_int = zeros(size(Ax));
% Valor promedio de las veces que hay varios usuarios bajo la misma luz
Emean = mean((1./(round(rand(1,100000)*(K-1))+1)));
Ad = (10e-2)*randn;
for x = 1:length(Ax)
    tiempo = [x length(Ax)]
    for y = 1:length(Ay)
        H = zeros(L);
        H_int = zeros(L);

        pos_usu = [Ax(x,x) Ay(y,y) 0.85];
        pos_usu_int = [Ax(x,x)+Ad*randn Ay(y,y)+Ad*randn 0.85];
        % Canal del usuario de referencia
        for led = 1:L
            d_led =  sqrt(sum((LED_pos(led,:) - pos_usu).^2));
            d_led_int =  sqrt(sum((LED_pos(led,:) - pos_usu_int).^2));
            
            V = LED_pos(led,:) - pos_usu;
            V_int = LED_pos(led,:) - pos_usu;
            
            %saveD(x,y) = d_led;
            for mod = 1:L % Modo del receptor, % NOTA, en teoria la posicion del LED varia un poco      
   
                n = [sin(beta)*cos(alfa(mod)) sin(beta)*sin(alfa(mod)) cos(beta)];
                phi = acos(dot(V,U)/(norm(V)*norm(U))); % Angulo de radiacion
                psi = acos(dot(V,n)/(norm(V)*norm(n))); % Angulo de incidencia
                H(led,mod) =0.53*((m+1)*A/(2*pi*(d_led^2)))*abs(acos(phi))^m*Ts*abs(cos(psi))^1.437;
                
                phi_int = acos(dot(V_int,U)/(norm(V_int)*norm(U))); % Angulo de radiacion
                psi_int = acos(dot(V_int,n)/(norm(V_int)*norm(n))); % Angulo de incidencia
                H_int(led,mod) =0.53*((m+1)*A/(2*pi*(d_led_int^2)))*abs(acos(phi_int))^m*Ts*abs(cos(psi_int))^1.437;
            end
        end
        
        H = real(H);

        
        % Strongest AP
        [Vmax Lmax] = max(sum(H,2));
        
        
        %% Equal gain combining %% Combinación de igual ganancia %%
        SINR_egc = (Pled*sum(H(Lmax,:))^2)/(Pled*(( sum(sum(H)) - sum(H(Lmax,:))))^2  + N*4);
        R_egc(x,y) = BW*log2(1+SINR_egc);

        
        %% Maximum ratio combining %% Combinación de relación máxima %%
        % Calcular el peso de cada usuario
        w = zeros(1,L);
        denom = 0;
        num = 0;
        for pd = 1:L
            w(pd) = ((Pled*H(Lmax,pd))^2)/( (Pled*(sum(H(:,pd))-H(Lmax,pd)))^2 + N);
        end
   w = w/norm(w);
        for pd = 1:L
            denom = denom + (Pled*w(pd)*(sum(H(:,pd))-H(Lmax,pd)))^2 + w(pd)^2*N;
        end
        num = (Pled*sum(w.*H(Lmax,:)))^2;
        SINR_rmc = num/denom;
                 
        R_rmc(x,y) = BW*log2(1+SINR_rmc);

        
        

        
        %% Blind Interference Alignment %% Alineación de Interferencia Ciega %%
        H = H';
        Bbia = (1/(L+K-1));
        Rz = (2*K-1)*eye(L);
        Rz(L,L) =1;
        Pstr = Pled;
        R_bia(x,y)= BW*Bbia*log2(det(eye(L)+Pstr*(H*H')/N*inv(Rz)));
        

    end
end


%% Mapas de color
figure(1)
surf(Ax,Ay,real(R_bia)/10^6,real(R_bia)/10^6,'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Blind Interference Alignment - User rate [Mbps]')
print('Blind Interference Alignment','-dpng')
close

figure(2)
surf(Ax,Ay,real(R_egc)/10^6,real(R_egc)/10^6,'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Equal Gain Combining - User rate [Mbps]')
print('Equal Gain Combining','-dpng')
close

figure(3)
surf(Ax,Ay,real(R_rmc)/10^6,real(R_rmc)/10^6,'EdgeColor','none')
colorbar
xlabel('Room x [m]')
ylabel('Room y [m]')
zlabel('Maximum Ratio Combining - User rate [Mbps]')
print('Maximum Ratio Combining','-dpng')
close









