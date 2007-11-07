function t = textureindex(odf,varargin)
% caclulate texture index of ODF
%
% The tetxure index of an ODF f is defined as:
%
% $$ t = -\int f(g)^2 dg$$
%
%% Input
%  odf - @ODF 
%
%% Output
%  texture index - double
%
%% Options
%  resolution - resolution of the discretization
%  fourier    - use Fourier coefficients 
%  bandwidth  - bandwidth used for Fourier calculation
%
%% See also
% ODF/entropy ODF/volume ODF_index ODF/calcfourier

if check_option(varargin,'fourier')
  
  t = sum(abs(fourier(odf,varargin{:})).^2);
  
else
  % get resolution
  res = get_option(varargin,'RESOLUTION',2.5*degree);

  % discretisation
  S3G = SO3Grid(res,odf(1).CS,odf(1).SS);

  % eval odf
  t = eval(odf,S3G);
  t = sum(t.^2)/GridLength(S3G);
end
