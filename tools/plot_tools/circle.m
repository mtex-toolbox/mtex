function h = circle(n,varargin)
% annotated a circle
%
% Input
%  n     - a normal @vector3d
%  omega - an opening angle around n (default pi/2) (GreatCircle)
%         an @vector3d
%
% Options
%

% where to plot
[ax,n,varargin] = getAxHandle(n,varargin{:});

% extract radius
if numel(varargin) >= 1 && isnumeric(varargin{1})
  omega = varargin{1};
else
  omega  = 90*degree; 
end

% if there is more then one circle - cycle through them
h = [];
if numel(n)>1
  hold on
  for i = 1:length(n);    
    h = [h,circle(ax{:},n(i),omega,varargin{:})]; %#ok<AGROW>
  end

  return
end

% generate circles
if isnumeric(omega)
  
  c = axis2quat(n,(0:1:360)*degree)*axis2quat(orth(n),omega)*n;
  
elseif isa(omega,'vector3d')
  
  c = axis2quat(cross(n,omega),linspace(0,angle(n,omega),fix(angle(n,omega)/degree)))*n;
  
elseif ~isnumeric(omega)
  
  varargin = [omega varargin];
  omega = 90*degree;
  
  c = axis2quat(n,(0:1:360)*degree)*axis2quat(orth(n),omega)*n;
  
end

% plot circles
holdState = getHoldState;

if ~holdState, hold on, end

plot(ax{:},c,'line',varargin{:});

hold(ax{:},holdState);
