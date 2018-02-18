function kappa = evalkappa(lambda,varargin)
% eigenvalues of orientation tensor to bingham distribution parameters
%
% Options
%  approximated - approximated solution of kappas
%  precision    - precision of solvus
%  iteration    - number of newton interations
%
% See also
% orientation/mean EBSD/mean BinghamODF

% only approximated solution of kappas'

lambda = sort(lambda);
kappa = -1./(2.*lambda);
kappa(4) = 0;
kappa = kappa - kappa(1);

% kappa = sort(1./((2.*lambda-1).*lambda));
% kappa = (kappa-min(kappa))/2;

end