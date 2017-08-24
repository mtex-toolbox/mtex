function  omega = maxAngle(oR,varargin)
% get the maximum angle of the fundamental region
%
% Syntax
%   omega = maxAngle(oR)   % maximum angle in the orientation region
%   omega = maxAngle(oR,v) % maximum angle about axis v 
%
% Description
% It is important that v is within the fundamental sector
%
% Input
%  oR - @orientationRegion
%  v  - @vector3d
%


if nargin>1 && isa(varargin{1},'vector3d')

  % ignore restrictions on the rotational axis
  %N = oR.N(oR.N.angle < pi<1e-3);
  N = oR.N;
  
  % project v to the fundamental sector
  dcs = properGroup(disjoint(oR.CS1,oR.CS2));
  if oR.antipodal, dcs = dcs.Laue; end
  h = varargin{1};
  h = reshape(project2FundamentalRegion(h,dcs),size(h));
    
  if isempty(N)
    omega = repmat(pi,size(h));
  else
    
    d = dot_outer(N.axis, normalize(h));
    dtan = repmat(-tan(N(:).angle./2),1,size(d,2));
    d(abs(d)<1e-2)=0;
    d = dtan .* d;
    
    %d = dot_outer(-tan(N.angle/2) .* N.axis, normalize(varargin{1}));
    
    d = 2*acot(d);
    d(d<0) = pi;
        
    omega = min(d,[],1);
    omega = reshape(omega,size(h));
    omega(omega<1e-4) = 0;
  end

elseif isempty(oR.V) || check_option(varargin,'complete')

  omega = pi;

else
  
  omega = max(angle(oR.V,'noSymmetry'));
  
end

