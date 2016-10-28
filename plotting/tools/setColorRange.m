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

  % find maximum color range
  c = zeros(length(mtexFig.children),2);
  for i = 1:length(mtexFig.children)
    c(i,:) = caxis(mtexFig.children(i));
  end
  mi = min(c,[],1);
  ma = max(c,[],1);
  limits = [mi(1),ma(2)];

elseif check_option(varargin,'tight')  
  
  set(mtexFig.children,'CLimMode','auto');
  try
    set(mtexFig.cBarAxis,'LimitsMode','auto');
  catch
    set(mtexFig.cBarAxis,'CLimMode','auto');
  end
  return
    
elseif length(varargin)>=1 && isa(varargin{1},'double') &&...
    length(varargin{1})==2
    
  limits = varargin{1};
  
else
  
  error('First argument must either be the color range or the flag ''equal''');  
  
end

set(mtexFig.children,'CLim',limits);
  try
    set(mtexFig.cBarAxis,'Limits',limits);    
  catch
    set(mtexFig.cBarAxis,'CLim',limits);
  end