function [f,v] = steepestDescent(sF, v, varargin)
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

% parameters
res = get_option(varargin,'resolution',0.025*degree);
tol = get_option(varargin,'tolerance',degree/4);
interMax  = get_option(varargin, {'kmax','iterMax'}, 30); 
maxStepSize = get_option(varargin,'maxStepSize',inf);
maxTravel = get_option(varargin,'maxTravel',inf);

% remove points exactly at the poles
v = rmOption(v(:),'resolution');
v = v(v.theta > 0.01 & v.theta < pi-0.01);

% possible steplength
omega = 1.25.^(-30:1:10) * degree; %omega = 1.25.^(-30:1:12) * degree;
omega(omega<res) = [];
omega(omega>maxStepSize) = [];
omega = [0,omega];

% cumulative walking distance
sumOmega = zeros(size(v));

gradsF = sF.grad;

% actual steepest descent
for k = 0:interMax

  %d = -normalize(sF.grad(v));
  d = -normalize(gradsF.eval(v));
  
  % search line
  line_v = repmat(v,1,length(omega)) + d * omega;
  
  % evaluate along lines
  line_f = reshape(sF.eval(line_v),size(line_v));
  
  % take the maximum
  [f,id] = min(line_f,[],2);
  
  % update v
  v = normalize(line_v(sub2ind(size(line_v),(1:length(v)).',id)));
  sumOmega = sumOmega + omega(id).';
  
  % project to fundamental region;
  v = v.project2FundamentalRegion;

  % if antipodal function project everything to upper hemisphere
  if v.antipodal, v(v.z<0) = -v(v.z<0); end
    
  if all(id == 1), break; end
  
  % maybe we can reduce the number of points a bit
  [~,~,I] = unique(v, 'tolerance', tol,'noSymmetry');
  v = normalize(accumarray(I,v));
  f = accumarray(I,f,[],@mean);
  sumOmega = accumarray(I,sumOmega,[],@min);

  % consider only points that did not walked too far
  f(sumOmega>maxTravel) = [];
  v(sumOmega>maxTravel) = [];
  sumOmega(sumOmega>maxTravel) = [];
end

end
