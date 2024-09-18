function ax = nextAxis(mtexFig,i,j,varargin)
% go to next plot
  
if nargin == 1
  mtexFig.currentId = mtexFig.currentId+1;
elseif nargin == 2
  mtexFig.currentId = i;
else
  mtexFig.nrows = max(mtexFig.nrows,i);
  mtexFig.ncols = max(mtexFig.ncols,j);  
  mtexFig.currentId = (i-1)*mtexFig.ncols + j;
  mtexFig.layoutMode = 'user';
end

mtexFig.parent.CurrentAxes = mtexFig.gca;

if nargout > 0, ax = mtexFig.gca;end

% if there are multiple plot aspect ratio should be kept constant
mtexFig.keepAspectRatio = true;

end

