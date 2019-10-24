function sigma = colon(C,eps)
% tensor product C * eps

if isa(eps,'strainTensor')

  % TODO: check symmetry
  sigma = stressTensor(EinsteinSum(C,[-1 -2 1 2],eps,[-1 -2]));
  
else
  
  sigma = colon@tensor(C,eps);

end
