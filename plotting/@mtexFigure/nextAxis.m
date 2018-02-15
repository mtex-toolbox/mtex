function ax = nextAxis(mtexFig,varargin)
% go to next plot
  
mtexFig.currentId = mtexFig.currentId+1;

set(mtexFig.parent,'CurrentAxes',mtexFig.gca);

if nargout > 0, ax = mtexFig.gca;end

end

