function varargout = plot(tV,varargin)
% plot a SO3Tangent vector
%
% Syntax
%   plot(tV)
%
% Input
%  tV - @SO3TangentVector
%
% Options
%

[mtexFig,isNew] = newMtexFigure(varargin{:});

if isNew || isappdata(mtexFig.gca,'orientationPlot')
  
  [varargout{1:nargout}] = quiver3(tV,varargin{:});
  return;

elseif isappdata(mtexFig.parent,'ODFSections')

  [varargout{1:nargout}] = quiverSection(tV,varargin{:});
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
  switch ax.Tag
  
    case 'pdf' % pole figure annotations

      tV = tV ./ max(norm(tV)) / 1000;

      [varargout{1:nargout}] = plotPDF(tV.rot,exp(tV),varargin{:},...
        'parent',ax,'noTitle');
    
    case 'ipdf' % inverse pole figure annotations
      
      [varargout{1:nargout}] = plotIPDF(ori,varargin{:},'parent',ax,'noTitle');
     
    otherwise
    
      [varargout{1:nargout}] = scatter(ori,varargin{:},'parent',ax);
  end
end

