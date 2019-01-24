function pdf = calcPDF(component,h,r,varargin)
% calculate pole figure from Fourier coefficients

% use only even Fourier coefficients?
even = check_option(varargin,'antipodal') || h.antipodal || component.CS.isLaue;
if nargin > 2, even = even || r.antipodal; end
even = 1 + double(even);

% bandwidth
L = get_option(varargin,'bandwidth',component.bandwidth);
L = min(L,component.bandwidth);

if length(h) == 1  % pole figures
  sym = component.SS;
else
  sym = component.CS;
end

ipdf_hat = cumsum([0,2*(0:L)+1]);

% calculate Fourier coefficients of the pole figure
for l = 0:even:L
  if length(h) == 1  % pole figures
    P_hat(1+ipdf_hat(l+1):ipdf_hat(l+2)) = reshape(...
      component.f_hat(1+deg2dim(l):deg2dim(l+1)),2*l+1,2*l+1).' ./(2*l+1) ...
      * 4 * pi * sphericalY(l,h).';
    
  elseif  length(r) == 1 % inverse pole figures
    P_hat(1+ipdf_hat(l+1):ipdf_hat(l+2)) = reshape(...
      conj(component.f_hat(1+deg2dim(l):deg2dim(l+1))),2*l+1,2*l+1) ./(2*l+1) ...
      * 4 * pi * sphericalY(l,r).';
  else
    error('Either h or r should be a single direction!');
  end
end

% setup a spherical harmonic function
pdf = S2FunHarmonicSym(conj(P_hat(:)),sym);

% evaluate if required
if length(h) > 1
  pdf = pdf.eval(h); 
elseif nargin>2 && length(r) > 1
  pdf = pdf.eval(r); 
end
