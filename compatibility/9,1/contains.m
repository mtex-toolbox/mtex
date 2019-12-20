function out = contains(str,pattern,~,ignoreCase)

if nargin == 4 && ignoreCase
  str = lower(str);
  pattern = lower(pattern);
end

out = any(strfind(str,pattern));
