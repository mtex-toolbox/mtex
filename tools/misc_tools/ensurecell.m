function c = ensurecell(v,s)
% ensures that v is a cell with size s

c = v;
if isempty(v),  return; end

if iscell(v) && (nargin==1 || numel(v) == prod(s))
  return;
else
  v = {v};
end

if nargin > 1
  c = cell(s);
  c(:) = v;
else
  c = v;
end
