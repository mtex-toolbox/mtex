function eps = mtimes(S,sigma)
% tensor product S * sigma

if isa(sigma,'stressTensor')

  % TODO: check symmetry
  eps = strainTensor(...
    EinsteinSum(S,[-1 -2 1 2],sigma,[-1 -2]));
  
else
  
  eps = mtimes@tensor(S,sigma);

end
