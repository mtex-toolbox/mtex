function r = rectangle(varargin)
% create an rectangle

if nargin == 4 && isnumeric(varargin{1})

  r = polygon([varargin{1} varargin{2};varargin{3} varargin{2};...
    varargin{3} varargin{4}; varargin{1} varargin{4}; varargin{1} varargin{2}]);
  
else
  
  r = builtin('rectangle',varargin{:});
  
end
