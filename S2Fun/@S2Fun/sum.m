function value = sum(sF)
% calculates the integral for an univariate S2Fun
%
% Syntax
%   value = sum(sF)
%   sF = sum(sF, d)
%
% Input
%  sF - @S2FunHarmonic
%  d - dimension to take the mean value over
%
% Output
%  sF - S2FunHarmonic
%  value - double
%

 
value = 4*pi*mean(sF);  

end
