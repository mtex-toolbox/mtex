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

% only approximated solution of kappas' which hold true only for large
% values of lambda see: F. Bachmann, R. Hielscher, P. Jupp, W. Pantleon, H.
% Schaeben, E.Wegert: Inferential statistics of electron backscatter
% diffraction data from within individual crystalline grains, Journal of
% applied Crystallogrpahy, 2010, 34, eq. 38.

lambda = sort(lambda);
kappa = -1./(2.*lambda);
kappa(4) = 0;
kappa = kappa - kappa(1);

% kappa = sort(1./((2.*lambda-1).*lambda));
% kappa = (kappa-min(kappa))/2;

end