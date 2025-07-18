function [out,list] = getClass(list,className,default,varargin)
% returns the first element of the requested class from a list
% the class can also be a list of classes

if nargin == 2, default = [];end

if iscell(className)
  match = find(cellfun(@(x) isInClasses(x,className),list),1,varargin{:});
else
  match = find(cellfun(@(x) isa(x,className),list),1,varargin{:});
end

if isempty(match)
  out = default;
else
  out = list{match};
end

% remove all occurrence of this class in the list
if nargout > 1
  list(cellfun(@(x) isa(x,className),list)) = [];
end

end




function out = isInClasses(x,className)

  out = false;
  for i=1:length(className)
    out = out || isa(x,className{i});
  end

end