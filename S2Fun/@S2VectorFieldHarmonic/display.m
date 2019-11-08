function display(sVF,varargin)
% standard output

displayClass(sVF,inputname(1),varargin{:});

disp([' bandwidth: ' num2str(sVF.sF.bandwidth)]);

if sVF.sF.antipodal, disp(' antipodal: true'); end

end
