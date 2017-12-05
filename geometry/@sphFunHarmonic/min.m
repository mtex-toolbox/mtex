function v = min(sF, varargin)
% calculates the minimum of a spherical harminc or the pointwise minimum of two spherical harmonics
% Syntax
%   v = min(sF)
%   v = min(sF, 'm', M)
%   sF = min(sF1, sF2)
%   sF = min(sF1, sF2, 'n', N, 'lambda', LAMBDA, 'tau', TAU, 'mu', MU, 'kmax', KMAX, 'tauLS', TAULS, 'kmaxLS', KMAXLS)
%
% Options
%  M      - minimal degree of the spherical harmonic
%  N      -  number of points
%  LAMBDA -  regularization parameter
%  TAU    -  tolerance
%  MU     -  in (0, 0.5) for Armijo condition
%  KMAX   -  maximal iterations
%  TAULS  -  in (0, 1) alpha(k+1) = tauLS*alpha(k)
%  KMAXLS -  maximal iterations for line search
%  

% pointwise minimum of two spherical harmonics{{{
if nargin > 1 & isa(varargin{1}, 'sphFunHarmonic')
	if check_option(varargin, 'm')
		f = @(v) 1/2*(sF.eval(v)+varargin{1}.eval(v)-abs(sF.eval(v)-varargin{1}.eval(v), 'm', get_option(varargin, 'm')));
	else
		f = @(v) 1/2*(sF.eval(v)+varargin{1}.eval(v)-abs(sF.eval(v)-varargin{1}.eval(v)));
	end
	v = sphFunHarmonic.quadrature(f);
	return;
end
%}}}

% minimization of one spherical harmonic
% parameters{{{
N 		= get_option(varargin, 'n', 2^10); % number of points
lambda 	= get_option(varargin, 'lambda', sqrt(N)/10); % regularization parameter
tau 	= get_option(varargin, 'tau', 1e-8); % tolerance
kmax 	= get_option(varargin, 'kmax', 10); % maximal iterations
mu 		= get_option(varargin, 'mu', 0.4); % in (0, 0.5) for Armijo condition
tauLS 	= get_option(varargin, 'tauLS', 0.5); % in (0, 1) alpha(k+1) = tauLS*alpha(k)
kmaxLS 	= get_option(varargin, 'kmaxLS', 6); % maximal iterations for line search
%}}}
% initialization{{{
v = equispacedS2Grid('points', N);
v = v(:);
v = v(v.theta > 0.01 & v.theta < pi-0.01); % cant derivate on the poles
G = sF.grad;
Gthth = sF.dthetadtheta;
Gthrh = sF.dthetadrho;
Grhrh = sF.drhodrho;

g = G.eval(v);
d = -g;
k = 1;

H = zeros(2, 2, length(v));
H(1, :, :) = [Gthth.eval(v) Gthrh.eval(v)-G.rho.eval(v).*cot(v.theta)]';
H(2, :, :) = [Gthrh.eval(v)-G.rho.eval(v).*cot(v.theta) Grhrh.eval(v)+G.theta.eval(v).*sin(v.theta).*cos(v.theta)]';
%}}}
while 1/length(v)*sum(norm(g)) > tau & k < kmax
	% initial step length{{{
	h = zeros(length(v), 1);
	for ii = 1:length(v)
		h(ii) = [d(ii).theta d(ii).rho]*H(:, :, ii)*[d(ii).theta; d(ii).rho];
	end
	normd = norm(d);
	alpha = abs(dot(g, d))./(h+lambda*abs(dot(g, d)).*normd);
	alpha = (alpha < eps)+(alpha >= 0).*alpha;
	%}}}
%	figure(2); plot(sort(alpha)); ylim([-1, 1]);
%	figure(1); clf;
%	plot3d(sF); hold on;
%	scatter3d(v, ones(3, length(v)));
%	quiver3(v, diag(alpha)*d);
%	drawnow;
	% step length by linesearch{{{
	f0 = sF.eval(v);
	vd = diag(cos(normd))*v+diag(sin(normd)./normd)*d;
	g = dot(G.eval(vd), d);
	for kLS = 1:kmaxLS
		valphad = diag(cos(alpha.*normd))*v+diag(sin(alpha.*normd)./normd)*d;
		f = sF.eval(valphad);
		allgood = true;
		for ii = 1:length(v)
			if f(ii)-f0(ii) > mu*alpha(ii)*g(ii)
				alpha(ii) = tauLS*alpha(ii);
				allgood = false;
			end
		end
		if allgood == true, break; end
	end
	%}}}
	% step direction{{{
	vold = v;
	v = valphad;
	g = G.eval(v);

	H = zeros(2, 2, length(v));
	H(1, :, :) = [Gthth.eval(v) Gthrh.eval(v)-G.rho.eval(v).*cot(v.theta)]';
	H(2, :, :) = [Gthrh.eval(v)-G.rho.eval(v).*cot(v.theta) Grhrh.eval(v)+G.theta.eval(v).*sin(v.theta).*cos(v.theta)]';

	dtilde = diag(-sin(alpha.*normd).*normd)*vold+diag(cos(alpha.*normd))*d;

	if mod(k, 2) ~= 0
		for ii = 1:length(v)
			betan(ii) = [g(ii).theta g(ii).rho]*H(:, :, ii)*[dtilde(ii).theta; dtilde(ii).rho];
			betad(ii) = [dtilde(ii).theta dtilde(ii).rho]*H(:, :, ii)*[dtilde(ii).theta; dtilde(ii).rho];
		end
		d = -g+diag((abs(betad) > eps).*betan./betad)*dtilde;
		d = diag(double(dot(g, d) >= 0))*(-g)+diag(double(dot(g, d) < 0))*d; % enforce descent direction
	else
		d = -g;
	end
	%}}}
	k = k+1;
end

end
