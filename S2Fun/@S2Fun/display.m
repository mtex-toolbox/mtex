function display(sF,varargin)
% standard output

displayClass(sF,inputname(1),varargin{:});

if length(sF) > 1, disp([' size: ' size2str(sF)]); end

end
