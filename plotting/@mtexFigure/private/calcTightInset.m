function tightInset = calcTightInset(mtexFig)
% determine tight inset for each axis
  
tightInset = zeros(1,4);

if isempty(mtexFig.children), return; end
ax = mtexFig.children(1);
    
if strcmpi(get(ax,'visible'),'off')
  
  xtl = get(ax,'xTickLabel');
  ytl = get(ax,'yTickLabel');
  xl = get(ax,'xLabel');
  yl = get(ax,'yLabel');
  set(ax,'xTickLabel',[],'yTickLabel',[],'units','pixel');
  tightInset = get(ax,'tightInset');
  set(ax,'xTickLabel',xtl,'yTickLabel',ytl,'xlabel',xl,'ylabel',yl);
  
elseif strcmpi(get(ax,'PlotBoxAspectRatioMode'),'auto')
  
  tightInset = get(ax,'tightInset');
  
else
  
  axis(ax,'normal');
  tightInset = get(ax,'tightInset');
  axis(ax,'equal','tight');
  
end
    
 % consider also colorbar  
 if ~isempty(mtexFig.cBarAxis)
      
   pos = get(mtexFig.cBarAxis(1),'position');
   pos = pos(3:4);
   pos(pos==max(pos)) = 0;
      
   try
     tiPos = get(mtexFig.cBarAxis(1),'tightInset');
     tiPos = tiPos(1:2) + tiPos(3:4);
        
   catch
     tiPos = [3.5,1.5]*get(mtexFig.cBarAxis(1),'FontSize');
   end
   pos(pos>0) = pos(pos>0) + tiPos(pos>0);
    
   if numel(mtexFig.cBarAxis) == numel(mtexFig.children)
     tightInset = tightInset + [0,pos(2),pos(1),0];
   else
        
   end
 end
end
