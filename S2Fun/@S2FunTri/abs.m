function sF = abs(sF)
% absolute value of a function
% Syntax
%   sF = abs(sF)
%   sF = abs(sF, 'bandwidth', bandwidth)
%
% Input
%  sF - @S2FunTri
%
% Output
%  sF - @S2FunTri
%
% Options
%  bandwidth - minimal degree of the spherical harmonic
%        

sF.values = abs(sF.values);
    
end