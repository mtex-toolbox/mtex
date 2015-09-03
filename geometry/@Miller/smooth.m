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


% symmetrise points
x = vector3d(symmetrise(m,'skipAntipodal'));

% symmetrise data
if ~isempty(varargin) && isnumeric(varargin{1})  
  varargin = [{repmat(varargin{1}(:).',size(x,1),1)},Miller.plotOptions,varargin(2:end)];
else
  varargin = [Miller.plotOptions,varargin];
end
    
% get plotting region
sR = region(m,varargin{:});

% use vector3d/smooth for output
[varargout{1:nargout}] = smooth(x(:),varargin{:},sR);

