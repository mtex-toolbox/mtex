function [f,v] = simultaniousCG(sF, varargin)
% calculates the minimum of a spherical harminc
% Syntax
%   [v,pos] = simultaniousCG(sF) % the position where the minimum is atained
%
%   [v,pos] = simultaniousCG(sF,'numLocal',5) % the 5 largest local minima
%
%   % with all options
%   [v,pos] = simultaniousCG(sF, 'startingnodes', NODES, 'lambda', LAMBDA, 'tau', TAU, 'mu', MU, 'kmax', KMAX, 'tauLS', TAULS, 'kmaxLS', KMAXLS)
%
% Output
%  v - double
%  pos - @vector3d
%
% Options
%  STARTINGNODES  -  starting nodes of type @vector3d
%  LAMBDA         -  regularization parameter
%  TAU            -  tolerance
%  MU             -  in (0, 0.5) for Armijo condition
%  KMAX           -  maximal iterations
%  TAULS          -  in (0, 1) alpha(k+1) = tauLS*alpha(k)
%  KMAXLS         -  maximal iterations for line search
%  

% parameters{{{
v = get_option(varargin, 'startingnodes', equispacedS2Grid('points', 2^9));
v = v(:);
v = v(v.theta > 0.01 & v.theta < pi-0.01);
lambda   = get_option(varargin, 'lambda', sqrt(length(v))/10); % regularization parameter
tau   = get_option(varargin, 'tau', 1e-8); % tolerance
kmax   = get_option(varargin, 'kmax', 10); % maximal iterations
mu     = get_option(varargin, 'mu', 0.4); % in (0, 0.5) for Armijo condition
tauLS   = get_option(varargin, 'tauLS', 0.5); % in (0, 1) alpha(k+1) = tauLS*alpha(k)
kmaxLS   = get_option(varargin, 'kmaxLS', 6); % maximal iterations for line search
%}}}
% initialization{{{
sF = sF.truncate;
D = [sF.dtheta sF.drho sF.dthetadtheta sF.drho sF.drhodrho];
G = S2VectorFieldHarmonic(subSet(D, 2:-1:1));
g = G.eval(v);
d = -g;
k = 1;

H = zeros(2, 2, length(v));
DV = D.eval(v);
H(1, :, :) = [DV(:, 3) DV(:, 4)-DV(:, 2).*cot(v.theta)]';
H(2, :, :) = [DV(:, 4)-DV(:, 2).*cot(v.theta) DV(:, 5)+DV(:, 1).*sin(v.theta).*cos(v.theta)]';
%}}}
while true
  k = k+1;
% initial step length{{{
  h = zeros(length(v), 1);
  for ii = 1:length(v)
    h(ii) = [d(ii).theta d(ii).rho]*H(:, :, ii)*[d(ii).theta; d(ii).rho];
  end
  normd = norm(d);
  alpha = abs(dot(g, d))./(h+lambda*abs(dot(g, d)).*normd);
  %}}}
% TODO: alpha may be negative - why?
%  figure(2); plot(sort(alpha)); ylim([-1, 1]);
%  figure(1); clf; hold on;
%  plot(sF);
%  scatter(v, 'MarkerColor', 'k');
%  scatter(v(alpha < 0), 'MarkerColor', 'r');
%  quiver(v, d, 'color', 'k');
%  hold off;
  alpha = (alpha < 0)+(alpha >= 0).*alpha;
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
% remove duplicates{{{
  vold = v;
  v = valphad;
  [v, I] = unique(v, 'tolerance', 0.01);
  vold = vold(I);
  alpha = alpha(I);
  d = d(I);
  normd = normd(I);
  g = G.eval(v);
  %}}}
  if ( 1/length(v)*sum(norm(g)) < tau ) || ( k > kmax ), break; end
% step direction{{{
  H = zeros(2, 2, length(v));
  DV = D.eval(v);
  H(1, :, :) = [DV(:, 3) DV(:, 4)-DV(:, 2).*cot(v.theta)]';
  H(2, :, :) = [DV(:, 4)-DV(:, 2).*cot(v.theta) DV(:, 5)+DV(:, 1).*sin(v.theta).*cos(v.theta)]';

  dtilde = diag(-sin(alpha.*normd).*normd)*vold+diag(cos(alpha.*normd))*d;

  if mod(k, 2) ~= 0
    betan = []; betad = [];
    for ii = 1:length(v)
      betan(ii) = [g(ii).theta g(ii).rho]*H(:, :, ii)*[dtilde(ii).theta; dtilde(ii).rho];
      betad(ii) = [dtilde(ii).theta dtilde(ii).rho]*H(:, :, ii)*[dtilde(ii).theta; dtilde(ii).rho];
    end
    d = -g+diag((abs(betad) > 0).*betan./betad)*dtilde;
    d = diag(double(dot(g, d) >= 0))*(-g)+diag(double(dot(g, d) < 0))*d; % enforce descent direction
  else
    d = -g;
  end
  %}}}
end

f = f(I);
[f, I] = sort(f);
if check_option(varargin, 'numLocal')
  n = get_option(varargin, 'numLocal');
  n = min(length(v), n);
  f = f(1:n);
  v = v(I(1:n));
else
  n = sum(f-f(1) < 0.01);
  f = f(1);
end
v = v(I(1:n));

end
