function hh = uitabpanel(varargin)

% UITABPANEL adds a group of tabbed uipanel container objects to a figure.
%   The user can click on a tab with the left mouse button to select it.
%   One tab is always selected, and appears on top of all the orthers.
%   The syntax is the same as UIPANEL except the following property changes:
%
%     Property              Values
%     -------------------   -------------------------------------------------
%     Title                 a cell array of strings specifying the title of
%                           each tab
%     String                (same as Title)
%     TitlePosition         the location of tabs in relation of the visible
%                           panel, the value is the same as UIPANEL
%     Style                 (same as TitlePosition)
%     FrameBackgroundColor  the background color for the tabpanel frame 
%     FrameBorderType       the border type for the tabpanel frame
%     PanelBackgroundColor  the background color for the active tab/panel
%     TitleHighlightColor   the highlight color for the active tab
%     TitleForegroundColor  the foreground color for tab titiles
%     TitleBackgroundColor  the background color for the inactive tabs
%     SelectedItem          index specifying the currently active tab
%
%   A yet another type of UITABPANEL is a group of popup panels, which
%   toggles open and close of a panel when its titile is clicked. Additional
%   properties for popup tabpanel are:
%
%     Property              Values
%     -------------------   -------------------------------------------------
%     Style                 'popup'
%     PanelHeights          a numeric array specfying the height in 
%                           characters of each popup panel
%     PanelBorderType       the border type for the popup panels
%     TitleHighlightColor   (not applicable)
%  
%   By defining 'CreateFcn', MATLAB will build the group of panels at 
%   creation of UITABPANEL. An array of handles of the UIPANELs can
%   be retrieved by calling getappdata(hTabpanel,'panels').
%
%   Example:
%     htab = uitabpanel('title',{'1','2','3'})
%     hpanel = getappdata(htab,'panels')
%   
%     See also uitabdemo, uipanel, uicontrol, set, get.
  
% Author: Shiying Zhao (zhao@arch.umsl.edu)
% Version: 1.0
% First created: May 02, 2006
% Last modified: May 20, 2006

tag = '';
units = 'normalized';
position = [0,0,1,1];
fontweight = 'normal';
[style,type] = deal('lefttop',2);
visible = 'on';

foregroundcolor = [0,0,0];
backgroundcolor = [0.7725,0.8431,0.9608];
panelbackgroundcolor = [0.4314,0.5882,0.8431];
titlehighlightcolor = [1,0.8,0];

horizontalalignment = 'center';
[createfcn,deletefcn,resizefcn] = deal({},{},{});

active = 0;
styles = {'popup','lefttop','righttop','leftbottom','rightbottom', ...
  'centertop','centerbottom'};

for k=1:2:nargin
  property = lower(varargin{k});
  value = varargin{k+1};
  switch property
    case {'style','tabposition','titleposition'}
      style = value;
      type = strmatch(lower(style),styles);
      if isempty(type)
        error(['Bad value for Style/TitlePosition property: ' style '.']);
      end
    case {'title','string'}
      string = value;
      ntab = length(string);
    case {'frameposition','position'}
      position = value;
    case {'framebackgroundcolor','backgroundcolor'}
      backgroundcolor = value;
    case {'framebordertype','bordertype'}
      bordertype = value;
    case {'panelheights','heights'}
      panelheight = value;
    case {'titleforegroundcolor','foregroundcolor'}
      foregroundcolor = value;
    case {'selecteditem','active'}
      active = value;
    otherwise
      eval([property '= value;']);
  end
end

if ~exist('parent','var')
  parent = gcf;
end
if ~exist('margins','var')
  if type==1
    margins = {[1.5,0.75,1.5,1],'characters'};
  else
    margins = {1,'pixels'};
  end
end
if ~iscell(margins)
  margins = {margins,units};
end

if ~exist('bordertype','var')
  if type==1
    bordertype = 'etchedin';
  else
    bordertype = 'none';
  end
end

if ~exist('titlebackgroundcolor','var')
  titlebackgroundcolor = 0.95*panelbackgroundcolor;
end

cmenu = uicontextmenu;
uimenu(cmenu,'Label','Goto Tab');
uimenu(cmenu,'Separator','on');

