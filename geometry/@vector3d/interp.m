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
if isa(v,'Miller') && ~check_option(varargin,{'linear','nearest','inverseDistance'}) 
  varargin = [varargin,'harmonic'];
else
  % take the mean over duplicated nodes
  [v,~,ind] = unique(v(:));
  if isa(y,'vector3d')
    y = nan2zero(y);
  else
    y(isnan(y)) = 0;
  end
  y = accumarray(ind,y,[],@mean);
end

% Decide Method
if nargin>2 && isa(varargin{1},'vector3d') && ~check_option(varargin,'linear')
  varargin = [varargin,'spline'];
end


%% Spherical Vector Fields

if isa(y,'vector3d') && check_option(varargin,'AxisField')

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


%% Spherical Functions

if isnumeric(y)
  if check_option(varargin,'nearest')
    sF = S2FunHandle(@(v) nearest(v));
  elseif check_option(varargin,'harmonic')
    sF = S2FunHarmonic.interpolate(v, y, varargin{:});
  elseif check_option(varargin,{'spline','inverseDistance'})
    sF = S2FunHandle(@(v) spline(v));
  else % ('linear')
    sF = S2FunTri(v,y);
  end
end

%% Evaluations

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
 
  % take the 4 closest neighbours for each point
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
  if check_option(varargin,'cutOutside')
    minO = min(omega,[],2);
    delta = 4*quantile(minO,0.5);
    M(all(so(:,1:4)>delta),:) = NaN;
    %M(so(:,1:4)>delta) = NaN;
  end
 
  M = repmat(1./sum(M,2),1,size(M,2)) .* M;
  M = sparse(i,j(:,1:4),M,size(omega,1),size(omega,2));
 
  yi = M * y(:);
end

end
