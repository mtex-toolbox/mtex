function CLim(mtexFig,varargin)
% set color range for figures 
%
% Syntax
%   CLim(mtexFig,[min max])
%   CLim(mtexFig,'equal')
%   CLim(mtexFig,'tight')
%
% Input
%  mtexFig    - mtexFigure
%  [min max]  - minimum and maximum value
%
% Options
%  equal       - scale plots to the same range
%  tight       - scale plots individually
%
% See also
% mtexFigure

if check_option(varargin,'equal')

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
  %if any(strcmp(get(mtexFig.cBarAxis,'zscale'),'log')), p = log10(p);end
         
else
  
  error('First argument must either be the color range or the flag ''equal''');  
  
end

if exist('p','var')
  
  % set the caxis to all axes
  for i = 1:numel(mtexFig.children)
    caxis(mtexFig.children(i),p);
  end
end
