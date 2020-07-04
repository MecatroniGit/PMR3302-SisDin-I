close all; 
clear all; 
clc;

%% Constantes

%Constantes inerciais do dummy
m_i = 5.5;
m_c = 6.1;
J_c = 0.3;
m_t = 44.5;
J_t = 1.5;
L_t = 0.35;
L_p = 0.5;

%Air-Bag
%k_ab = @(t) 0;
%c_ab = @(t) 0;
k_ab = @(t) (104)*(t>0.2);
c_ab = @(t) (50.4)*(t>0.2);

%Pesco�o
k_p = 20200;
c_p = 266;
k_rp = 915;
c_rp = 34;

%Articula��o da cintura
k_ri = 328;
c_ri = 724;

%Cinto de Seguran�a: Cinto de tronco e de cintura
%k_s = 50000;
%c_s = 3000;
%k_s = 0;
%c_s = 0;
k_s = 1815;
c_s = 568;

%k_i = 50000;
%c_i = 1100;
%k_i = 0;
%c_i = 0;
k_i = 1815;
c_i = 200;

%Demais constanres
a = @(t) (90)*(t<0.2); % A for�a inercial atua em 200ms
g = 9.8;

%% Equa��o

%Defini��o do tempo de an�lise:
ti = 0;
h = 0.001;
tf = 0.5;
tspan = ti:h:tf;

%Condi��es iniciais:
Y0 = [0; 0; 0; 0; 0; 0; 0; 0; L_p + 0.2; 0; 0; 0];
% x_i: Y(1) Y(2)
% x_t: Y(3) Y(4)
% theta_t: Y(5) Y(6)
% x_c: Y(7) Y(8)
% y_c: Y(9) Y(10)
% theta_c: Y(11) Y(12)

%Sistema de equa��es:
sistema = @(t,Y)[(Y(2));
          ((1/m_i)*(m_i*a(t) - c_i*Y(2) - k_i*Y(1)));
          (Y(4));
          ((1/m_t)*(m_t*a(t) - (c_s + c_ab(t))*Y(4) - c_p*(Y(4)-Y(8)) - (k_s + k_ab(t))*Y(3) - k_p*(Y(7) - Y(3) + (L_p - L_t)*sin(Y(5)) ) ));
          (Y(6));
          ((1/J_t)*(-k_ri*Y(5) - k_rp*(Y(5) - Y(11)) - k_p*(Y(7) + Y(9) - Y(3) + (L_p - L_t)*(cos(Y(5))+ sin(Y(5)))) - c_ri*Y(6) -  c_rp*(Y(6) - Y(12))));
          (Y(8));
          ((1/m_c)*(m_c*a(t) -  k_p*(Y(7)- Y(3)) - (Y(7)- Y(3))*k_ab(t)- c_p*(Y(8)-Y(4)) -(Y(8))*c_ab(t)));
          (Y(10));
          ((1/m_c)*(-k_p*(Y(9) - (L_p)*(cos(Y(5))))- c_p*(Y(10))));
          (Y(12));
          ((1/J_c)*(-k_rp*(Y(11) - Y(5)) - c_rp*(Y(12) - Y(6))))];

[t, Y] = ode45(sistema, tspan, Y0);

%Gr�ficos
figure(1)
plot(t, Y(:,7:8))
grid on
str = {'$$ x_c (m) $$','$$ \dot{x_c} (m/s) $$'};
legend(str, 'Interpreter','latex', 'Location','NW');
title('An�lise da cabe�a sem air-bag e cinto - eixo x');
xlabel('t(s)') 
figure(2)
plot(t, Y(:,9:10))
grid on
str = {'$$ y_c (m) $$','$$ \dot{y_c} (m/s) $$'};
legend(str, 'Interpreter','latex', 'Location','NW');
title('An�lise da cabe�a sem air-bag e cinto -  eixo y');
xlabel('t(s)') 

%Acelera��o da cabe�a:
Vc2 = (Y(:,8).^2 )+ (Y(:,10).^2) ;    % Velocidade resultante quadratica
Vc = Vc2.^(1/2);                      % Velocidade resultante
acc = (((diff(Vc)./diff(t)))./g);  % Acelera��o g: derivando a Velocidade

figure(3)
plot(t(1:tf/h), acc)
title('Acelera��o g sem air-bag e cinto')
xlabel('t(s)') 
ylabel('a(g)')

%C�lculo da HIC_15
HIC = 0;
k = 250;

for n = ti:h:tf-16*h-250*h
    A = acc(k:k+14);
    HIC_a = ((trapz(A)*(1./(15)))^2.5)*15;  %Defini��o de HIC para 15ms
    HIC_t = HIC_a;
    if abs(HIC_a) > HIC
        HIC = abs(HIC_a);
    end 
    k = k + 1;
end

HIC


 
    
    
    
    
