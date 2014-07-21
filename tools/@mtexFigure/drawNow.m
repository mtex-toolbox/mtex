function  drawNow(mtexFig, varargin)

if check_option(varargin,'doNotDraw'), return;end

if check_option(varargin,'autoPosition')  
  adjustFigurePosition(mtexFig);
  %refresh(mtexFig.parent);  
else
  rFcn = get(mtexFig.parent,'ResizeFcn');
  rFcn(mtexFig.parent,[]);
end

end
