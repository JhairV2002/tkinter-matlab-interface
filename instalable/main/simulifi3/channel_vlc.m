function [h] = channel_vlc(LED_pos,pos_usu,alfa,beta,A,R,k,Tr_ang,Ts)
% Inputs
% ------
% pos_led: LED position [x,y,z]
% pos_usu: User position [x,y,z]
% alfa: Angle of the photodiode and the vertical
% beta: Angle of the phtoodiode with the floor
% A: Area of detection (typically 15mm2)
% R: Responsitivity of the photodiode (typically R = 0.53)
% k: Directivity of the field of view (FoV) (typically k = 1.437)
% Tr_ang: Transmitter semiangle (typically 60?)
% Ts: Filter response

% Output
% ------
% h: channel


% Distance between LED and user
d_led =  sqrt(sum((LED_pos - pos_usu).^2));
% VEctor between LED and user
V = LED_pos - pos_usu;
% Irradiance vector (vertical illumination)
U = [0 0 1];
% Order m of the transmitter semiangle
m= -log(2)/log(cos(Tr_ang*pi/180));


% Normal vector of the photodiode for alfa and beta
n = [sin(beta)*cos(alfa) sin(beta)*sin(alfa) cos(beta)];
% Irradiation angle
phi = acos(dot(V,U)/(norm(V)*norm(U))); 
% Incidence angle
psi = acos(dot(V,n)/(norm(V)*norm(n)));


% channel
h =R*((m+1)*A/(2*pi*(d_led^2)))*Ts*abs(cos(phi))^m*abs(cos(psi))^k;
h = real(h);
end

