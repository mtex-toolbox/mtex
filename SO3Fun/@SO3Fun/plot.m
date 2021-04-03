function varargout = plot(odf,varargin)
% plots odf or append to a previous plot using 'add2all'
%
% Syntax
%
%   % plot in phi2 sections
%   plot(odf)
%
%   % plot in specific phi2 sections
%   plot(odf,'phi2',45*degree)
%
%   % plot in 3d space
%   plot(odf,'axisAngle')
%   plot(odf,'rodrigues')
%   
%   % plot along a fibre
%   f = fibre.alpha(odf.CS)
%   plot(odf,f)
%
%   % plot the odf as sigma sections
%   oS = sigmaSections(odf.CS)
%   plot(odf,oS)
%
% See also
% ODF/plotSection ODF/plot3d ODF/plotFibre

% get current figure
[mtexFig,isNew] = newMtexFigure(varargin{:});

%
if isNew % old functionality in case plotting to a new figure
  if nargin > 1 && isa(varargin{1},'fibre')
    plotFibre(odf,varargin{:});
  elseif check_option(varargin,{'3d','axisAngle','rodrigues'})
    plot3d(odf,varargin{:});
  else
    plotSection(odf,varargin{:});  
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
  switch get(ax,'tag')
    
    case 'pdf' % pole figure annotations
        
      [varargout{1:nargout}] = plotPDF(odf,getappdata(ax,'h'),varargin{:},'parent',ax,'noTitle');
        
    case 'ipdf' % inverse pole figure annotations
        
      [varargout{1:nargout}] = plotIPDF(odf,getappdata(ax,'inversePoleFigureDirection'),varargin{:},'parent',ax,'noTitle');
        
  end
end

% TODO: store ODF section info on axis level
% because we may have mixed pole figures and ODF sections in one figure
if isappdata(mtexFig.parent,'ODFSections')
  [varargout{1:nargout}] = plotSection(odf,varargin{:});  
end

end