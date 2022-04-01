function value = mean(SO3F,varargin)
% expected value of an SO3FunComposition
%
% Syntax
%   mean(SO3F)
%
% Input
%  SO3F - @SO3FunComposition
%
% Output
%  value - double
%
% See also
% orientation/calcBinghamODF

value = sum(cellfun(@mean,SO3F.components,'UniformOutput',true));

end