function  BS2 = rotate(BS2,rot)
% rotate a S2FunBingham function
%
% Syntax
%   BS2 = BS2.rotate(rot)
%
% Input
%  BS2 - @S2FunBingham
%  rot - @rotation
%
% Output 
%  BS2 - @S2FunBingham
%

BS2.a = rot.*BS2.a;
end

