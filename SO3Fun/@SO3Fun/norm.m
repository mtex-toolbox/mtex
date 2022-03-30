function t = norm(odf,varargin)
% caclulate texture index of SO3Fun
%
% The norm of an ODF f is defined as:
%
% $$ t = \sqrt(-\int f(g)^2 dg)$$
%
% Input
%  odf - @SO3Fun 
%
% Output
%  texture index - double
%
% Options
%  bandwidth  - bandwidth used for Fourier calculation
%
% See also
% ODF/textureindex ODF/entropy ODF/volume ODF/ODF ODF/calcFourier


%     % get approximation grid
%     S3G = extract_SO3grid(odf,varargin{:},'resolution',5*degree);
% 
%     % eval ODF
%     t = sqrt(mean(eval(odf,S3G(:)).^2));


f = SO3FunHarmonic(odf,varargin{:});
t = f.norm;
    
end
