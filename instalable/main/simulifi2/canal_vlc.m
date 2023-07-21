function [h] = canal_vlc(posLED, pos_usu,alfa, theta, A, R, m,Ts,FoV)

% Distancia entre led y usuario
d_led =  sqrt(sum((posLED - pos_usu).^2));
% Vector entre led y usuario
V = posLED - pos_usu;
% Vector de radiación
U = [0 0 1];
% Vector de apuntamiento del usuario
n = [sin(theta)*cos(alfa) sin(theta)*sin(alfa) cos(theta)];

% Angulo de radiación
phi = acos(dot(V,U)/(norm(V)*norm(U))); 
% Angulo de incidencia
psi = acos(dot(V,n)/(norm(V)*norm(n)));
if psi >pi/2
    psi = psi- pi;
end
% Canal óptico
if abs(psi)<FoV
    h = R*((m+1)*A/(2*pi*(d_led^2)))*Ts*abs(cos(phi))^m*abs(cos(psi));
else
    
    h= 0;
end

end

