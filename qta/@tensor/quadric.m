function q = quadric(T,v)
% quadric

% convert directions to double
d = double(v);

% compute tensor products
while T.rank > 0
  T = mtimesT(T,1,d,[3 4]);
end

q = reshape(T.M,size(v));
