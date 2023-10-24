function obj = median(obj,varargin)
% arithmetic median of embedding
%
% Syntax
%   median(e)   % take the median along the first non singular dimension
%   median(e,d) % take the median along dimension d
%
% Input
%  e - @embedding
%  d - dimension to calculate over
%
% Output
%  e - @embedding
%


for i = 1:length(obj.u)
  obj.u{i} = median(obj.u{i},varargin{:});
end

end