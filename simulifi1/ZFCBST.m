function [W,S_tot] = ZFCBST(h,M,t,N,r)
%% Función que genera los pesos y canales tras aplicar el esquema ZF-CBST
%
% Parámetros de entrada
% ---------------------
%
% M --> Cantidad de BS
% t --> Cantidad de antenas por BS
% N --> Cantidad de receptores
% r --> Cantidad de antenas por receptor


H = h;

%% e) ZF según método de Spencer
P=zeros(N,r); % potencias para cada bit de cada usuario: cada fila un usuario
W=zeros(M*t,N*r); % pesos para cada bit de cada usuario: cada columna un usuario
S_tot=zeros(r,N);  % autovalores para cada bit (stream) de cada usuario: cada columna un usuario
R=zeros(N,1); % rate conseguidas por cada usuario (columna)
for usu=1:N,
    rk=rank(removerows(H,[(usu-1)*r+1:r*usu]));   % H1_no=removerows(H,[1:r]  sin las filas del usuario
    [U,S,V]=svd(removerows(H,[(usu-1)*r+1:r*usu]));
    V1_0=V(:,rk+1:end);
    Hk=H((usu-1)*r+1:usu*r,:);   % solo filas del usuario
    [U,S,V]=svd(Hk*V1_0);
    S_tot(:,usu)=S(1);
    rk=rank(Hk*V1_0);
    V1_1=V(:,1:rk);
    M1=V1_0*V1_1;
    W(:,(usu-1)*r+1:usu*r)=M1;
end % usu

