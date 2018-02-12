function ax = nextAxis(mtexFig,i,j,varargin)
% go to next plot
  
if nargin == 1
  mtexFig.currentId = mtexFig.currentId+1;
elseif nargin == 2
  mtexFig.currentId = i;
else
  mtexFig.currentId = (i-1)*mtexFig.ncols + j;
end

set(mtexFig.parent,'CurrentAxes',mtexFig.gca);

if nargout > 0, ax = mtexFig.gca;end

end

