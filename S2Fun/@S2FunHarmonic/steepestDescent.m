function [f,v] = steepestDescent(sF, varargin)
% calculates the minimum of a spherical harminc
% Syntax
%   [v,pos] = steepestDescent(sF) % the position where the minimum is atained
%
%   [v,pos] = steepestDescent(sF,'numLocal',5) % the 5 largest local minima
%
%   % with all options
%   [v,pos] = steepestDescent(sF, 'startingnodes')
%
% Output
%  v - double
%  pos - @vector3d
%
% Options
%  STARTINGNODES  -  starting nodes of type @vector3d
%  kmax  -  maximal iterations
%  tolerance  -  tolerance for nearby nodes to be ignored
%  

sF = sF.truncate;

% parameters
res = get_option(varargin,'resolution',0.025*degree);
TOL = get_option(varargin,'tolerance',degree/4);
kmax  = get_option(varargin, 'kmax', 20); % maximal iterations
isAntipodal = {'','antipodal'};
v = get_option(varargin, 'startingnodes', ...
  equispacedS2Grid('points', min(1000000,2*sF.bandwidth^2), isAntipodal{sF.antipodal+1}));
v = rmOption(v(:),'resolution');
v = v(v.theta > 0.01 & v.theta < pi-0.01);

% possible steplength
omega = 1.25.^(-30:1:12) * degree;
omega(omega<res) = [];
omega = [0,omega];

% actual steepest descent
for k = 0:kmax

  d = -normalize(sF.grad(v));
  
  % search line
  line_v = repmat(v,1,length(omega)) + d * omega;
  
  % evaluate along lines
  line_f = reshape(sF.eval(line_v),size(line_v));
  
  % take the maximum
  [f,id] = min(line_f,[],2);
  
  % update v
  v = normalize(line_v(sub2ind(size(line_v),(1:length(v)).',id)));
  
  if all(id == 1), break; end

  % maybe we can reduce the number of points a bit
  [v, I] = unique(v, 'tolerance', TOL);
  f = f(I);
  
end

% format output
[f, I] = sort(f);
if check_option(varargin, 'numLocal')
  n = get_option(varargin, 'numLocal');
  n = min(length(v), n);
  f = f(1:n);
else
  n = sum(f-f(1) < 1e-4);
  f = f(1);
end
v = v(I(1:n));

end
