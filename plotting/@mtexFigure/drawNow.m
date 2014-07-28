function  drawNow(mtexFig, varargin)

if check_option(varargin,'doNotDraw'), return;end

if check_option(varargin,'autoPosition')  
  posHasChanged = adjustFigurePosition(mtexFig);
  %refresh(mtexFig.parent);  
else
  posHasChanged = false;
end

if ~posHasChanged
  rFcn = get(mtexFig.parent,'ResizeFcn');
  rFcn(mtexFig.parent,[]);
end

end
