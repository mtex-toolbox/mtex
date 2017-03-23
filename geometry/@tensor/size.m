function varargout = size(T,dim)
% overloads size

s = size(T.M);
s = s(T.rank+1:end);

if nargin == 1
  if length(s) <= 1
    s = [s,ones(1,2-length(s))];
  end
elseif dim > numel(s)
  s = 1;
else
  s = s(dim);
end

if nargout > 1
  varargout = num2cell(s);
else
  varargout{1} = s;
end