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

% get plotting region
sR = region(m,varargin{:});

if isfield(m.opt,'plot')

  if ~isempty(varargin) && isnumeric(varargin{1})
    varargin = [varargin{1},m.plotOptions,varargin(2:end)];
  else
    varargin = [m.plotOptions,varargin];
  end
  
else

  % symmetrise points
  m = symmetrise(m,'skipAntipodal');

  if ~isempty(varargin) && isnumeric(varargin{1})
    varargin = [{repmat(varargin{1}(:).',size(m,1),1)},m.plotOptions,varargin(2:end)];
  else
    varargin = [m.plotOptions,varargin];
  end
  m = m(:);
  
end
    
% use vector3d/smooth for output
[varargout{1:nargout}] = smooth@vector3d(m,varargin{:},sR);
