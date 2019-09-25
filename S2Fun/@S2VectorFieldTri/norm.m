function sF = norm(sVF)
% pointwise norm of the vectorfield
%
% Syntax
%   norm(sVF)
%
% Output
%   sF - S2FunTri
%

sF = S2FunTri(sVF.tri,norm(sVF.values));

end
