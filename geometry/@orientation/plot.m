function plot(ori,varargin)
% annotate a orientation to an existing plot
%
% Syntax
%   plot(ori)
%   plot(ori,'label','o1')
%
% Input
%  ori - @orientation
%
% Options
%
% See also
% orientation/scatter orientation/plotPDF orientation/plotODF
% orientation/plotIPDF vector3d/text

[mtexFig,isNew] = newMtexFigure(varargin{:});

if isNew || isappdata(mtexFig.gca,'orientationPlot')
  
  scatter(ori,varargin{:})
  return;

elseif isappdata(mtexFig.parent,'ODFSections')

  oS = getappdata(mtexFig.parent,'ODFSections');
  oS.plot(ori,varargin{:});
  return
  
end

if check_option(varargin,'add2all')
  allAxes = mtexFig.children;
else
  allAxes = get_option(varargin,'parent',mtexFig.currentAxes);
end
varargin = delete_option(varargin,{'add2all','parent'});

% plotting
for ax = allAxes(:).'
  switch get(ax,'tag')
  
    case 'pdf' % pole figure annotations
      
      plotPDF(ori,varargin{:},'parent',ax,'noTitle');
    
    case 'ipdf' % inverse pole figure annotations
      
      plotIPDF(ori,varargin{:},'parent',ax,'noTitle');
  
    case 'odf' % ODF sections plot
    
      plotSection(ori,varargin{:},'parent',ax);
    
    otherwise
    
      scatter(ori,varargin{:},'parent',ax);
  end
end
