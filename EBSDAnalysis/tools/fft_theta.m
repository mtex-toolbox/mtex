function pth = fft_theta(th)
% project theta to interval [0,0.5]

th = mod(th,2*pi);
pth = th /2/pi;

