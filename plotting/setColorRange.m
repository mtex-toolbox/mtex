function setColorRange(varargin)
% set color range for figures 
%
% Syntax
%   setColorRange([min max],'all')
%   setColorRange('equal','current')
%   setColorRange('tight','figure',figurelist)
%
% Input
%  [min max]  - minimum and maximum value
%  figurelist - list of figure where the plots should be scaled  
%
% Options
%  equal       - scale plots to the same range
%  tight       - scale plots individually
%  all         - scale all plots
%  current     - scale only plots in the current figure
%  figure      - scale only plots in figurelist
%  zero2white  - color zero values white
%
% See also
% multiplot S2Grid/plot

% which figures to touch
if check_option(varargin,'all')  
  fig = 0;
elseif check_option(varargin,'current')
  fig = gcf;
else
  fig = get_option(varargin,'figure',gcf);
end

% find all axes
mtexFig = getappdata(fig,'mtexFig');
if isempty(mtexFig.children), return; end

if check_option(varargin,'equal')

  % ensure same scale in all plots
  if ~equal(strcmp(get(mtexFig.cBarAxis,'zscale'),'log'),1)
    error('You can not mix logarithmic and non logarithmic plots with equal colorrange')
  end
    
  % find maximum color range
  c = zeros(length(mtexFig.children),2);
  for i = 1:length(mtexFig.children)
    c(i,:) = caxis(mtexFig.children(i));
  end
  mi = min(c,[],1);
  ma = max(c,[],1);
  p = [mi(1),ma(2)];

elseif check_option(varargin,'tight')  
  
  p = 'auto';  
  
elseif length(varargin)>=1 && isa(varargin{1},'double') &&...
    length(varargin{1})==2  
  
  p = varargin{1};
  
  % logarithmic scale?
  if any(strcmp(get(mtexFig.cBarAxis,'zscale'),'log')), p = log10(p);end
         
else
  
  error('First argument must either be the color range or the flag ''equal''');  
  
end

if exist('p','var')
  
  % set the caxis to all axes
  for i = 1:numel(mtexFig.children)
    caxis(mtexFig.children(i),p);
  end

  % set the caxis to all colorbaraxes
  for i = 1:numel(mtexFig.cBarAxis)
    if strcmp(get(mtexFig.cBarAxis(i),'zscale'),'log')
      caxis(mtexFig.cBarAxis(i),10.^p);
    else
      caxis(mtexFig.cBarAxis(i),p);
    end
  end
  
end
