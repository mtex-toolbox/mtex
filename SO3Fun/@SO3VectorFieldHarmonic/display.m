function display(SO3VF,varargin)
% standard output

displayClass(SO3VF,inputname(1),varargin{:});

disp([' bandwidth: ' num2str(SO3VF.SO3F.bandwidth)]);

if SO3VF.SO3F.antipodal, disp(' antipodal: true'); end

end
