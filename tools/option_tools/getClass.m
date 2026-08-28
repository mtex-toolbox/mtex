function [out,list] = getClass(list,className,default,varargin)
% returns the first element of the requested class from a list
%
% The class can also be a list of classes, or a predicate - what an object
% is rather than which class it is, which is the only way to ask for a
% crystal direction, see isCrystalDirection.

if nargin == 2, default = [];end

if isa(className,'function_handle')
  isWanted = className;
elseif iscell(className)
  isWanted = @(x) isInClasses(x,className);
else
  isWanted = @(x) isa(x,className);
end

match = find(cellfun(isWanted,list),1,varargin{:});

if isempty(match)
  out = default;
else
  out = list{match};
end

% remove all occurrence of this class in the list
if nargout > 1
  list(cellfun(isWanted,list)) = [];
end

end




function out = isInClasses(x,className)

  out = false;
  for i=1:length(className)
    out = out || isa(x,className{i});
  end

end