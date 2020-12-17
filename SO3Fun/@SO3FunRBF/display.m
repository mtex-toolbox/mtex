function display(SO3F,varargin)
% called by standard output

displayClass(SO3F,inputname(1),varargin{:});

disp(['  kernel: ',char(SO3F.psi)]);
disp(['  center: ',char(SO3F.center)]);
if SO3F.c0 > 0, disp(['      c0: ',xnum2str(SO3F.c0)]); end

end
