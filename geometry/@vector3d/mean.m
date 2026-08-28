function [m,v] = mean(v,varargin)
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
%   % mean crystal direction, and the directions it was taken over
%   [m,mSym] = mean(m)
%
% Input
%  v - @vector3d
%
% Output
%  m    - @vector3d
%  mSym - the crystal directions projected around m
%
% Options
%  antipodal  - include <VectorsAxes.html antipodal symmetry>
%  robust     - robust mean (with respect to outliers)
%  noSymmetry - average the directions as they are given
%

persistent plan

% under a group a direction stands for its whole symmetrically equivalent
% set, so the equivalent directions closest to one another are averaged
if hasSymmetry(v) && ~check_option(varargin,'noSymmetry')

  % some cases where nothing is to do
  if isempty(v)
    m = v; m.x = NaN; m.y = NaN; m.z = NaN;
    return
  elseif isscalar(v)
    m = v;
    return
  end

  % get a first guess of the mean
  if check_option(varargin,'m0')
    m = get_option(varargin,'m0');
    varargin = delete_option(varargin,'m0',1);
  else
    m = v.subSet(find(~isnan(v.x),1));
  end

  % maybe the vectors are sufficiently concentrated around m
  if all(angle(m,v) < 10*degree)

    v = project2FundamentalRegion(v,m);
    m = meanVector(v,varargin{:});
    return
  end

  % in the general case we need a more robust algorithm - a search grid in
  % the fundamental sector, kept between calls since it is expensive
  if isempty(plan) || plan.frame ~= v.frame
    plan.frame = v.frame;
    plan.r = plotS2Grid(fundamentalSector(v.frame),'resolution',10*degree);
  end

  % take the grid point with the smallest mean square distance as the guess
  d = mean(angle_outer(v,plan.r).^2);
  [~,id] = min(d);
  m = subSet(plan.r,id);

  v = project2FundamentalRegion(v,m);
  m = meanVector(v,varargin{:});

  if nargout == 2, v = project2FundamentalRegion(v,m); end
  return
end

m = meanVector(v,varargin{:});

end

% -----------------------------------------------------------------

function m = meanVector(v,varargin)

% robust estimator
if check_option(varargin,'robust') && length(v)>4

  varargin = delete_option(varargin,'robust');

  m = meanVector(v,varargin{:});

  omega = angle(m,v);
  id = omega < quantile(omega,0.8)*(1+1e-5);

  if any(id), m = meanVector(v.subSet(id),varargin{:}); end
  return;
end

if check_option(varargin,'antipodal') || v.antipodal

  varargin = delete_option(varargin,'antipodal');

  if check_option(varargin,'weights')
    v = v .* reshape(sqrt(get_option(varargin,'weights')),size(v));
    varargin = delete_option(varargin,'weights',1);
  end

  varargin = delete_option(varargin,'weights',1);
  varargin = delete_option(varargin,'noSymmetry');

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

    v.x = mean(v.x,varargin{:},'omitnan');
    v.y = mean(v.y,varargin{:},'omitnan');
    v.z = mean(v.z,varargin{:},'omitnan');

    v.opt = struct;
    v.isNormalized = false;

    m = v;
  end

end

end
