function value = mean(sF1)
% calculates the mean value for an univariate S2Fun
%
% Syntax
%   value = mean(sF)
%
% Input
%  sF - @S2FunTri
%
% Output
%  value - double
%

% TODO: exact computation

value = 1/(4*pi)*mean(sF1.values(:).*calcVoronoiArea(sF1.vertices(:)));

    
end