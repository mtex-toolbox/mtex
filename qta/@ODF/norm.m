function t = norm(odf,varargin)
% caclulate texture index of ODF
%
% The normx of an ODF f is defined as:
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
% ODF/entropy ODF/volume ODF_index ODF/calcFourier

t = norm(Fourier(odf,'l2-normalization',varargin{:})).^2;
  
