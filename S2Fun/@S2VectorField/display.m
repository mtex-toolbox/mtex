function display(sVF,varargin)
% standard output

displayClass(sVF,inputname(1),varargin{:});

if length(sVF) > 1, disp([' size: ' size2str(sVF)]); end

end
