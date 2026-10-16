function args = solveOptions(F,evalVector,varargin)
% options of the local least squares solvers

args = {'eval_vector',evalVector};
if F.centered, args = [args,{'centered_evaluation'}]; end
if F.regularize
  args = [args,{'regularize','mincond',F.mincond,'maxcond',F.maxcond, ...
    'targetcond',F.targetcond,'basis_degrees',basisDegrees(F), ...
    'degree_laplace_shift',F.domainDim - 1}];
end
args = [args,varargin];

end
