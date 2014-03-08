function  drawNow(mtexFig, varargin)

if ~check_option(varargin,'position')  
  adjustFigurePosition(mtexFig)
else
  rFcn = get(mtexFig.parent,'ResizeFcn');
  rFcn(mtexFig.parent,[]);
end

end

