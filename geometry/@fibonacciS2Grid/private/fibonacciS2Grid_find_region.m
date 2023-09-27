function varargout = fibonacciS2Grid_find_region(fibgrid, v, epsilon)
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
n = round(numel(fibgrid.x) - 1) / 2;
s = size(v, 1);
theta = v.theta;
rho = v.rho + pi;

% we need this to avoid massive overhead when calling v(k) for each k
fibgrid_xyz = fibgrid.xyz;
v_xyz = v.xyz;

% sort rho and get the corresponding index vectors
% if the grid is large it may be useful to save the precise rho values
% during construction in the options and retrieve them here 
try 
  rhoGrid = fibgrid.opt.rho;
catch 
  rhoGrid = fibgrid.rho;
end
[rhoGrid_sorted,sort_id,rank_id] = unique(rhoGrid + pi);

% the rho values are not uniformly distributed on [0,2*pi] which is why we
% have to assume that the rho difference between consecutive rho values
% (sorted by rho) is bigger than the expected value which is 2*pi / (2*n+1)
rhodiff = diff(rhoGrid_sorted);
rhodiff_max = max(rhodiff);
rhoscale = rhodiff_max * (2*n+1)/(2*pi);

% initialize the returning values of the function
test_id_cell = cell(s, 1);
grid_id_cell = cell(s, 1);
dist_cell = cell(s, 1);
nn = zeros(s, 1);

% if theta_big is true we first determine all grid points that are suitable
% w.r.t. their theta angle and throw away the ones that differ too much
% w.r.t. the rho angle 
% if theta_big is false we do it vice versa
% it should be faster due to the reduced average size of the relevant
% indice that remains after the first step
% TODO: this should also be dependent on epsilon
theta_crit = asin(0.825);
theta_big = abs(pi/2 - theta) > theta_crit;

% compute the index range for theta
thetamin = max(theta-epsilon, 0);
thetamax = min(theta+epsilon, pi);
thetamin_id = max(floor(-(2*n+1)/2 * cos(thetamin)) + n+1, 1);
thetamax_id = min( ceil(-(2*n+1)/2 * cos(thetamax)) + n+1, 2*n+1);

% compute the maximal allowed rho derivtion
% rho is not uniformly distributed on [0,2*pi] thus we have to scale the
% region w.r.t. rho by the ratio of the largest and the expected difference
% between consecutive rho angles
epsilon_rho = rhoscale * ...
  min(acos((max(cos(epsilon)-v.z.^2, 0)) ./ (1-v.z.^2)), pi);
rhomin = mod(rho - epsilon_rho, 2*pi);
rhomax = mod(rho + epsilon_rho, 2*pi);
rhomin_id = max(floor(rhomin * (2*n+1)/(2*pi)), 1);
rhomax_id = min( ceil(rhomax * (2*n+1)/(2*pi)), 2*n+1);
swap = rhomin > rhomax;

% mark the center if all rho values are suitable 
homerun = (epsilon_rho > pi-rhodiff_max) | (abs(pi/2-theta)  > pi/2-1.2*epsilon);

for k = 1:s
  % if rho region is very big use all points with suitable theta angle
  if homerun(k)
    best_id = (thetamin_id(k) : thetamax_id(k))';
  elseif theta_big(k)
    % grid indice suitable w.r.t. theta
    I = (thetamin_id(k) : thetamax_id(k))';
    % get the rho indice if sorted by rho
    rank_rho = rank_id(I);
    % filter out by index (faster than by value)
    rho_good = (rank_rho >= rhomin_id(k)) & (rank_rho <= rhomax_id(k));
    % swap upper and lower bounds if the rho interval contains 0 = 2*pi
    if swap(k)
      rho_good = ~rho_good;
    end
    % use the indice where also rho fits
    best_id = I(rho_good);

    % same as above but vice versa
  else
    % make the index vectors with respect to rho_sorted
    if swap(k)
      I = [1 : rhomax_id(k) rhomin_id(k) : 2*n+1]';
    else
      I = (rhomin_id(k) : rhomax_id(k))';
    end
    % get the grid indice if sorted by theta (as in construction)
    rank_theta = sort_id(I);
    % mark the ones where theta is in the suitable range
    theta_good = (rank_theta >= thetamin_id(k)) & ...
      (rank_theta <= thetamax_id(k));
    % only choose those as potential neighbors
    best_id = rank_theta(theta_good);
  end

  % compute the distances
  dist_temp = acos(sum(fibgrid_xyz(best_id,:) .* v_xyz(k,:), 2));
  % mark the grid points in the support
  inregion = dist_temp < epsilon;
  nn(k) = sum(inregion);
  % compute the return values of the function
  dist_cell{k} = dist_temp(inregion);
  grid_id_cell{k} = best_id(inregion);
  nn(k) = sum(inregion);
  test_id_cell{k} = k * ones(nn(k), 1);
end

% convert grid_idx and test_idx from cells into arrays
grid_id = cell2mat(grid_id_cell);
test_id = cell2mat(test_id_cell);

varargout{1} = grid_id;
varargout{2} = test_id;
varargout{3} = nn;
varargout{4} = cell2mat(dist_cell);

end