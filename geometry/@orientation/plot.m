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

% plotting
switch get(mtexFig.parent,'tag')
  
  case 'pdf' % pole figure annotations
      
    plotPDF(ori,[],varargin{:});
    
  case 'ipdf' % inverse pole figure annotations
      
    plotIPDF(ori,[],varargin{:});
  
  case 'odf' % ODF sections plot
    
    plotSection(ori,varargin{:});
    
  otherwise
    
    scatter(ori,varargin{:});              
    
end
