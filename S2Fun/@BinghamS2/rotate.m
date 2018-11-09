function  BS2 = rotate(BS2,rot)
% rotate a BinghamS2 function
%
% Syntax
%   BS2 = BS2.rotate(rot)
%
% Input
%  BS2 - @BinghamS2
%  rot - @rotation
%
% Output 
%  BS2 - @BinghamS2
%

BS2.a = rot.*BS2.a;
end

