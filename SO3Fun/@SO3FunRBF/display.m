function display(SO3F,varargin)
% called by standard output

displayClass(SO3F,inputname(1),varargin{:});

disp(['  kernel: ',char(SO3F.psi)]);
disp(['  center: ',char(SO3F.center)]);

end
