function m = median(v,varargin)
% computes the median vector
%
% Syntax
%   % average direction with respect to the first nonsingleton dimension
%   m = median(v)
%
%   % average direction along dimension d
%   m = median(v,d)
%
%   % average axis
%   m = median(v,'antipodal')
%
% Input
%  v - @vector3d
%
% Output
%  m - @vector3d
%
% Options
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  robust    - robust median (with respect to outliers)
%


% robust estimator
if check_option(varargin,'robust') && length(v)>4
  
  varargin = delete_option(varargin,'robust');
  
  m = median(v,varargin{:});
  
  omega = angle(m,v);
  id = omega < quantile(omega,0.8)*(1+1e-5);
  
  if any(id), m = median(v.subSet(id),varargin{:}); end
  return;
end
  
if check_option(varargin,'antipodal') || v.antipodal

  varargin = delete_option(varargin,'antipodal');

  if check_option(varargin,'weights')
    v = v .* reshape(sqrt(get_option(varargin,'weights')),size(v));
    varargin = delete_option(varargin,'weights',1);
  end
    
  varargin = delete_option(varargin,'weights',1);
  
  xx = median(v.x.^2,  varargin{:});
  xy = median(v.x.*v.y,varargin{:});
  xz = median(v.x.*v.z,varargin{:});
  yy = median(v.y.^2,  varargin{:});
  yz = median(v.y.*v.z,varargin{:});
  zz = median(v.z.^2,  varargin{:});
  
  [m,~] = eig3(xx,xy,xz,yy,yz,zz,'largest');
else
  
  if check_option(varargin,'weights')
    v = v .* reshape(get_option(varargin,'weights'),size(v));
    varargin = delete_option(varargin,'weights',1);
    
    m = normalize(sum(v,varargin{:}));
    
  else
    
    v.x = median(v.x,varargin{:});
    v.y = median(v.y,varargin{:});
    v.z = median(v.z,varargin{:});

    v.opt = struct;
    v.isNormalized = false;
    
    m = v;
  end
  
end

end
