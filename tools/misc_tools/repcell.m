function c = repcell(v,s)

c = v;
if isempty(v),  return; end
if iscell(v) && length(v) >= 1,   return; end
if ~iscell(v), v = {v};end

if nargin > 1
  c = cell(s);
  c(:) = v;
else
  c = v;
end
