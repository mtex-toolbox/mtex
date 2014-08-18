function  drawNow(mtexFig, varargin)

if check_option(varargin,'doNotDraw'), return;end

set(mtexFig.children,'units','pixel');

rFcn = get(mtexFig.parent,'ResizeFcn');
rFcn(mtexFig.parent,[]);

% update children
 mtexFig.children = flipud(findobj(mtexFig.parent,'type','axes',...
   '-not','tag','Colorbar','-and','-not','tag','legend')); 

getTightInset;

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

if check_option(varargin,'colorrange')
  mtexFig.CLim(get_option(varargin,'colorrange'));
end



  function getTightInset
    % determine tight inset for each axis
    
    if isempty(mtexFig.children), return; end
    ax = mtexFig.children(1);
    
    if strcmpi(get(ax,'visible'),'off')
      xtl = get(ax,'xTickLabel');
      ytl = get(ax,'yTickLabel');
      xl = get(ax,'xLabel');
      yl = get(ax,'yLabel');
      set(ax,'xTickLabel',[],'yTickLabel',[]);
      mtexFig.tightInset = get(ax,'tightInset');
      set(ax,'xTickLabel',xtl,'yTickLabel',ytl,'xlabel',xl,'ylabel',yl);
    elseif strcmpi(get(ax,'PlotBoxAspectRatioMode'),'auto')
      mtexFig.tightInset = get(ax,'tightInset');
    else
      axis(ax,'normal');
      mtexFig.tightInset = get(ax,'tightInset');
      axis(ax,'equal','tight');
    end
    
    
    
    if ~isempty(mtexFig.cBarAxis)
      
      pos = get(mtexFig.cBarAxis(1),'position');
      pos = pos(3:4);
      pos(pos==max(pos)) = 0;
      
      
      try
        tiPos = get(mtexFig.cBarAxis(1),'tightInset');
        tiPos = tiPos(1:2) + tiPos(3:4);
        
      catch
        tiPos = [2.5,1.5]*get(mtexFig.cBarAxis(1),'FontSize');
      end        
      pos(pos>0) = pos(pos>0) + tiPos(pos>0);
    
      if numel(mtexFig.cBarAxis) == numel(mtexFig.children)
        mtexFig.tightInset = mtexFig.tightInset + [0,pos(2),pos(1),0];
      else
        
      end
    end
  end


end
