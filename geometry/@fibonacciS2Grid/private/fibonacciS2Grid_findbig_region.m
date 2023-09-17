function varargout = fibonacciS2Grid_findbig_region(fibgrid, v, epsilon)
% return incex of all points in a epsilon neighborhood of a vector and
% their distance to v
%
% Input
%   fibgrid     - @fibobacciS2Grid
%   v           - @vector3d
%   epsilon     - double
%
% Output:
%   ind         - int32
%   dist        - dounle

% get parameters of v
n = (numel(fibgrid.x) - 1) / 2;
s = size(v, 1);
theta = v.theta;
rho = v.rho;

% initialize the returning values of the function
t_id_cell = cell(s, 1);
g_id_cell = cell(s, 1);
dist_cell = cell(s, 1);
nn = zeros(s, 1);

% we need this to avoid massive overhead when calling v(k) for all k
fibgrid_xyz = fibgrid.xyz;
v_xyz = v.xyz;

% compute the index range for theta
thetamin = max(theta - epsilon, -pi/2);
thetamax = min(theta + epsilon, pi/2);
thetamin_id = max( floor((2*n+1)/2 * sin(thetamin)) + n+1, 1);
thetamax_id = min( ceil((2*n+1)/2 * sin(thetamax)) + n+1, 2*n+1);

% compute the maximal allowed rho derivtion
% rho is not uniformly distributed on [0,2*pi] thus we have to scale the
% region w.r.t. rho by the ratio of the largest and the expected difference
% between consecutive rho angles
epsilon_rho = 1.1 * min(acos((max(cos(epsilon)-v.z.^2, 0)) ./ (1-v.z.^2)), pi);

% this marks rows where the center is so close to the pole that we use all
% points close enough to the pole as potential neighbors
homerun = (epsilon_rho > pi) | (abs(theta) + 1.5*epsilon > pi/2);

for k = 1:s
  % grid indice suitable w.r.t. theta
  I = (thetamin_id(k) : thetamax_id(k))';

  % if close to pole just use all points with suitable theta angle
  if homerun(k)
    best_id = I;
  else
    temp = abs(fibgrid.rho(I) - rho(k));
    diff_rho = min(temp, 2*pi-temp);
    rho_good = diff_rho < epsilon_rho(k);
    best_id = I(rho_good);
  end

  % compute the distances
  dist_temp = acos(sum(fibgrid_xyz(best_id,:) .* v_xyz(k,:), 2));
  % mark the grid points in the support
  insupp = dist_temp <= delta;
  nn(k) = sum(insupp);
  % compute the return values of the function
  dist_cell{k} = dist_temp(inregion);
  g_id_cell{k} = best_id(insupp);
  nn(k) = sum(insupp);
  t_id_cell{k} = k * ones(nn(k), 1);
end

% convert grid_idx and test_idx from cells into arrays
g_id = cell2mat(g_id_cell);
t_id = cell2mat(t_id_cell);
dist = cell2mat(dist_cell);

varargout{1} = g_id;
varargout{2} = t_id;
varargout{3} = nn;
varargout{4} = dist;

end