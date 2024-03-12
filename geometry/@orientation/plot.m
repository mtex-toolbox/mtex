function varargout = plot(ori,varargin)
% annotate a orientation to an existing plot
%
% Syntax
%   plot(ori)
%   plot(ori,'label','o1')
%   plot(ori,'MarkerFaceColor','blue')
%   plot(ori,'filled')
%
% Input
%  ori - @orientation
%
% Options
%  axisAngle - 3d axis angle plot
%  Rodrigues - 3d Rodrigues vector plot
%  Euler     - 3d Bunge Euler plot
%  points    - number of orientations to be plotted
%  MarkerFaceColor - fill color of the marker
%  MarkerEdgeColor - edge color of the marker
%  MarkerSize      - size of the marker
%  label           - a text displayed next to the marker
%  backgroundColor - background color of the text (none)
%
% Flags
%  axisAngle  -
%  filled  - MarkerFaceColor is MarkerEdgeColor
%
% See also
% orientation/scatter orientation/plotPDF orientation/plotODF
% orientation/plotIPDF vector3d/text

[mtexFig,isNew] = newMtexFigure(varargin{:});

if isNew || isappdata(mtexFig.gca,'orientationPlot')
  
  [varargout{1:nargout}] = scatter(ori,varargin{:});
  return;

elseif isappdata(mtexFig.parent,'ODFSections')

  oS = getappdata(mtexFig.parent,'ODFSections');
  [varargout{1:nargout}] = oS.plot(ori,varargin{:});
  return
  
end

if check_option(varargin,'add2all')
  allAxes = mtexFig.children;
else
  allAxes = get_option(varargin,'parent',mtexFig.currentAxes);
end
varargin = delete_option(varargin,{'add2all','parent'},[0,1]);

% plotting
for ax = allAxes(:).'
  switch get(ax,'tag')
  
    case 'pdf' % pole figure annotations
      
      [varargout{1:nargout}] = plotPDF(ori,varargin{:},'parent',ax,'noTitle');
    
    case 'ipdf' % inverse pole figure annotations
      
      [varargout{1:nargout}] = plotIPDF(ori,varargin{:},'parent',ax,'noTitle');
  
    case 'odf' % ODF sections plot
    
      [varargout{1:nargout}] = plotSection(ori,varargin{:},'parent',ax);
    
    otherwise
    
      [varargout{1:nargout}] = scatter(ori,varargin{:},'parent',ax);
  end
end
