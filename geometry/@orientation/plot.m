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

if isNew
  
  scatter(ori,varargin{:})
  return;

elseif isappdata(mtexFig.parent,'ODFSections')

  oS = getappdata(mtexFig.parent,'ODFSections');
  oS.plot(ori,varargin{:});
  return

else
  
  for i = 1:length(mtexFig.children)
    
    sP = getappdata(mtexFig.children(i),'sphericalPlot');
    
    if isa(sP,'pfPlot')
      plotPDF(ori,varargin{:},'parent',mtexFig.children(i));
    elseif isa(sP,'ipfPlot')
      plotIPDF(ori,varargin{:},'parent',mtexFig.children(i));
    else
      scatter(ori,varargin{:},'parent',mtexFig.children(i));
    end
    
  end
  
end


end
