function A = mclComponents(A,p)
% Markovian clustering algorithm
% test the explanations in stijn van dongens thesis.
%
% Input
%  A - adjecency matrix with weights between 0 and 1
%  p - parameter
%
% Output
%  A - adjecency matrix of the components
%
% author gregor arbylon.net

minval = 0.0001;

e = 1;
i = 1;
emax = 0.001;
while e > emax

  i = i + 1;
  
  % expansion
  A = A^2;
  
  % inflation by Hadamard potentiation
  A = A .^ p;
  
  % prune elements of A that are below minval
  A = (A > minval) .* A;
  
  % column re-normalisation
  dinv = spdiags(1./sum(A).',0,length(A),length(A));
  A = A * dinv;
  %A = sqrt(dinv) * A * sqrt(dinv);
  
  % calculate residual energy
  maxs = max(A);
  sqsums = sum(A .^ 2);
  e = max(maxs - sqsums);

    
end 

disp(['number of iterations:' xnum2str(i)]);

end 

