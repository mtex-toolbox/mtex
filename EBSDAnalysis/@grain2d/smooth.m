function grains = smooth(grains,iter,varargin)
% constraint laplacian smoothing of grain boundaries
%
% Input
%  grains - @grain2d
%  iter   - number of iterations (default: 1)
%
% Output
%  grains - @grain2d
%
% Options
%  moveTriplePoints  - do not exclude triple/quadruple points from smoothing
%  moveOuterBoundary - do not exclude outer boundary from smoothing
%  second_order, S2  - second order smoothing
%  rate              - default smoothing kernel  
%  gauss             - gaussian smoothing kernel  
%  exp               - exponential smoothing kernel  
%  umbrella          - umbrella smoothing kernel   
 
if nargin < 2 || isempty(iter), iter = 1; end

% compute incidence matrix vertices - faces
I_VF = [grains.boundary.I_VF,grains.innerBoundary.I_VF];

% compute vertice adjacency matrix
A_V = I_VF * I_VF';
t = size(A_V,1);

% do not consider triple points
if check_option(varargin,'moveTriplePoints')
  ignore = false(size(A_V,1),1);
else
  ignore = full(diag(A_V)) > 2;
end

% ignore outer boundary
if ~check_option(varargin,'moveOuterBoundary')
  ignore(grains.boundary.F(any(grains.boundary.grainId==0,2),:)) = true;
end

if check_option(varargin,{'second order','second_order','S','S2'})
  A_V = logical(A_V + A_V*A_V);
  A_V = A_V - diag(diag(A_V));
end

weight = get_flag(varargin,{'gauss','expotential','exp','umbrella','rate'},'rate');
lambda = get_option(varargin,weight,.5);

V = full(grains.V);
isNotZero = ~all(~isfinite(V) | V == 0,2) & ~ignore;

for l=1:iter
  if ~strcmpi(weight,'rate')
    [i,j] = find(A_V);
    d = sqrt(sum((V(i,:)-V(j,:)).^2,2)); % distance
    switch weight
      case 'umbrella'
        w = 1./(d);
        w(d==0) = 1;
      case 'gauss'
        w = exp(-(d./lambda).^2);
      case {'expotential','exp'}
        w = lambda*exp(-lambda*d);
    end
    
    A_V = sparse(i,j,w,t,t);
  end

  % take the mean over the neigbours
  Vt = A_V*V;
  
  m = sum(A_V,2);
  
  dV = V(isNotZero,:)-bsxfun(@rdivide,Vt(isNotZero,:),m(isNotZero,:));
  
  isZero = any(~isfinite(dV),2);
  dV(isZero,:) = 0;
  
  V(isNotZero,:) = V(isNotZero,:) - lambda*dV;
  
end

grains.V = V;
