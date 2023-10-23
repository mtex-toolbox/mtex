function obj = median(obj,varargin)
% arithmetic mean of embedding
%
% Syntax
%   median(e)   % take the mean along the first non singular dimension
%   median(e,d) % take the mean along dimension d
%
% Input
%  e - @embedding
%  d - dimension of sum over
%
% Output
%  e - @embedding
%


for i = 1:length(obj.u)
  obj.u{i} = median(obj.u{i},varargin{:});
end

end