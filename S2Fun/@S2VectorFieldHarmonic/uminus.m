function sVF = uminus(sVF)
% the negative of a spherical vector field
%
% Syntax
%
%   sVF = -sVF
%
% Input
%  sVF - @S2VectorFieldHarmonic
%
% Output
%  sVF - @S2VectorFieldHarmonic

sVF.sF = -sVF.sF;

end
