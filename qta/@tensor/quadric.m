function q = quadric(T,v)
% quadric

% compute tensor products with directions v with respect to all dimensions
while T.rank > 0
  T = EinsteinSum(T,[-1 1:T.rank-1],v,-1);
end

q = reshape(T.M,size(v));
