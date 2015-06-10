function plot(ori,varargin)
% annotate a orientation to an existing plot
%
% Input
%  ori - @orientation
%
% Options
%
% See also
% orientation/scatter Plotting

[mtexFig,isNew] = newMtexFigure(varargin{:});

if isNew
  
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
    
    plotODF(ori,varargin{:});
    
  otherwise
    
    scatter(ori,varargin{:});              
    
end
