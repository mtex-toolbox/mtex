function x = calcAxisDistribution(odf,h,varargin)
% compute the axis distribution of an ODF or MDF
%
%
%% Input
%  odf - @ODF
%  h   - @vector3d
%
%% Flags
%  smallesAngle - use axis corresponding to the smalles angle
%  largestAngle - use axis corresponding to the largest angle
%  allAngles    - use all axes
%
%% Output
%  x   - values of the axis distribution
%
%% See also

res = get_option(varargin,'resolution',2.5*degree)/8;

% angle discretisation
omega = -pi:res:pi-res;
weight = sin(omega./2).^2 ./ length(omega);

% define a grid for quadrature
h = repmat(h(:),1,length(omega));
omega = repmat(omega,size(h,1),1);
S3G = orientation('axis',h,'angle',omega,odf(1).CS,odf(1).SS);

if check_option(varargin,'allAngles')
  
  f = eval(odf,S3G,varargin{:}); %#ok<EVLC>
  
else
  
  omega2 = angle(S3G);
  if check_option(varargin,'largestAngle')
    ind = abs(omega) >= omega2 - 0.01;
  else % smalles angle - default
    ind = abs(omega) <= omega2 + 0.01;
  end
  
  [i,j] = find(ind);

  f = eval(odf,S3G(ind),varargin{:}); %#ok<EVLC>
  f = sparse(i,j,f,size(S3G,1),size(S3G,2));
  
end

x = 2 * f * weight(:);
x = x./mean(x);
