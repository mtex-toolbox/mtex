function grains = smooth(grains,iter,varargin)
% constraint laplacian smoothing of grains
%


if nargin < 2 || isempty(iter)
  iter = 1;
end

V = grains.V;

FD = grains.I_FDext | grains.I_FDsub;
F = grains.F(any(FD,2),:);

[i,j,f] = find(double(F));
I_VF = sparse(f,reshape(i,[],size(F,2)),1,size(V,1),size(F,1));

% adjacent vertices
A_V = I_VF*I_VF';
t = size(A_V,1);

if isa(grains,'Grain2d')
  A_V = double(A_V == 1);
elseif isa(grains,'Grain3d')
  A_V = A_V>1;
  A_V = double(A_V-diag(diag(A_V)));
end

% constraits = sparse(l1,nn+1:t,1,t,t);
% constraits = constraits+constraits';

if check_option(varargin,{'second order','second_order','S','S2'})
  A_V = logical(A_V + A_V*A_V);
  A_V = A_V - diag(diag(A_V));
end

weight = get_flag(varargin,{'gauss','expotential','exp','umbrella','rate'},'rate');
lambda = get_option(varargin,weight,.5);

V = full(V);
isNotZero = ~all(~isfinite(V) | V == 0,2);

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
  
  Vt = A_V*V;
  
  m = sum(A_V,2);
  
  dV = V(isNotZero,:)-bsxfun(@rdivide,Vt(isNotZero,:),m(isNotZero,:));
  
  isZero = any(~isfinite(dV),2);
  dV(isZero,:) = 0;
  
  V(isNotZero,:) = V(isNotZero,:) - lambda*dV;
  
end

grains.V = V;
