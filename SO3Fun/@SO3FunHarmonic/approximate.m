function SO3F = approximate(f, varargin)
% Approximating an SO3FunHarmonic from a given SO3Fun by evaluating on a
% quadrature grid and doing quadrature.
%
% Syntax
%   SO3F = SO3FunHarmonic.approximate(odf)
%   SO3F = SO3FunHarmonic.approximate(odf,'bandwidth',48)
%
% Input
%  odf   - @SO3Fun, @function_handle
%
% Output
%  SO3F - @SO3FunHarmonic
%  lsqrParameters - double
%
% Options
%  bandwidth       - maximal harmonic degree (Be careful by setting the bandwidth by yourself, since it may yields undersampling)
%
% See also
% SO3FunHarmonic SO3FunHarmonic/quadrature SO3VectorFieldHarmonic/approximate SO3FunRBF/approximate


if isa(f,'function_handle')
  [SRight,SLeft] = extractSym(varargin);
  f = SO3FunHandle(f,SRight,SLeft);
end

% do Quadrature
f_hat = calcFourier(f,varargin{:});  % more efficient in case of SO3FunRBF
SO3F = SO3FunHarmonic(f_hat,f.SRight,f.SLeft,varargin{:});

end