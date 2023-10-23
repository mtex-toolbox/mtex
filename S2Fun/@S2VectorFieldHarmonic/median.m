function v = median(sVF)
%
% Syntax
%   f = median(sVF)
%
% Output
%   v - @vector3d
%

v = vector3d(median(sVF.sF.fhat(:)));

end
