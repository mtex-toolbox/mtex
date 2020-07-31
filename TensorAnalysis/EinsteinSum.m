function T = EinsteinSum(varargin)

t = tensor(varargin{1});
T = t.EinsteinSum(varargin{2:end});

end