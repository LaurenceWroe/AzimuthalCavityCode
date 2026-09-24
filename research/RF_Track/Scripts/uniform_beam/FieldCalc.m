


E_g = 1;
f_rf = 705e6;
k_rf = 2*pi*f_rf/2.9979e8;
L = 0.2125; g = L/2; a = 0.4*L;
N_z = 201; z_lim = 1;
##z = linspace(0,z_lim,N_z);
z = linspace(-z_lim,z_lim,N_z);
r = 0;

k_spacing = 0.01; k_upper = 1400;
k_1 = 0:k_spacing:k_rf; k_1 = [k_1 k_rf];

k_2 = k_rf:k_spacing:k_upper;

kappa_l_1 = sqrt(k_rf^2-k_1.^2);
kappa_l_2 = sqrt(k_2.^2-k_rf^2);
E_1 = zeros(1,length(z));
E_2 = zeros(1,length(z));

n =0;
for ii = 1:length(z)
   if mod(n,2) == 0
       E_1(ii) = E_g*g/pi*trapz(k_1,sinc(k_1*g/2).*besselj(0,kappa_l_1*r)./besselj(0,kappa_l_1*a).*(1-2*cos(k_1*L)+2*cos(2*k_1*L)).*k_1.^n.*(-1)^(n/2).*cos(k_1.*z(ii)));
       E_2(ii) = E_g*g/pi*trapz(k_2,sinc(k_2*g/2).*besseli(0,kappa_l_2*r)./besseli(0,kappa_l_2*a).*(1-2*cos(k_2*L)+2*cos(2*k_2*L)).*k_2.^n.*(-1)^(n/2).*cos(k_2.*z(ii)));
   else
       E_1(ii) = E_g*g/pi*trapz(k_1,sinc(k_1*g/2).*besselj(0,kappa_l_1*r)./besselj(0,kappa_l_1*a).*(1-2*cos(k_1*L)+2*cos(2*k_1*L)).*k_1.^n.*(-1)^((n+1)/2).*cos(k_1.*z(ii)));
       E_2(ii) = E_g*g/pi*trapz(k_2,sinc(k_2*g/2).*besseli(0,kappa_l_2*r)./besseli(0,kappa_l_2*a).*(1-2*cos(k_2*L)+2*cos(2*k_2*L)).*k_2.^n.*(-1)^((n+1)/2).*cos(k_2.*z(ii)));
   end

end



figure(); hold all;
plot(z,E_1)
plot(z,E_2)
plot(z,E_1+E_2,'k','Linewidth',2)

return
g = 0.02;
E_g = 5.3e7;
f_rf = 3.08351e9;
k_rf = 2*pi*f_rf/2.9979e8;
L_cav = 1;
N_z = 201;z = linspace(-L_cav,L_cav,N_z);

N = 10000; k_upper = 1000;
k_1 = linspace(0,k_rf,N);
k_2 = linspace(k_rf,k_upper,N);

kappa_l_1 = sqrt(abs(k_1.^2-k_rf^2));
kappa_l_2 = sqrt(abs(k_2.^2-k_rf^2));
E_1 = zeros(1,length(z));
E_2 = zeros(1,length(z));
for ii = 1:length(z)
    E_1(ii) = E_g*g/pi*trapz(k_1,sin(k_1*g/2)/(k_1*g/2)./besselj(0,kappa_l_1).*cos(k_1.*z(ii)));
    E_2(ii) = E_g*g/pi*trapz(k_1,sin(k_1*g/2)/(k_1*g/2)./besseli(0,kappa_l_2).*cos(k_1.*z(ii)));
end

figure(); hold all;
plot(z,E_1)
plot(z,E_2)
