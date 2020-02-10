function initRegularisation(solver,varargin)

epsilon = get_option(varargin,'epsilon',solver.psi.halfwidth*2);

% a discrete Laplacian
A = -dot_outer(S3G,S3G,'epsilon',epsilon);
d = full(sum(A)).';

solver.RM = spdiags(-1-d,0,A);
