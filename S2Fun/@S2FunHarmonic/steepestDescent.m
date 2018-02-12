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
%  kmax - number of iterations
%  numLocal      - number of peaks to return
%  startingNodes - @vector3d
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size

sF = sF.truncate;

% parameters
res = get_option(varargin,'resolution',0.025*degree);
tol = get_option(varargin,'tolerance',degree/4);
kmax  = get_option(varargin, {'kmax','iterMax'}, 20); % maximal iterations
maxStepSize = get_option(varargin,'maxStepSize',inf);

isAntipodal = sF.antipodal;
if check_option(varargin, 'startingnodes')
  v = get_option(varargin, 'startingnodes');
else
  antipodalFlag = {'','antipodal'};
  v = equispacedS2Grid('points', min(1000000,2*sF.bandwidth^2), antipodalFlag{isAntipodal+1});
end

v = rmOption(v(:),'resolution');
v = v(v.theta > 0.01 & v.theta < pi-0.01);

% possible steplength
%omega = 1.25.^(-30:1:12) * degree;
omega = 1.25.^(-30:1:10) * degree;
omega(omega<res) = [];
omega(omega>maxStepSize) = [];
omega = [0,omega];


%base = (2*tol/res)^(1/kmax);


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
  
  
  % project to upper hemisphere if required
  if isAntipodal
    ind = v.z<0;
    v.x(ind) = -v.x(ind); v.y(ind) = -v.y(ind); v.z(ind) = -v.z(ind);
  end
  
  
  if all(id == 1), break; end

  % maybe we can reduce the number of points a bit
  [~,~,I] = unique(v, 'tolerance', tol);
  v = normalize(accumarray(I,v));
  f = accumarray(I,f,[],@mean);
  
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
