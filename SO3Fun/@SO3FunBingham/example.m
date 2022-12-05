function f = example(varargin)
% Construct the BinghamODF starting by some random values as example for an 
% SO3FunBingham.

% 2nd Possibility:
% kappa = [100 100 90 90];
% U = orth([4,7,4,4;7,6,9,3;9,2,9,0;9,4,1,9]./10);
% f = BinghamODF(kappa,U,crystalSymmetry);

cs = crystalSymmetry('1');
kappa = [100 90 80 0];   % shape parameters
U     = eye(4);          % orthogonal matrix
f = BinghamODF(kappa,U,cs);

end