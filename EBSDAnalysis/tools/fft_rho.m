function prho = fft_rho(rho)
% project rho to interval [-1,1)

rho = mod(rho+pi,2*pi)-pi;
prho = rho/2/pi;

prho(prho>=0.5) = -0.5;
