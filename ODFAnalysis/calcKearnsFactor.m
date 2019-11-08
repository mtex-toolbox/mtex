function k = calcKearnsFactor(pdf,varargin)
%
% Syntax
%
%   k = calcKearnsFactor(odf,N,h)
%   k = calcKearnsFactor(pdf,N)
%
% Input
%  odf - orientation distribution function, @ODF
%  h - crystal direction, @Miller (default is [0001])
%  pdf - pole density function, @S2Fun 
%  N - normal direction @vector3d, (default is Z)
%
% Output
%  k - Kearns texture factors

% if ODF is provided compute pole figure
if isa(pdf,'ODF')
  h = getClass(varargin,'Miller',Miller(0,0,0,1,pdf.CS));
  pdf = pdf.calcPDF(h);
end

% get normal direction
N = getClass(varargin,'vector3d',vector3d.Z);

if check_option(varargin,'quadrature') % slow quadrature based approach

  r = equispacedS2Grid('resolution',2.5*degree);
    
  k = mean( pdf.eval(r) .* dot_outer(r,N).^2).';

else % fast Fourier approach
  
  %
  A = [2*sqrt(pi)/3,0,4/3*sqrt(pi)];
  psi = kernel(A ./ A(1) / 3);

  f = conv(pdf,psi);

  k = f.eval(N);

end


% sF = S2FunHarmonic.quadrature(@(v) dot(v,zvector).^2);
%psi = kernel(A ./ A(1));

% psi should actually be defined by
% psi = S2KernelHandle(@(x) x^2);
