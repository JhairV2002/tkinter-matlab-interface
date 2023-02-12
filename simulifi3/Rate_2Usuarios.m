% Alejandro Villamar - Universidad Israel %
% Calculo Rate 2 usuarios
% Calculo para realizar figura 2:
% Mismos canales:
% Canales de los usuariosx
clear
close all 

n_users = 2;
h = zeros(1,n_users)


%% ------------ NOMA ------------ %%
% La variable nu, marca la diferencia entre los valores. 
% Prueba a ir cambiando este valor y vas a ver como funciona NOMA
nu = 0.025;
h(1) = 1*nu;
h(2) = 1;
% Ahora hay que ir calculando el Rate para diferentes valores de asignacion
% de potencia:
n_points = 1000;
coef_potencia = zeros(n_users,n_points);
coef_potencia(1,:) = sqrt(linspace(0,1,n_points));
coef_potencia(2,:) = sqrt(linspace(1,0,n_points));
% coef_potencia(1,:) = linspace(0,1,n_points);
% coef_potencia(2,:) = linspace(1,0,n_points);
% Para una SNR dada
rho = 50; % P_elec/No_B
for i=1:n_points
    R_1(i) = log2(1 + (coef_potencia(1,i)*h(1))^2 / ((coef_potencia(2,i)*h(1))^2 + 1/(10^(rho*0.1))));    
    R_2(i) = log2(1 + 10^(rho*0.1)*((coef_potencia(2,i)*h(2))^2));
end

%% ------------ Orthogonal, cada usuario se transmite individualmente ------------ %%
alfa_orth = 0:0.01:1;
R_1_orth = alfa_orth.*log2(1 + 10^(rho*0.1)*h(1)^2);
R_2_orth = (1-alfa_orth).*log2(1 + 10^(rho*0.1)*h(2)^2);
    
plot(R_1,R_2,'-b')
xlabel('Rate user 1')
ylabel('Rate user 2')
grid on
hold on 
plot(R_1_orth,R_2_orth,'-r')
legend('NOMA','Orthogonal')
print('Barplot2u','-dpng')
close


