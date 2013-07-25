function out = checkOption(obj,option)
% return options

if nargin == 1
  out = fieldnames(obj.options);
else
  out = checkOption(obj.options,option);
end
