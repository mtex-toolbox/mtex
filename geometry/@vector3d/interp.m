function yi = interp(v,y,varargin)
% spherical interpolation - including some smoothing
%
% Syntax
%   sF = interp(v,y,'linear')     % linear interpolation (default)
%   sF = interp(v,y,'harmonic')   % approximation with spherical harmonics
%   yi = interp(v,y,vi,'linear')  % linear interpolation
%   yi = interp(v,y,vi,'spline')  % spline interpolation (default)
%   yi = interp(v,y,vi,'nearest') % nearest neigbour interpolation
%   yi = interp(v,y,vi,'inverseDistance') % inverse distance interpolation
%   yi = interp(v,y,vi,'harmonic') % approximation with spherical harmonics
%
% Input
%  v - data points @vector3d
%  y - data values
%  vi - interpolation points @vector3d
%
% Output
%  sF - @S2Fun
%  yi - interpolation values
%

% set harmonic approximation default for symmetric data 
if isa(v,'Miller') && ~check_option(varargin,{'linear','nearest','inverseDistance'}) 
  varargin = [varargin,'harmonic'];
else
  % take the mean over duplicated nodes
  y = reshape(y, length(v), []);
  [v,~,ind] = unique(v(:));
  y = accumarray(ind,y,[],@nanmean);
end

if isempty(varargin) 
  yi = S2FunTri(v,y);
  return
end

if isa(varargin{1},'vector3d')
  
  vi = varargin{1};
  if check_option(varargin,'nearest')

    [ind,d] = find(v,vi);
    yi = y(ind);
    yi(d > 2*v.resolution) = nan;
    yi = reshape(yi,size(vi));

  elseif check_option(varargin,'linear') % linear interpolation

    sF = S2FunTri(v,y);
    yi = sF.eval(vi);

  elseif check_option(varargin, {'harmonicApproximation','harmonic'})

    sF = S2FunHarmonic.approximation(v, y, varargin{:});
    yi = sF.eval(vi);

  else
  
    res = v.resolution;
    psi = S2DeLaValleePoussin('halfwidth',res/2);

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
else % varargin{1} not numeric
  if check_option(varargin, {'harmonicApproximation','harmonic'})
    yi = S2FunHarmonic.approximation(v, y, varargin{:});

  elseif check_option(varargin, 'linear')
    yi = S2FunTri(v,y);
  
  end
  
end
  
end
