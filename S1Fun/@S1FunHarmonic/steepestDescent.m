function [v,x] = steepestDescent(fun, varargin)
% calculates the minimum of a spherical function
% Syntax
%   [v,pos] = steepestDescent(sF) % the position where the minimum is attained
%
%   [v,pos] = steepestDescent(sF,'numLocal',5) % the 5 largest local minima
%
%   % with all options
%   [v,pos] = steepestDescent(sF, 'startingnodes')
%
% Output
%  v - double
%  pos - angle between 0 and 2*pi
%
% Options
%  numLocal      - number of peaks to return
%  startingNodes - @vector3d
%


%  kmax - number of iterations
%  tolerance     - minimum distance between two peaks
%  resolution    - minimum step size 
%  maxStepSize   - maximm step size

% parameters
res = get_option(varargin,'resolution',0.025*degree);
% tol = get_option(varargin,'tolerance',degree/4);
% kmax  = get_option(varargin, {'kmax','iterMax'}, 30); % maximal iterations
% maxStepSize = get_option(varargin,'maxStepSize',inf);

isAntipodal = fun.antipodal;
x = get_option(varargin, 'startingnodes',0:res:((2-isAntipodal)*pi-res));

% first evaluation
v = fun.eval(x);

% find local extrema
id = find(circshift((circdiff(v)<=0),1) & circdiff(v)>=0);
% id = find(islocalmin(v));

v = v(id); x = x(id);

% format output
[v, I] = sort(v);
if check_option(varargin, 'numLocal')
  n = get_option(varargin, 'numLocal');
  n = min(length(x), n);
  v = v(1:n);
else
  n = 1;
  v = v(1);
end
x = x(I(1:n));

end
