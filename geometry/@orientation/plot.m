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

hold on
[mtexFig,isNew] = newMtexFigure(varargin{:});

if isNew
  disp('Do something fancy here.');
  return;  
end

% plotting
switch get(mtexFig.parent,'tag')
  
  case 'quaternionScatter' % quaternion scatter plot      
      
    scatter(ori,varargin{:});          
  
  case 'pdf' % pole figure annotations
      
    plotPDF(ori,[],varargin{:});
    
  case 'ipdf' % inverse pole figure annotations
      
    plotIPDF(ori,[],varargin{:});
  
  case 'odf' % ODF sections plot
    
    plotODF(ori,varargin{:});
    
  otherwise
    
    error('Do not know how to plot orientation.')
    
end
