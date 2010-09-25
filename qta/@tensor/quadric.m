function q = quadric(T,v)
% quadric

% convert directions to double
d = double(v);

% compute tensor products
for i = 1:T.rank
  T = mtimesT(T,i,d,[3 4]);
end

q = reshape(T.M,size(v));
