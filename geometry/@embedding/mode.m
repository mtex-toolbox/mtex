function obj = mode(obj,varargin)
% arithmetic mode of embedding
%
% Syntax
%   mode(e)   % take the mode along the first non singular dimension
%   mode(e,d) % take the mode along dimension d
%
% Input
%  e - @embedding
%  d - dimension of sum over
%
% Output
%  e - @embedding
%


for i = 1:length(obj.u)
  obj.u{i} = mode(obj.u{i},varargin{:});
end

end