function [x,value] = steepestDescent(fun,x,varargin)
% find minimum with steepest descent
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

% prepare step length computation by Armijo search
maxIter = get_option(varargin,'maxIter',30);
res = get_option(varargin,'resolution',0.05*degree);
omega = 1.25.^(-30:1:10) * degree;
omega(omega<res) = [];
omega = [0,omega];

x = x(:);
value = fun.eval(x);

% use fixed number of iterations
for k = 1:maxIter

  % compute gradient - element of tangential space
  g = fun.grad(x);

  notZero = norm(g)>1e-8;

  g = normalize(g(notZero));

  % prepare for line search
  line_x = exp(repmat(x(notZero),1,length(omega)),g .* omega);
  
  % evaluate along lines
  line_v = reshape(fun.eval(line_x),size(line_x));
  
  % find maxima along line
  [value(notZero),id] = min(line_v,[],2);
  
  % update nodes
  x(notZero) = line_x(sub2ind(size(line_x),(1:nnz(notZero)).',id));
  
  % if there was no change -> abort
  if all(id == 1), break; end
  %fprintf('.')
end

% [o2,v1,v2] = unique(ori)
% v = accumarray(v2,1)
%id = v>5;
%o2 = o2(id);
%v = v(id)

