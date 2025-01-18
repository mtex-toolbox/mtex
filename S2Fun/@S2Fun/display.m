function display(sF,varargin)
% standard output

displayClass(sF,inputname(1),'moreInfo',char(sF.s,'compact'),varargin{:});

if length(sF) > 1, disp([' size: ' size2str(sF)]); end

end
