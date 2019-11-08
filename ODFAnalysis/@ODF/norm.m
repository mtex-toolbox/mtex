function t = norm(odf,varargin)
% caclulate texture index of ODF
%
% The normx of an ODF f is defined as:
%
% $$ t = \sqrt(-\int f(g)^2 dg)$$
%
% Input
%  odf - @ODF 
%
% Output
%  texture index - double
%
% Options
%  resolution - resolution of the discretization
%  fourier    - use Fourier coefficients 
%  bandwidth  - bandwidth used for Fourier calculation
%
% See also
% ODF/textureindex ODF/entropy ODF/volume ODF/ODF ODF/calcFourier

% decide which method to use
if all(cellfun(@(x) isa(x,'FourierComponent'),odf.components)) ...
  || odf.bandwidth < 32
  default = 'Fourier';
else
  default = 'quadrature';
end

method = get_option(varargin,'method',default);

switch method
  case 'Fourier'
    odf = FourierODF(odf);
    t = abs(odf.weights) * odf.components{1}.norm;
  case 'quadrature'
    
    % get approximation grid
    S3G = extract_SO3grid(odf,varargin{:},'resolution',5*degree);

    % eval ODF
    t = sqrt(mean(eval(odf,S3G(:)).^2));
    
end
