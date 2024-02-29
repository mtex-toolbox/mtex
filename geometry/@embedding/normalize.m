function obj = normalize(obj)
% normalize to one
%
% Syntax
%
%   e = normalize(e)
%
% Input
%  e - @embedding
%
% Output
%  e - @embedding
%

obj = obj ./ norm(obj);

end