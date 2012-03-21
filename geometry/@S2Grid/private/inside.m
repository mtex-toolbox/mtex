function ind = inside(rho,minrho,maxrho)

minr = mod(minrho+1e-6,2*pi)-3e-6;
maxr = mod(maxrho-1e-6,2*pi)+3e-6;
if minr < maxr
  ind = ~(mod(rho-1e-6,2*pi) < minr | mod(rho+1e-6,2*pi) > maxr);
else
  ind = ~(mod(rho-1e-6,2*pi) < minr & mod(rho+1e-6,2*pi) > maxr);
end
