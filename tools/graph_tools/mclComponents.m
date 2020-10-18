function A = mclComponents(A,p,maxIter)
% Markovian clustering algorithm
% check out the explanations in stijn van dongens thesis.
% author: gregor arbylon.net
%
% Input
%  A - adjecency matrix with weights between 0 and 1
%  p - parameter
%
% Output
%  A - adjecency matrix of the components
%

if nargin < 3, maxIter = inf; end

% prune elements of A that are below minval
minval = 0.0001;
A = (A > minval) .* A;

% ensure A is symmetric
if nnz(A .* A.') == 0, A = max(A, A.'); end

% ensure diagonal has ones
if ~any(diag(A)), A = A + speye(length(A)); end

e = 1;
i = 1;
emax = 0.001;
while e > emax && i <maxIter

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

end 

