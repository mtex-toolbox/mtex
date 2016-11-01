function yi = interp(v,y,vi,varargin)
% dirty spherical interpolation - including some smoothing

% we need unqiue input data
[v,ind] = unique(v);
y = y(ind);

if check_option(varargin,'nearest')
  
  [ind,d] = find(v,vi);
  yi = y(ind);
  yi(d > 2*v.resolution) = nan;
  yi = reshape(yi,size(vi));
  
else
  
  res = v.resolution;
  psi = deLaValeePoussinKernel('halfwidth',res/2);
  
  % take the 4 closest neighbours for each point
  % TODO: this can be done better
  omega = angle_outer(vi,v,varargin{:});
  [so,j] = sort(omega,2);
  
  i = repmat((1:size(omega,1)).',1,4);
  if check_option(varargin,'inverseDistance')
    M = 1./so(:,1:4); M = min(M,1e10);
  else
    M = psi.RK(cos(so(:,1:4)));
  end
  
  % set point to nan which are to far away
  if check_option(varargin,'cutOutside')
    minO = min(omega,[],2);
    delta = 4*quantile(minO,0.5);
    M(so(:,1:4)>delta) = NaN;
  end
  
  
  M = repmat(1./sum(M,2),1,size(M,2)) .* M;
  M = sparse(i,j(:,1:4),M,size(omega,1),size(omega,2));
  
  yi = M * y(:);
  
end
  
end
