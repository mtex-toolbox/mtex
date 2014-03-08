function ax = nextAxis(mtexFig,varargin)
%
%


ax =  axes('visible','off','parent',mtexFig.parent);
mtexFig.children = [mtexFig.children,ax];
set(mtexFig.parent,'nextplot','add');
set(mtexFig.parent,'currentAxes',mtexFig.cBarAxis);

end

