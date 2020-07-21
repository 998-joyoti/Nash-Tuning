close all; clear all; clc;

% define pant transfer function
s = tf('s');
% 2nd order system
%sys = (exp(-4*s))/(10*s+1)   %Example-1
%sys = 1/(s^4 + 4*s^3+ 6*s^2+ 4*s+ 1); %Example-2
sys = 1/(s+1)^20;%Example-3

%sys = 1/(s^2+20*s+20) %random example
% Obtain step response of the system
[y,t] = step(sys);
plot(t,y,'LineWidth',2); grid on; xlabel('Time(s)'); ylabel('Amplitude');
title('Open loop Response');

yp = diff(y);
ypp = diff(y,2);
%plot (ypp)
% Find the root using FZERO(Finds Inflection point ----- verify pakka pakka)
t_infl = fzero(@(T) interp1(t(2:end-1),ypp,T,'linear','extrap'),0)
y_infl = interp1(t,y,t_infl,'linear')
hold on;
plot(t_infl,y_infl,'ro');

%code to plot tangent 
h = mean(diff(t));
dy = gradient(y, h);
[~,idx] = max(dy);
b = [t([idx-1,idx+1]) ones(2,1)] \ y([idx-1,idx+1]);            % Regression Line Around Maximum Derivative
tv = [-b(2)/b(1); (1-b(2))/b(1)];                               % Independent Variable Range For Tangent Line Plot
f = [tv ones(2,1)] * b;                                         % Calculate Tangent Line

plot(tv, f, '-r','LineWidth',1.5)
ylim([0 max(y)]);

L = tv(1)%equal to delay time for us(verified)
T = tv(2) - tv(1)% should be equal to tp/K in order to verify the coefficients 

% PID parameters
a = L/T
Kp = 1.2/a
Ti = 2*L
Td = L/2

% cont = Kp(1 + 1/(s*Ti) + s*Td);
cont = Kp + Kp/(s*Ti) + Kp*Td*s;

cl_sys = feedback(cont*sys,1);
t = [0:0.01:3];
[yc,tc] = step(cl_sys,t);
figure;
plot(tc,yc,'LineWidth',2); xlabel('Time(s)'); ylabel('Amplitude');
title('Zeigler Nicholas (PRC method)Optimized Closed Loop Response');
grid on;