htab = uipanel( ...
  'Parent',parent, ...
  'Units',units, ...
  'Position',position, ...
  'DeleteFcn',deletefcn, ...
  'ResizeFcn',resizefcn, ...
  'BackgroundColor',backgroundcolor, ...
  'BorderType',bordertype, ...
  'UIContextMenu',cmenu, ...
  'Visible',visible, ...
  'Tag',tag);
set(htab,'Units','pixels');
tabpos = get(htab,'Position');

status = uicontainer( ...
  'Parent',htab, ...
  'BackgroundColor',backgroundcolor, ...
  'Units',margins{2}, ...
  'Position',[1,1,1,1], ...
  'UIContextMenu',cmenu, ...
  'Visible','off');
set(status,'Units','pixels');
charsz = get(status,'Position');
margins = [charsz(1:2),charsz(1:2)].*margins{1};
set(status,'Units','characters');
set(status,'Position',[1,1,1,1]);
set(status,'Units','pixels');
charsz = get(status,'Position');
titleheight = 1.5*charsz(4);

if type==1
  %--------------------------------------------------------------------------
  %  PopupTab
  %--------------------------------------------------------------------------
  panelpos = tabpos;
  titlepos = [margins(1),tabpos(2)+tabpos(4)-titleheight-margins(2), ...
    tabpos(3)-sum(margins([1,3])),titleheight];
  ttextpos = [0.05,0.1,0.9,0.76];
  
  if ~exist('panelheight','var')
    panelheight = ones(1,ntab);
  end
  if ~exist('panelbordertype','var')
    panelbordertype = 'line';
  end

  for k=1:ntab
    title(k) = uicontrol( ...
      'Parent',htab, ...
      'Units','pixels', ...
      'Position',titlepos, ...
      'ForegroundColor',foregroundcolor, ...
      'BackgroundColor',titlebackgroundcolor, ...
      'FontWeight',fontweight, ...
      'HorizontalAlignment',horizontalalignment, ...
      'Callback',{@PopupTabCbk,k}, ...
      'Style','toggle', ...
      'String',string{k}, ...
      'Value',0, ...
      'Visible','on');

    panel(k) = uipanel( ...
      'Parent',htab, ...
      'Units','pixels', ...
      'Position',titlepos+[0,0,0,panelheight(k)*charsz(4)], ...
      'BackgroundColor',panelbackgroundcolor, ...
      'BorderType',panelbordertype, ...
      'Visible','off');

    uimenu(cmenu, ...
      'Label',string{k}, ...
      'Callback',{@PopupTabCbk,k});
  end
  
  uimenu(cmenu,'Separator','on');
  uimenu(cmenu, ...
    'Label','Expand All', ...
    'Callback',{@PopupTabEnableAllCbk,'on'});
  uimenu(cmenu, ...
    'Label','Collapse All', ...
    'Callback',{@PopupTabEnableAllCbk,'off'});

  sliderpos = [tabpos(3)-14,2,15,tabpos(4)-3];
  slider = uicontrol( ...
    'Parent',htab, ...
    'Units','pixels', ...
    'Position',sliderpos, ...
    'BackgroundColor',panelbackgroundcolor, ...
    'Style','slider', ...
    'Callback',@PopupTabSliderCbk, ...
    'Value',0, ...
    'Min',-1, ...
    'Max',0, ...
    'Visible','off');

  statuspos = titlepos;
  statuspos([2,4]) = [margins(4),panelpos(4)-(ntab+1)*(margins(4)+titlepos(4))];
  set(status,'Position',statuspos);
  PopupTabCbk(title(1),[],active);
  set(status,'ResizeFcn',@PopupTabResizeCbk);

