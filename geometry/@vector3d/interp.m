function sF = interp(v,y,varargin)
% spherical interpolation - including some smoothing
%
% Syntax
%   sF = interp(v,y)
%   sF = interp(v,y,'linear')             % linear interpolation (default)
%   sF = interp(v,y,'nearest')            % nearest neighbor interpolation
%   sF = interp(v,y,'spline')             % spline interpolation (default)
%   sF = interp(v,y,'inverseDistance')    % inverse distance interpolation
%   sF = interp(v,y,'harmonic')           % approximation with spherical harmonics
%   yi = interp(v,y,vi)
%   yi = interp(v,y,vi,'spline')          % spline interpolation (default)
%   yi = interp(v,y,vi,'linear')          % linear interpolation
%   yi = interp(v,y,vi,'nearest')         % nearest neighbor interpolation
%   yi = interp(v,y,vi,'inverseDistance') % inverse distance interpolation
%   yi = interp(v,y,vi,'harmonic')        % approximation with spherical harmonics
%
% Input
%  v - data points @vector3d
%  y - data values (double, @vector3d)
%  vi - interpolation points @vector3d
%
% Output
%  sF - @S2Fun
%  yi - interpolation values
%

y = reshape(y, length(v), []);

% set harmonic approximation default for symmetric data 
if isa(v,'Miller') && ~check_option(varargin,{'linear','nearest','inverseDistance','noSymmetry'}) 
  varargin = [varargin,'harmonic'];
end

% decide method
if nargin>2 && isa(varargin{1},'vector3d') && ~check_option(varargin,'linear')
  varargin = [varargin,'spline'];
end

% Spherical Vector Fields
if isa(y,'vector3d') && y.antipodal

  if  check_option(varargin,'harmonic')
    sF = S2AxisFieldHarmonic.interpolate(v, y, varargin{:});
  else % 'linear'
    sF = S2AxisFieldTri(v,y);
  end

elseif isa(y,'vector3d')

  if check_option(varargin,'nearest')
    sF = S2VectorFieldHandle(@(v) nearest(v)); 
  elseif check_option(varargin,'harmonic')
    sF = S2VectorFieldHarmonic.interpolate(v, y, varargin{:});
  elseif check_option(varargin,'spline')
    sF = S2FunHandle(@(v) spline(v));
  else % 'linear'
    sF = S2VectorFieldTri(v,y);
  end

end

% Spherical Functions
if isnumeric(y)
  if check_option(varargin,'MLS')
    sF = S2FunMLS(v,y,varargin{:});
  elseif check_option(varargin,'nearest')
    sF = S2FunHandle(@(v) nearest(v));
  elseif check_option(varargin,'harmonic')
    sF = S2FunHarmonic.interpolate(v, y, varargin{:});
  elseif check_option(varargin,{'spline','inverseDistance'})
    sF = S2FunHandle(@(v) spline(v));
  else % ('linear')
    sF = S2FunTri(v,y);
  end
end

% Evaluations
if nargin>2 && isa(varargin{1},'vector3d')
  sF = sF.eval(varargin{1});
end


%% Functions

function yi = nearest(vi)
  [ind,d] = find(v,vi);
  if isa(y,'vector3d')
    yi = y.subSet(ind);
    ind = d > 2*v.resolution;
    yi = subsasgn(yi,struct('type','()','subs',{{ind}}),vector3d.nan);
  else
    yi = y(ind);
    yi(d > 2*v.resolution) = nan;
  end
  yi = reshape(yi,size(vi));
end

function yi = spline(vi)
  res = v.resolution;
  psi = S2DeLaValleePoussinKernel('halfwidth',res/2);
 
  % take the 4 closest neighbors for each point
  % TODO: this can be done better
  omega = angle_outer(vi,v,varargin{:});
  [so,j] = sort(omega,2);

  i = repmat((1:size(omega,1)).',1,4);
  if check_option(varargin,'inverseDistance')
    M = 1./so(:,1:4); M = min(M,1e10);
  else
    M = psi.eval(cos(so(:,1:4)));
  end

  % set point to nan which are to far away
  %
  % all() over an n x 4 matrix without a dimension reduces down the COLUMNS,
  % so the test used to produce a 1 x 4 row that then indexed rows 1 to 4 of
  % M: the per query point test never happened. Corrected to all(...,2).
  %
  % That alone changes nothing yet, because delta is still inert. It is a
  % quantile of how far each QUERY point sits from the data - a set
  % dominated by the very outliers the cut is meant to catch, so it grows
  % with them and never fires. On a pole figure measured only to a polar
  % angle of 60 degree, 0 of 8507 plotting nodes exceed it and all 6498
  % lying beyond the measured region are filled in, smeared out to the edge
  % of the hemisphere (#707). Deriving delta from the data's own spacing is
  % the obvious candidate, but 2 to 8 times v.resolution each blanked the
  % whole plot in measurement, which does not fit the geometry: angle_outer
  % reports a median nearest-data distance of 75 degree between an upper
  % hemisphere query grid and data covering the upper 60 degree cap. Work
  % out what that number really is before picking a constant.
  if check_option(varargin,'cutOutside')
    minO = min(omega,[],2);
    delta = 4*quantile(minO,0.5);
    M(all(so(:,1:4) > delta,2),:) = NaN;
  end
 
  M = repmat(1./sum(M,2),1,size(M,2)) .* M;
  M = sparse(i,j(:,1:4),M,size(omega,1),size(omega,2));
 
  yi = M * y(:);
end

end
