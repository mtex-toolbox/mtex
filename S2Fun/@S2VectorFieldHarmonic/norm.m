function sF = norm(sVF,varargin)
% pointwise norm of the vectorfield
%
% Syntax
%   norm(sVF)
%
% Output
%  sF - S2FunHarmonic
%

sF = S2FunHarmonic.quadrature(@(v) norm(sVF.eval(v)),varargin{:});

end
