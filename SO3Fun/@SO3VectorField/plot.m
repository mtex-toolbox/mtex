function varargout = plot(SO3VF,varargin)
% plot vector field on SO(3)
%
% Syntax
%   plot(SO3VF)
%
% Options
%  normalized - normalize vectors
%  arrowSize  - arrow size
%  maxHeadSize - head size
%
% See also
% S2VectorField/quiver3
%  

% get current figure
[mtexFig,isNew] = newMtexFigure(varargin{:});

%
if isNew % old functionality in case plotting to a new figure
  if check_option(varargin,{'3d','axisAngle','rodrigues'})
    quiver3(SO3VF,varargin{:});
  else
    quiverSection(SO3VF,varargin{:});
  end
  return;
end
  
% somehow assuming that add2all is supplied
if check_option(varargin,'add2all')
  allAxes = mtexFig.children;
else % this case is probably not needed at all
  allAxes = get_option(varargin,'parent',mtexFig.currentAxes);
end
varargin = delete_option(varargin,{'add2all','parent'},[0,1]);
  
for ax = allAxes(:).'
  switch ax.Tag
    
    case 'pdf' % pole figure annotations
        
      [varargout{1:nargout}] = plotPDF(SO3VF,getappdata(ax,'h'),varargin{:},'parent',ax,'noTitle');
        
    case 'ipdf' % inverse pole figure annotations
        
      [varargout{1:nargout}] = plotIPDF(SO3VF,getappdata(ax,'inversePoleFigureDirection'),varargin{:},'parent',ax,'noTitle');
        
  end
end

% TODO: store ODF section info on axis level
% because we may have mixed pole figures and ODF sections in one figure
if isappdata(mtexFig.parent,'ODFSections')
  [varargout{1:nargout}] = quiverSection(SO3VF,varargin{:});  
end

end
