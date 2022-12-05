function [x,value] = steepestDescent(fun,x,varargin)
% find maximum with steepest descent
%
% Input
%  fun - @S2Fun, @SO3Fun
%  x   - initial seed @vector3d, @rotation
%
% Output
%  x     - local maxima
%  value - function values
%
% Options
%  maxIter    - 
%  resolution -

% prepare stepsize computation by Armijo search
maxIter = get_option(varargin,'maxIter',30);
res = get_option(varargin,'resolution',0.05*degree);
omega = 1.25.^(-30:1:10) * degree;
omega(omega<res) = [];
omega = [0,omega];

% use fixed number of iterations
for k = 1:maxIter

  % compute gradient - element of tangential space
  g = normalize(fun.grad(x));

  % prepare for linesearch
  line_x = exp(repmat(x(:),1,length(omega)),g(:) * omega);
  
  % evaluate along lines
  line_v = fun.eval(line_x);
  
  % find maxima along line
  [value,id] = max(line_v,[],2);
  
  % update nodes
  x = line_x(sub2ind(size(line_x),(1:length(x)).',id));
  
  % if there was no change -> abbort
  if all(id == 1), break; end
  %fprintf('.')
end

% [o2,v1,v2] = unique(ori)
% v = accumarray(v2,1)
%id = v>5;
%o2 = o2(id);
%v = v(id)

