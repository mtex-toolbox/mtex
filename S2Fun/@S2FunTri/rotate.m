function sF = rotate(sF, rot)
% rotate a function by a rotation
%
% Syntax
%   sF = sF.rotate(rot)
%
% Input
%  sF - @S2FunTri
%  rot - @rotation
%
% Output 
%  sF - @S2FunTri
%
 
sF.tri = rotate(sF.tri,rot);
       
end