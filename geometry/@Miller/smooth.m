function varargout = smooth(m,varargin)
% plot Miller indece
%
% Input
%  m  - Miller
%
% Options
%
% See also
% vector3d/smooth

% get axis hande
[ax,m,varargin] = getAxHandle(m,varargin{:});

% symmetrise points
x = vector3d(symmetrise(m,'skipAntipodal'));

% symmetrise data
if ~isempty(varargin) && isnumeric(varargin{1})
  varargin{1} = repmat(varargin{1}(:).',size(x,1),1);
end
    
% get plotting region
[minTheta,maxTheta,minRho,maxRho] = get(m,'bounds',varargin{:});

% use vector3d/smooth for output
[varargout{1:nargout}] = smooth(ax{:},x(:),varargin{:},...
  'minTheta',minTheta,...
  'maxTheta',maxTheta,...
  'minRho',minRho,...
  'maxRho',maxRho);
