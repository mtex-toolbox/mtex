function varargout = fibonacciS2Grid_findbig(fibgrid, v)
% return incex of the grid point closest to v
%
% Input
%   fibgrid     - @fibobacciS2Grid
%   v           - @vector3d
%
% Output:
%   ind         - int32
%   dist        - double

% get parameters of v
n = (numel(fibgrid.x) - 1) / 2;
s = size(v, 1);
theta = v.theta;
rho = mod(v.rho, 2*pi);

% we need this to avoid massive overhead when calling v(k) for all k
% if the grid is large it may be useful to save the precise rho values
% during construction in the options and retrieve them here 
try 
  rhoGrid = fibgrid.opt.rho;
catch 
  rhoGrid = mod(fibgrid.rho, 2*pi);
end
fibgrid_xyz = fibgrid.xyz;
v_xyz = v.xyz;

% the resolution is slightly bigger than the max separation between 2 nodes
epsilon = fibgrid.resolution;

% initialize the returning values of the function
ind = zeros(s, 1);
dist = zeros(s, 1);

% compute the index range for theta
thetamin = max(theta - epsilon, 0);
thetamax = min(theta + epsilon, pi);
thetamin_id = max(floor(-(2*n+1)/2 * cos(thetamin)) + n+1, 1);
thetamax_id = min( ceil(-(2*n+1)/2 * cos(thetamax)) + n+1, 2*n+1);

% compute the maximal allowed rho derivtion
% rho is not uniformly distributed on [0,2*pi] thus we have to scale the
% region w.r.t. rho by the ratio of the largest and the expected difference
% between consecutive rho angles
epsilon_rho = min(acos((max(cos(epsilon)-v.z.^2, 0)) ./ (1-v.z.^2)), pi);

% this marks rows where the center is so close to the pole that we use all
% points close enough to the pole as potential neighbors
homerun = (epsilon_rho > pi-.1) | (abs(pi/2-theta) > pi/2-1.2*epsilon);

for k = 1:s
  % grid indice suitable w.r.t. theta
  I = (thetamin_id(k) : thetamax_id(k))';

  % if close to pole just use all points with suitable theta angle
  if homerun(k)
    best_id = I;
  else
    temp = abs(rhoGrid(I) - rho(k));
    diff_rho = min(temp, 2*pi-temp);
    rho_good = diff_rho < epsilon_rho(k);
    best_id = I(rho_good);
  end

  % compute the distances
  dist_temp = acos(sum(fibgrid_xyz(best_id,:) .* v_xyz(k,:), 2));
  [d, id] = min(dist_temp);
  dist(k) = d;
  ind(k) = best_id(id);
end

varargout{1} = ind;
varargout{2} = dist;

end