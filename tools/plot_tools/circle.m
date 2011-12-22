function circle(n,omega,varargin)
% annotated a circle
%
%% Input
% n     - a normal @vector3d
% omega - an opening angle around n (default pi/2) (GreatCircle)
%         an @vector3d
%% Options
%

if nargin < 2, omega  = 90*degree; end

if numel(n)>1
  for i = 1:numel(n);
    circle(n(i),omega,varargin{:});
  end
  return
end

if isnumeric(omega)
  
  c = axis2quat(n,(0:1:360)*degree)*axis2quat(orth(n),omega)*n;
  
elseif isa(omega,'vector3d')
  
  c = axis2quat(cross(n,omega),linspace(0,angle(n,omega),fix(angle(n,omega)/degree)))*n;
  
elseif ~isnumeric(omega)
  
  varargin = [omega varargin];
  omega = 90*degree;
  
  c = axis2quat(n,(0:1:360)*degree)*axis2quat(orth(n),omega)*n;
  
end


holdState = ishold;

if ~holdState, hold on, end

plot(c,'line',varargin{:})

if ~holdState, hold off, end
