function initRegularisation(solver,varargin)

epsilon = get_option(varargin,'epsilon',solver.psi.halfwidth*2);

% a discrete Laplacian
A = -dot_outer(solver.S3G,solver.S3G,'epsilon',epsilon);
d = full(sum(A)).';

solver.RM = solver.lambda * spdiags(-1-d,0,A);
