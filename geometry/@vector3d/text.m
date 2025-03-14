function h = text(v,varargin)
% display a text in a spherical plot
%
% Syntax
%   text(v,s)
%   text(v,s,'fontSize',16)
%   text(v,s,'textAboveMarker')
%   text(v,s,'textColor','blue')
%   text(v,s,'textBackgroundColor','white')
%
% Input
%  v  - @vector3d
%  s  - string
%
% Options
%  textColor - rgb or color name
%  textAboveMarker - display the text above the marker
%
% See also

if check_option(varargin,'add2all')
  mtexFig = gcm;
  if isempty(gcm)
    ax = gca;
  else
    ax = mtexFig.children;
  end
  ax = get_option(varargin,'parent',ax);
  varargin = delete_option(varargin,'parent',1);
  varargin = delete_option(varargin,'add2all');
  
  for i = 1:length(ax)
    if strcmpi(get(gca,'PlotBoxAspectRatioMode'),'manual') % check for 3d plot
      hold(ax(i),'on');
      arrow3d(v,varargin{:},'parent',ax(i));
      text3(v,varargin{:},'parent',ax(i));
    else
      text(v,varargin{:},'parent',ax(i));
    end
  end
  
  return
end


% initialize spherical plot
sP = newSphericalPlot(v,varargin{:},'hold');
h = [];
interpreter = getMTEXpref('textInterpreter');
fs = getMTEXpref('FontSize');
varargin = delete_option(varargin,'parent',1);

if check_option(varargin,'textAboveMarker')
  aboveBelow = -1;
elseif check_option(varargin,'autoAlignText')
  aboveBelow = 0;
else % textBelowMarker
  aboveBelow = 1;
end

for j = 1:numel(sP)

  % project data
  [x,y] = project(sP(j).proj,v,varargin{:});

  % special option -> labeled
  if check_option(varargin,'labeled')

    strings = cell(1,length(v));
    for i = 1:length(v), strings{i} = char(v.subSet(i),getMTEXpref('textInterpreter')); end

  elseif isnumeric(varargin{1})  % ensure cell as input
    
    strings = ensurecell(xnum2str(varargin{1},'cell'));
    
  else
    strings = ensurecell(varargin{1});
  end

  if length(v)>1 && isscalar(strings), strings = repmat(strings,length(v),1); end
  
  % print labels  
  for i = 1:length(strings)
    
    if isnan(x(i)), continue; end
    
    s = strings{i};
    if ~ischar(s) && ~isstring(s), s = char(s,interpreter);end

    if strcmpi(interpreter,'LaTeX') && ~isempty(regexp(s,'[\\\^_]','ONCE'))
      s = ['$' s '$']; %#ok<AGROW>
    end

    if check_option(varargin,'addMarkerSpacing')
      
      xy = [x(i),y(i)];
            
      if aboveBelow == -1 || (aboveBelow == 0 && ...
          xor(sP(j).ax=="reverse",...
          xy(2) > mean(sP(j).bounds([2 4])) + 0.1))
        tag = {'UserData',xy,'tag','setAboveMarker'};
      else
        tag = {'UserData',xy,'tag','setBelowMarker'}; 
      end
    else
      tag = {};
    end
    
    h = [h,optiondraw(text(x(i),y(i),s,'interpreter',interpreter,...
      'HorizontalAlignment','center','VerticalAlignment','middle',...
      tag{:},'margin',0.001,'parent',sP(j).ax),'FontSize',fs,varargin{2:end})]; %#ok<AGROW>
    
  end

  if check_option(varargin,'textcolor')
    [h.Color] = deal(str2rgb(get_option(varargin,'textcolor')));
  end

  % finish plot
  if isappdata(sP(1).parent,'mtexFig')
    mtexFig = getappdata(sP(1).parent,'mtexFig');
    mtexFig.drawNow(varargin{:});
  end
end

if nargout == 0, clear h;end

end

