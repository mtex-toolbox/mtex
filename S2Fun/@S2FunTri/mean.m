function value = mean(sF1)
% calculates the mean value for an univariate S2Fun or calculates the mean along a specified dimension of a multimodal S2Fun
%
% Syntax
%   value = mean(sF)
%   sF = mean(sF, d)
%
% Input
%  sF - @S2FunTri
%  d - dimension to take the mean value over
%
% Output
%  sF - S2FunTri
%  value - double
%
% Description
%
% If sF is a 3x3 S2Fun then |mean(sF)| returns a 3x3 matrix with the mean
% values of each function mean(sF, 1) returns a 1x3 S2Fun wich contains the
% pointwise means values along the first dimension
%

value = mean(sF1.values(:));
    
end