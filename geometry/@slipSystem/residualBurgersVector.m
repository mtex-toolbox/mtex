function rBv = residualBurgersVector(sS1,sS2)
% compute the Schmid factor 
%
% Syntax
%
%   rBv = residualBurgersVector(sS1,sS2)
%
% Input
%  sS1, sS2 - list of @slipSystem
%
% Output
%  rBv - size(sS1) array of rBv values
%


rBv = norm(sS1.b - sS2.b);


end
