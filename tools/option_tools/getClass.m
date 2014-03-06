function out = getClass(list,className,default)

if nargin == 2, default = [];end

match = find(cellfun(@(x) isa(x,className),list),1);

if isempty(match)
  out = default;
else
  out = list{match};
end
