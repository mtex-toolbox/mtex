function  drawNow(mtexFig, varargin)

if check_option(varargin,'doNotDraw'), return;end

set(mtexFig.children,'units','pixel');

% update children to be only the axes of mtexFig
mtexFig.children = flipud(findobj(mtexFig.parent,'type','axes',...
  '-not','tag','Colorbar','-and','-not','tag','legend'));

% this seems to be necesarry to get tight inset right
if ~check_option(varargin,'keepAxisSize') 
  updateLayout(mtexFig);
end

% compute surounding box of each axis in pixel
[mtexFig.tightInset,mtexFig.figTightInset] = calcTightInset(mtexFig);

% determine prelimary figure size
if check_option(varargin,'position')
  
  position = get_option(varargin,'position');
  figSize = position(3:4);
  
elseif check_option(varargin,'figSize') || mtexFig.figSizeFactor > 0 
  
  screenExtend = get(0,'MonitorPositions');
    
  mtexFig.keepAspectRatio = true;
  figSize = screenExtend(1,3:4) - [0,120]; % consider only the first monitor

  switch get_option(varargin,'figSize','','char')
    case 'huge'
      fac = 1;
    case 'large'
      fac = 0.8;
    case {'normal','medium'}
      fac = 0.5;
    case 'small'
      fac = 0.35;
    case 'tiny'
      fac =  0.25;
    otherwise
      fac = get_option(varargin,'figSize',mtexFig.figSizeFactor,'double');
  end
  figSize = figSize .* fac;
  
  n = numel(mtexFig.children);
  if isappdata(mtexFig.children(1),'sphericalPlot') ...
      || n > 1
    figSize = figSize .* min([1 1]./fac,0.75*[n/(1+(n>4)), (1 + (n>4))]);
  end
 
  % try to compensate tight inset
  figSize(1) = figSize(1) + sum(mtexFig.figTightInset([1,3])) + ...
    mtexFig.ncols * sum(mtexFig.tightInset([1,3]));
  figSize(2) = figSize(2) + sum(mtexFig.figTightInset([2,4])) + ...
    mtexFig.nrows * sum(mtexFig.tightInset([2,4]));
    
else

  position = get(mtexFig.parent,'Position'); 
  figSize = position(3:4);
  
end

figSize = figSize - sum(reshape(mtexFig.figTightInset,2,2),2).';

% compute layout
if check_option(varargin,'figSize') ||...
    ~check_option(varargin,'keepAxisSize') || isempty(mtexFig.axisWidth)
  [mtexFig.ncols,mtexFig.nrows] = calcPartition(mtexFig,figSize);
  [mtexFig.axisWidth,mtexFig.axisHeight] = calcAxesSize(mtexFig,figSize);
else
  screenExtend = get(0,'MonitorPositions');
end

% resize figure
if exist('screenExtend','var')
  width = mtexFig.axesWidth;
  height = mtexFig.axesHeight;
  position = [(screenExtend(1,3)-width)/2,(screenExtend(1,4)-height)/2,width,height];
end

% draw layout
set(mtexFig.parent,'ResizeFcn',[]);
set(mtexFig.parent,'position',position);
updateLayout(mtexFig);
set(mtexFig.parent,'ResizeFcn',@(src,evt) updateLayout(mtexFig));

% update colorrange
if check_option(varargin,'colorrange')
  mtexFig.CLim(get_option(varargin,'colorrange'),varargin{:});
end

% update scale bars
for i = 1:numel(mtexFig.children)
  mP = getappdata(mtexFig.children(i),'mapPlot');
  if ~isempty(mP), mP.micronBar.update; end  
end

% maybe we should switch to zBuffer
if getMTEXpref('openglBug') && isRGB(mtexFig.parent)
  try
    set(mtexFig.parent,'renderer','zBuffer');
  end
end

end
