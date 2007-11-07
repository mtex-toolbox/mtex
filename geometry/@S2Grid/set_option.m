function out = set_option(obj,option,varargin)
% set options

out = obj;
for i = 1:length(obj)
  out(i).options = set_option(out(i).options,option,varargin{:});
end
