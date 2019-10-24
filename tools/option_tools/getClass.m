function [out,list] = getClass(list,className,default,varargin)

if nargin == 2, default = [];end

match = find(cellfun(@(x) isa(x,className),list),1,varargin{:});

if isempty(match)
  out = default;
else
  out = list{match};
end

% remove all occurence of this class in the list
if nargout > 1
  list(cellfun(@(x) isa(x,className),list)) = [];
end