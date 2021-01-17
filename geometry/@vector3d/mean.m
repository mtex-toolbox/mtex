function m = mean(v,varargin)
% computes the mean vector
%
% Syntax
%   % average direction with respect to the first nonsingleton dimension
%   m = mean(v)
%
%   % average direction along dimension d
%   m = mean(v,d)
%
%   % average axis
%   m = mean(v,'antipodal')
%
% Input
%  v - @vector3d
%
% Output
%  m - @vector3d
%
% Options
%  antipodal - include <VectorsAxes.html antipodal symmetry>
%  robust    - robust mean (with respect to outliers)
%

% robust estimator
if check_option(varargin,'robust') && length(v)>4
  
  varargin = delete_option(varargin,'robust');
  
  m = mean(v,varargin{:});
  
  omega = angle(m,v);
  id = omega < quantile(omega,0.8)*(1+1e-5);
  
  if any(id), m = mean(v.subSet(id),varargin{:}); end
  return;
end
  
if check_option(varargin,'antipodal') || v.antipodal

  varargin = delete_option(varargin,'antipodal');

  if check_option(varargin,'weights')
    v = v .* reshape(sqrt(get_option(varargin,'weights')),size(v));
    varargin = delete_option(varargin,'weights',1);
  end
    
  varargin = delete_option(varargin,'weights',1);
  
  xx = mean(v.x.^2,  varargin{:});
  xy = mean(v.x.*v.y,varargin{:});
  xz = mean(v.x.*v.z,varargin{:});
  yy = mean(v.y.^2,  varargin{:});
  yz = mean(v.y.*v.z,varargin{:});
  zz = mean(v.z.^2,  varargin{:});
  
  [m,~] = eig3(xx,xy,xz,yy,yz,zz,'largest');
else
  
  if check_option(varargin,'weights')
    v = v .* reshape(get_option(varargin,'weights'),size(v));
    varargin = delete_option(varargin,'weights',1);
    
    m = normalize(sum(v,varargin{:}));
    
  else
    
    v.x = mean(v.x,varargin{:});
    v.y = mean(v.y,varargin{:});
    v.z = mean(v.z,varargin{:});

    v.opt = struct;
    v.isNormalized = false;
    
    m = v;
  end
  
end

end
