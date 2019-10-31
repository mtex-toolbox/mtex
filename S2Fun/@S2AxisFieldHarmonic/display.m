function display(sAF,varargin)
% standard output

displayClass(sAF,inputname(1),varargin{:});

disp([' bandwidth: ' num2str(sAF.sF.bandwidth)]);

if sAF.sF.antipodal, disp(' antipodal: true'); end

end
