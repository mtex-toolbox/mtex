function display(s,varargin)
% display a point group

displayClass(s,inputname(1),'moreInfo',s.name,varargin{:});
disp([' symmetry elements: ' int2str(numSym(s))]);
disp(' ');

end
