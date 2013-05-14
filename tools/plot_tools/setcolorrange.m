function setcolorrange(varargin)
% set color range for figures 
%
%% Syntax
%  setcolorrange([min max],'all')
%  setcolorrange('equal','current')
%  setcolorrange('tight','figure',figurelist)
%
%% Input
%  [min max]  - minimum and maximum value
%  figurelist - list of figure where the plots should be scaled  
%
%% Options
%  equal       - scale plots to the same range
%  tight       - scale plots individually
%  all         - scale all plots
%  current     - scale only plots in the current figure
%  figure      - scale only plots in figurelist
%  ZERO2WHITE  - color zero values white
%
%% See also
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
ax = findall(fig,'type','axes');
checkMultiplotAxis = @(a) ismember(a,getappdata(get(a,'parent'),'multiplotAxes'));
ax = ax(arrayfun(checkMultiplotAxis,ax));
if isempty(ax), return; end

% colorbaraxes
cax = findall(fig,'type','axes','tag','colorbaraxis');

if check_option(varargin,'equal')

  % ensure same scale in all plots
  if ~equal(strcmp(get(cax,'zscale'),'log'),1)
    error('You can not mix logarithmic and non logarithmic plots with equal colorrange')
  end
    
  % find maximum color range
  c = zeros(length(ax),2);
  for i = 1:length(ax)
    c(i,:) = caxis(ax(i));
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
  if any(strcmp(get(cax,'zscale'),'log')), p = log10(p);end
         
else
  
  error('First argument must either be the color range or the flag ''equal''');  
  
end

if exist('p','var')
  
  % set the caxis to all axes
  for i = 1:numel(ax),	caxis(ax(i),p);end

  % set the caxis to all colorbaraxes
  for i = 1:numel(cax)
    if strcmp(get(cax(i),'zscale'),'log')
      caxis(cax(i),10.^p);
    else
      caxis(cax(i),p);
    end
  end
  
end
