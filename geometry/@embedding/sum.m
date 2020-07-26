function obj1 = sum(obj1,varargin)
% sum of embedding
%
% Syntax
%   sum(e)   % sum along the first non singular dimension
%   sum(e,d) % sum along dimension d
%
% Input
%  e - @embedding
%  d - dimension of sum over
%
% Output
%  e - @embedding

for i = 1:length(obj1.u)
  obj1.u{i} = sum(obj1.u{i},varargin{:});
end

end