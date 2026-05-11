function varargout = eig(sF)
% eigen value of a spherical function
%
% Syntax
%   [V,E] = eig(sF)
%
% Input
%  sF - @S2FunHarmonic
%
% Output
%  V - eigen @vector3d
%  E - eigen values
%



%sFM = S2FunHarmonic.quadrature(M,'bandwidth',2);

%M = real(dot(sF.^2,sFM));

%M = S2FunHarmonic.quadrature(@(v) sF.eval(v).*[v.x.^2 v.x.*v.y v.x.*v.z v.y.^2 v.y.*v.z v.z.^2],'bandwidth',0);

M = @(v) [v.x.^2 v.x.*v.y v.x.*v.z v.y.^2 v.y.*v.z v.z.^2];

sFM = S2FunHandle(@(v) M(v(:)).* sF.eval(v(:)));

M = sFM.mean;

M = reshape(real(M([1 2 3 2 4 5 3 5 6])),3,3);

[varargout{1:nargout}] = eig3(M);

end
