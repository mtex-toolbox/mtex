function smooth(m,varargin)
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
  varargin{1} = repmat(varargin{1}(:).',size(x,1),1);
end
    
% get plotting region
sR = region(m,varargin{:});

% use vector3d/smooth for output
smooth(x(:),varargin{:},sR);