else
  %--------------------------------------------------------------------------
  %  TopT/Bottom Tab
  %--------------------------------------------------------------------------
  margins(3:4) = -(margins(1:2)+margins(3:4));
  switch type
    case 2 %lefttop
      [loop,sign] = deal(1:ntab,[1,0,1,0]);
    case 3 %righttop
      [loop,sign] = deal(ntab:-1:1,[ntab,0,0,0]);
    case 4 %lefttbottom
      [loop,sign] = deal(1:ntab,[1,0,1,1]);
    case 5 %rightbottom
      [loop,sign] = deal(ntab:-1:1,[ntab,0,0,1]);
    case 6 %centertop
      [loop,sign] = deal(1:ntab,[1,ntab,1,0]);
    case 7 %centerbottom
      [loop,sign] = deal(1:ntab,[1,ntab,1,1]);
  end
  addtitle = 2*[sign(3:4),-1,-1];
  if sign(3)
    ttextpos = [0.05,0.08,0.9,0.76];
  else
    ttextpos = [0.05,0.05,0.9,0.76];
  end
  
  if ~exist('panelbordertype','var')
    panelbordertype = 'beveledout';
  end
  
  for k=1:ntab
    title(k) = uipanel( ...
      'Parent',htab, ...
      'Units','pixels', ...
      'BackgroundColor',titlebackgroundcolor, ...
      'BorderType',panelbordertype, ...
      'ButtonDownFcn',{@TopBottomTabCbk,k}, ...
      'Visible','on');
    %titlewidth(k) = (length(string{k})+4)*1.2*charsz(3);

    ttext(k) = uicontrol( ...
      'Parent',title(k), ...
      'Units','normalized', ...
      'Position',ttextpos, ...
      'ForegroundColor',foregroundcolor, ...
      'BackgroundColor',titlebackgroundcolor, ...
      'HorizontalAlignment',horizontalalignment, ...
      'Style','text', ...
      'String',string{k}, ...
      'Enable','inactive', ...
      'HitTest','off',...
      'Visible','on');

    panel(k) = uipanel( ...
      'Parent',htab, ...
      'Units','pixels', ...
      'BackgroundColor',panelbackgroundcolor, ...
      'BorderType',panelbordertype, ...
      'Visible','off');

    uimenu(cmenu, ...
      'Label',string{k}, ...
      'Callback',{@TopBottomTabCbk,k});
  end

  if ~active, active = 1; end
  set(panel(active),'Visible','on');
  setappdata(htab,'value',active);
  
  inset(1) = uicontrol( ...
    'Parent',htab, ...
    'Units','pixels', ...
    'BackgroundColor',panelbackgroundcolor, ...
    'Style','text', ...
    'Visible','on');
  if ~isnan(titlehighlightcolor)
    inset(2) = uicontrol( ...
      'Parent',htab, ...
      'Units','pixels', ...
      'BackgroundColor',titlehighlightcolor, ...
      'Style','text', ...
      'Visible','on');
    inset(3) = uicontrol( ...
      'Parent',htab, ...
      'Units','pixels', ...
      'BackgroundColor',0.85*titlehighlightcolor, ...
      'Style','text', ...
      'Visible','on');
  end
  
  TopBottomTabResizeCbk(status,[]);
  set(status,'ResizeFcn',@TopBottomTabResizeCbk);
end

setappdata(htab,'panels',panel);
setappdata(htab,'status',status);
if ~isempty(createfcn)
  createfcn(htab,[],panel,status);
end

if nargout, hh = htab; end


%--------------------------------------------------------------------------
% Inner Functions for Popup Tab
%--------------------------------------------------------------------------
  function PopupTabCbk(hobj,evdt,indx)

    set(title,'Value',0);
    if indx>0
      indxvis = strcmp(get(panel(indx),'Visible'),'off');
      if indxvis
        set(panel(indx),'Visible','on');
      else
        set(panel(indx),'Visible','off');
      end
    end
    if isempty(strmatch('on',get(panel,'Visible')))
      set(status,'Visible','on');
    else
      set(status,'Visible','off');
    end

    currval = get(slider,'Value');
    if currval<0
      set(slider,'Value',0);
      PopupTabSliderCbk(slider,evdt);
    end
    titlepos = get(title(1),'Position');
    addtolen = titlepos(2)+titlepos(4)+margins(4);

    for k=1:ntab
      titlepos = get(title(k),'Position');
      titlepos(2) = addtolen-titlepos(4)-margins(4);
      set(title(k),'Position',titlepos);
      addtolen = titlepos(2);
      visible = strcmp(get(panel(k),'Visible'),'on');
      if visible
        panelpos = get(panel(k),'Position');
        addtolen = addtolen-panelpos(4);
        panelpos(2) = addtolen;
        set(panel(k),'Position',panelpos);
      end
    end

    if visible
      botpos = get(panel(ntab),'Position');
    else
      botpos = get(title(ntab),'Position');
    end

    visible = strcmp(get(slider,'Visible'),'on');
    addwidth = (-1)^(~visible);
    if botpos(2)*addwidth>0
      if visible
        set(slider,'Visible','off');
      else
        set(slider,'Visible','on');
      end
    else
      if visible
        addwidth = 0;
      else
        return;
      end
    end

    addwidth = addwidth*sliderpos(3);
    for k=1:ntab
      titlepos = get(title(k),'Position');
      titlepos(3) = titlepos(3)+addwidth;
      set(title(k),'Position',titlepos);
      set(title(k),'UserData',titlepos(2));

      panelpos = get(panel(k),'Position');
      panelpos(3) = panelpos(3)+addwidth;
      set(panel(k),'Position',panelpos);
      set(panel(k),'UserData',panelpos(2));
    end

    toplen = botpos(2)-margins(2);
    if toplen>0
      set(slider,'Value',0);
      return;
    end

    try
      if indxvis
        viewpos = get(panel(indx),'Position');
        if viewpos(2)-viewpos(4)<0
          if viewpos(4)+margins(4)<=tabpos(4);
            currval = min(0,viewpos(2)-margins(4)/2);
          else
            viewpos = get(title(indx),'Position');
            currval = viewpos(2)+viewpos(4)+margins(4)/2-tabpos(4);
          end
        end
      end
    catch
    end

    set(slider,'Min',toplen);
    set(slider,'Value',max(currval,toplen));
    set(slider,'SliderStep',[0.3,1]/max(1,-toplen/100));
    PopupTabSliderCbk(slider,evdt);

  end


