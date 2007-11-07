function interface = check_interfaces(fname,varargin)
% determine interface from file

global mtex_path;

% find all installed interfaces
interfaces = dir([mtex_path '/qta/interfaces/loadPoleFigure_*.m']);
interfaces = {interfaces.name};

interface = {};

% ckeck for matching interfaces
w = warning;
warning off all
for i =1:length(interfaces)
  try
    feval(interfaces{i}(1:end-2),fname,varargin{:});
    interface = {interface{:},interfaces{i}(16:end-2)};
  catch  
  end
end
warning(w);
