function ind = rhoInside(rho,minRho,maxRho)

minr = mod(minRho+1e-6,2*pi)-3e-6; % in [-2e-6,2*pi-3e-6]
maxr = mod(maxRho-1e-6,2*pi)+3e-6; % in [2e-6,2*pi+3e-6]

if minr < 0
  rho = mod(rho+1e-6,2*pi);
else
  rho = mod(rho-1e-6,2*pi);
end

if minr < maxr
  ind = rho > minr & rho < maxr;
else
  ind = rho > minr | rho < maxr;
end
