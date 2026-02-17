function a = noverk(n, k)

% same as nchoosek, but works for vector-valued inputs

% Syntax:
% a = noverk(n, k);
% 
% Input:
% n - array of integers
% k - array of integers with:
%       either n(i) >= k(i) (same size), or min(n) >= max(k) (different size)
% 
% Output:
% a = nchoosek(n, k) (pointwise)
% 

% if n and k have same size
if (size(n) == size(k))
  a = zeros(size(n));
  for i = 1 : numel(n)
    a(i) = nchoosek(n(i), k(i));
  end
  a = reshape(a, size(n));
  return;
end

% if they have different size
a = zeros(numel(n), numel(k));
for i = 1 : numel(n)
  for j = 1 : numel(k)
    a(i,j) = nchoosek(n(i), k(j));
  end
end
if (isscalar(n) && ~isscalar(k))
  a = reshape(t, size(k));
elseif (~isscalar(n) && isscalar(k))
  a = reshape(t, size(n));
end

end