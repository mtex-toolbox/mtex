function e = entropy(odf,varargin)
% caclulate entropy of ODF
%
% The entropy of an ODF f is defined as:
%
% $$ e = - \int f(g) \ln f(g) dg$$
%
%
% Input
%  odf - @ODF 
%
% Output
%  entropy - double
%
% Options
%  resolution - resolution of the discretization
% See also
% ODF/textureindex ODF/volume

% discretisation
S3G = extract_SO3grid(odf,varargin{:});

% eval odf
%disp(' evaluate odf');
e = eval(odf,S3G,varargin{:});
e = - real(nansum(e(:) .* log(e(:)))/length(S3G));
