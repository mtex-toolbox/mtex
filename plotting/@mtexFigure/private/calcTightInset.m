function [tightInset,figTightInset] = calcTightInset(mtexFig)
% determine tight inset for each axis
  

tightInset = zeros(1,4);
figTightInset = mtexFig.outerPlotSpacing * [1,1,1,1];

%return

if isempty(mtexFig.children), return; end
ax = mtexFig.children(1);

% a polar axes has none of the tick and label properties measured below, but
% it does report a tight inset of its own
if isa(ax,'matlab.graphics.axis.PolarAxes')
  if isprop(ax,'TightInset')
    unit = get(ax,'units'); set(ax,'units','pixel');
    tightInset = get(ax,'TightInset');
    set(ax,'units',unit);
  end
  return
end

if strcmpi(get(ax,'visible'),'off') || strcmpi(get(ax,'XColor'),'none')
  
  xtl = get(ax,'xTickLabel');
  ytl = get(ax,'yTickLabel');
  %xl = get(ax,'xLabel');
  %yl = get(ax,'yLabel');
  set(ax,'xTickLabel',[],'yTickLabel',[],'units','pixel');
  tightInset = get(ax,'tightInset');
  %set(ax,'xTickLabel',xtl,'yTickLabel',ytl,'xlabel',xl,'ylabel',yl);
  set(ax,'xTickLabel',xtl,'yTickLabel',ytl);
  
  % consider text labels
  txt = findall(ax,'type','text','unit','data');
  s = get(txt,'string');
  if ~iscell(s), s = {s}; end
  ind = cellfun(@isempty,s);
  txt = txt(~ind);
  if ~isempty(txt)
    pos = ensurecell(get(txt,'position'));
    set(txt,'unit','pixel')
    ext = cell2mat(ensurecell(get(txt,'extent')));
    %set(txt,'units','data');
    for i=1:length(txt), set(txt(i),'units','data','position',pos{i}); end
    pos = get(ax,'position');
    tightInset(1:2) = max([tightInset(1:2);-ext(:,1:2)]);
    tightInset(3:4) = max([tightInset(3:4);ext(:,1:2)+ext(:,3:4)-repmat(pos(3:4),size(ext,1),1)]);
  end
  
elseif all(get(ax,'ticklength') == 0)
  
  xt = get(ax,'xtick');
  yt = get(ax,'ytick');
  set(ax,'xtick',[],'ytick',[]);
  %axis(ax,'normal');
  tightInset = get(ax,'tightInset');  
  %axis(ax,'equal','tight');
  set(ax,'xtick',xt,'ytick',yt);
  
else %if strcmpi(get(ax,'PlotBoxAspectRatioMode'),'auto')

  tightInset = get(ax,'tightInset');

end


 % consider colorbar  
 if ~isempty(mtexFig.cBarAxis)
      
   pos = get(mtexFig.cBarAxis(1),'position');
   pos = pos(3:4);
   pos(pos==max(pos)) = 0;
   fs = get(mtexFig.cBarAxis(1),'FontSize');
   
   try
     tiPos = get(mtexFig.cBarAxis(1),'tightInset');
     tiPos = tiPos(1:2) + tiPos(3:4);
        
   catch
     l = get(mtexFig.cBarAxis(1),'Label');
     s = get(l,'String');
     if isempty(s)
       tiPos = [3.5,1.5] * fs;
     elseif get(l,'Rotation') == 0
       tiPos = [3.5,3.5] * fs;
     else
       tiPos = [5.5,1.5] * fs;
     end
   end
   mtexFig.cBarShift = tiPos(pos>0) + fs / 2;

   pos(pos>0) = pos(pos>0) + mtexFig.cBarShift + fs / 2;

   % reserve the band on the side the colorbar was asked for - pos(1) is the
   % thickness of a vertical bar, pos(2) that of a horizontal one, the other
   % having been zeroed above
   band = zeros(1,4); % [left bottom right top]
   switch mtexFig.cBarSide
     case 'west'
       band(1) = pos(1);
     case 'north'
       band(4) = pos(2);
     case 'south'
       band(2) = pos(2);
     otherwise % east
       band(3) = pos(1);
   end

   if numel(mtexFig.cBarAxis) == numel(mtexFig.children)
     tightInset = tightInset + band;
   else
     figTightInset = figTightInset + band;
   end
 end
 
 % consider a legend placed outside the axes - reserve a band of its size
 % plus the requested spacing, so that the legend does not eat into the
 % space given to the axes. It is positioned within that band in
 % updateLayout.
 if ~isempty(mtexFig.legendAxis) && all(isgraphics(mtexFig.legendAxis))

   set(mtexFig.legendAxis,'Units','pixels');
   pos = get(mtexFig.legendAxis,'Position');

   switch mtexFig.legendSide
     case 'east'
       figTightInset(3) = figTightInset(3) + pos(3) + mtexFig.legendSpacing;
     case 'west'
       figTightInset(1) = figTightInset(1) + pos(3) + mtexFig.legendSpacing;
     case 'north'
       figTightInset(4) = figTightInset(4) + pos(4) + mtexFig.legendSpacing;
     case 'south'
       figTightInset(2) = figTightInset(2) + pos(4) + mtexFig.legendSpacing;
   end
 end

 % consider sgtitle
 h = findobj(gcf,'Type','subplottext');
 if ~isempty(h)
   figTightInset(4) = figTightInset(4) + 2.5*h(1).FontSize;
 end
 
end
