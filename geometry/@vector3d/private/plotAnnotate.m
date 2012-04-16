function plotAnnotate( ax, varargin )
%PLOTANNOTATE Summary of this function goes here
%   Detailed explanation goes here


% tl tr bl br

t = getappdata(ax,'annotation');

if isempty(t)
  t.TL = get_option(varargin,{'TopLeft','TL'},'');
  t.TR = get_option(varargin,{'TopRight','TR'},'');
  t.BL = get_option(varargin,{'BottomLeft','BL'},'');
  t.BR = get_option(varargin,{'BottomRight','BR'},'');
  
  t = structfun(@(x) st2char(x), t,'UniformOutput',false);
  
  m = 0.005;
  if check_mtex_option('noLaTex')
    b = 0;
  else
    b = 0.015;
  end
  
  TL = text(0+m,1-b,t.TL,'parent',ax,'units','normalized');
  TR = text(1-m,1-b,t.TR,'parent',ax,'units','normalized');
  
  BL = text(0+m,0+b,t.BL,'parent',ax,'units','normalized');
  BR = text(1-m,0+b,t.BR,'parent',ax,'units','normalized');
  
  set([TL TR],'VerticalAlignment','top');
  set([BL BR],'VerticalAlignment','bottom');
  set([TL BL],'HorizontalAlignment','left');
  set([TR BR],'HorizontalAlignment','right');
  
  t.h = [TL TR BL BR];
  if check_mtex_option('noLaTex')
    set(t.h,'interpreter','tex');
  else
    set(t.h,'interpreter','latex');
  end
  
  opts = get_mtex_option('default_plot_options');
  
  optiondraw(t.h,varargin{:},opts{:},'FontName','times');
  
else  
  t.TL = get_option(varargin,{'TopLeft','TL'},t.TL);
  t.TR = get_option(varargin,{'TopRight','TR'},t.TR);
  t.BL = get_option(varargin,{'BottomLeft','BL'},t.BL);
  t.BR = get_option(varargin,{'BottomRight','BR'},t.BR);
  
  ta = structfun(@(x) st2char(x), t,'UniformOutput',false);
  ta.h = t.h;  t = ta;
  
  set(t.h(1),'String',t.TL);
  set(t.h(2),'String',t.TR);
  set(t.h(3),'String',t.BL);
  set(t.h(4),'String',t.BR);  
end

setappdata(ax,'annotation',t);



function s = st2char(t)

if isa(t,'Miller') || isa(t,'vector3d')
  for i = 1:length(t)
    if isOctave()
      s{i} =  char(subsref(t,i));
    elseif check_mtex_option('noLaTex')
      s{i} = char(subsref(t,i),'Tex');
    else
      s{i} = ['$' char(subsref(t,i),'LaTex') '$'];
    end
  end
else
  if iscell(t)
    s = t;
  elseif ~ischar(t)
    s = char(t);
  else
    s = t;
  end
  if ~check_mtex_option('noLaTex')
    if ~iscell(s) && ~isempty(regexp(s,'[\\\^_]','ONCE'))
      s = ['$' s '$'];
    end
  end
end