%--------------------------------------------------------------------------
  function PopupTabSliderCbk(hobj,evdt)

    currval = get(hobj,'Value');
    for k=1:ntab
      titlepos = get(title(k),'Position');
      titlepos(2) = get(title(k),'UserData')-currval;
      set(title(k),'Position',titlepos);
      panelpos = get(panel(k),'Position');
      panelpos(2) = get(panel(k),'UserData')-currval;
      set(panel(k),'Position',panelpos);
    end

  end


%--------------------------------------------------------------------------
  function PopupTabEnableAllCbk(hobj,evdt,cstr)

    set(panel,'Visible',cstr);
    PopupTabCbk(hobj,evdt,0);

  end


%--------------------------------------------------------------------------
  function PopupTabResizeCbk(hobj,evdt)

    oldpos = tabpos;
    units = get(htab,'Units');
    set(htab,'Units','pixels');
    tabpos = get(htab,'Position');
    set(htab,'Units',units);

    addtopos = tabpos-oldpos;
    sliderpos([1,2,4]) = sliderpos([1,2,4])+addtopos([1,2,4]);
    set(slider,'Position',sliderpos);

    addtopos = [tabpos(3:4)-oldpos(3:4),0,0];
    currval = get(slider,'Value');
    if currval<0
      set(slider,'Value',0);
      PopupTabSliderCbk(slider,evdt);
    end

    for k=1:ntab
      titlepos = get(title(k),'Position');
      set(title(k),'Position',titlepos+addtopos);
    end
    PopupTabCbk(title(1),evdt,0);

    visible = strcmp(get(slider,'Visible'),'on');
    if visible & currval<0
      set(slider,'Value',max(currval,get(slider,'Min')));
      PopupTabSliderCbk(slider,evdt);
    end

  end


