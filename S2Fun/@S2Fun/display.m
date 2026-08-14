function display(sF,varargin)
% standard output

% sF.how2plot, not sF.s.how2plot - the convention lives on the function
displayClass(sF,inputname(1),'moreInfo',char(sF.how2plot,'compact'),varargin{:});

if length(sF) > 1, disp([' size: ' size2str(sF)]); end

end