%--------------------------------------------------------------------------
% Inner Functions for Top/Bottom Tab
%--------------------------------------------------------------------------
  function TopBottomTabCbk(hobj,evdt,indx)

    if active==indx, return; end

    % deactivate tab(active)
    n = active;
    titlepos = get(title(n),'Position');
    titlepos = titlepos+addtitle.*[n==sign(1),1,n==sign(1),1];
    titlepos(3) = titlepos(3)+addtitle(3)*(n==sign(2));
    set(title(n),'Position',titlepos,'BackgroundColor',titlebackgroundcolor);
    set(ttext(n),'FontWeight','normal','BackgroundColor',titlebackgroundcolor);
    set(panel(n),'Visible','off');

    % activate tab(indx)
    active = indx;
    titlepos = get(title(indx),'Position');
    titlepos = titlepos-addtitle.*[indx==sign(1),1,indx==sign(1),1];
    titlepos(3) = titlepos(3)-addtitle(3)*(indx==sign(2));
    
    set(title(indx),'Position',titlepos,'BackgroundColor',panelbackgroundcolor);
    set(ttext(indx),'FontWeight','bold','BackgroundColor',panelbackgroundcolor);
    insetpos = [titlepos(1)+1,titlepos(2)+sign(4)*titlepos(4)-2,titlepos(3)-1,3];
    set(inset(1),'Position',insetpos);
    try
      insetpos = insetpos+[0,(1-2*sign(4))*titleheight+2*sign(4),0,-2];
      set(inset(2),'Position',insetpos);
      set(inset(3),'Position',insetpos+[2,1-2*sign(4),-4,0]);
    catch
    end
    set(panel(indx),'Visible','on');
    setappdata(htab,'value',indx);

    if isappdata(htab,'SelectionChangeFcn')
      SelectionChangeFcn = getappdata(htab,'SelectionChangeFcn');
      eventdata = struct('EventName','SelectionChanged', ...
        'OldValue',n,'NewValue',indx,'Panels',panel,'Status',status);
      if iscell(SelectionChangeFcn)
        SelectionChangeFcn{1}(hobj,eventdata,SelectionChangeFcn{2:end});
      else
        SelectionChangeFcn(hobj,eventdata);
      end
    end

  end


%--------------------------------------------------------------------------
  function TopBottomTabResizeCbk(hobj,evdt)

    units = get(htab,'Units');
    set(htab,'Units','pixels');
    tabpos = get(htab,'Position');
    set(htab,'Units',units);

    titlepos = [0,0,0,titleheight];
    if sign(4)
      panelpos = [0,titleheight+1,tabpos(3),tabpos(4)-titleheight]+margins;
      titlepos(2) = panelpos(2)-titlepos(4);
    else
      panelpos = [0,0,tabpos(3),tabpos(4)-titleheight]+margins;
      titlepos(2) = panelpos(2)+panelpos(4);
    end
    set(panel,'Position',panelpos);
    
    n = sum(cellfun('length',string))+2*ntab;
    if type<6
      if (n+2*ntab)*1.2*charsz(3)+2>panelpos(3)
        [loop,sign(1:3)] = deal(1:ntab,[1,ntab,1]);
      else
        if type==2 | type==4
          [loop,sign(1:3)] = deal(1:ntab,[1,0,1]);
        else
          [loop,sign(1:3)] = deal(ntab:-1:1,[ntab,0,0]);
        end
      end
      addtitle = 2*[sign(3:4),-1,-1];
    end
    titlepos(1) = panelpos(1)+(1-sign(3))*panelpos(3);
    for k=loop
      if sign(2)
        titlepos(3) = panelpos(3)*(length(string{k})+2)/n;
        addtopos = addtitle.*[k==1,1,k==1|k==ntab,1];
      else
        titlepos(3) = (length(string{k})+4)*1.2*charsz(3);
        addtopos = addtitle.*[k==sign(1),1,k==sign(1),1];
      end
      titlepos(1) = titlepos(1)-(1-sign(3))*titlepos(3);
      set(title(k),'Position',titlepos+addtopos);
      titlepos(1) = titlepos(1)+sign(3)*titlepos(3);
    end

    statuspos = titlepos;
    statuspos(1) = sign(3)*titlepos(1)+2;
    statuspos(3) = titlepos(1)+sign(3)*(tabpos(3)-2*titlepos(1))-4;
  
    titlepos = get(title(active),'Position');
    titlepos = titlepos-addtitle.*[active==sign(1),1,active==sign(1),1];
    titlepos(3) = titlepos(3)-addtitle(3)*(active==sign(2));
    set(title(active),'Position',titlepos,'BackgroundColor',panelbackgroundcolor);
    set(ttext(active),'FontWeight','bold','BackgroundColor',panelbackgroundcolor);

    insetpos = [titlepos(1)+1,titlepos(2)+sign(4)*titlepos(4)-2,titlepos(3)-1,3];
    set(inset(1),'Position',insetpos);
    try
      insetpos = insetpos+[0,(1-2*sign(4))*titleheight+2*sign(4),0,-2];
      set(inset(2),'Position',insetpos);
      set(inset(3),'Position',insetpos+[2,1-2*sign(4),-4,0]);
    catch
    end
    try
      % This causes the above statements being excuted twice for each resizing.
      set(status,'Position',statuspos,'Visible','on');
    catch
      set(status,'Visible','off');
    end

  end

end
