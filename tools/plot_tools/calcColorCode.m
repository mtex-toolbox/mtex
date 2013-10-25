function [d,prop,opts] = calcColorCode(obj,subset,prop,varargin)

opts = {};

if isempty(subset) || (numel(subset) == 1 && subset == 0)
  d = [];
  return
else
  obj = obj(subset);
end

% empty object
if isempty(obj), d = [];return;end

% special case phase
if isa(prop,'char') && strcmpi(prop,'phase')
  
  % extract colormaps
  cmap = getMTEXpref('EBSDColors');
  colorNames = getMTEXpref('EBSDColorNames');
  
  % preallocate color vector
  d = ones(length(obj),3);
  
  % for all phases
  for i = 1:numel(obj.phaseMap)
    
    if ~ischar(obj.CS{i})
      
      if isempty(get(obj.CS{i},'color'))
        
        index = i;
        
      else
        
        index = strmatch(get(obj.CS{i},'color'),colorNames);

      end
          
      ph = obj.phaseMap(i);
      d(obj.phase==ph,1) = cmap{index}(1);
      d(obj.phase==ph,2) = cmap{index}(2);
      d(obj.phase==ph,3) = cmap{index}(3);
    end
  end
  return
end
 
% try to extract property from object
if ischar(prop) 
  
  try
    d = obj.(prop);
  catch       %#ok<CTCH>
    d = NaN(length(obj),1);
  end
  
else % user defined property
  
  if size(prop,2) == 3
    d = prop(subset,:);
  else
    d = prop(subset);
  end
  
end
  
% if d is an orientation convert to color
if isa(d,'quaternion')
  
  % get colorcoding
  colorcoding = lower(get_option(varargin,'colorcoding','ipdfHSV'));
  prop = ['orientation.' colorcoding];
  
  if strcmpi(prop,'mis2mean'), varargin = [varargin 'r','auto']; end
  
  [d,opts] = orientation2color(d,colorcoding,varargin{:});
  
end

% convert to column vector
if any(size(d)==1) && numel(obj) > 1
  d = d(:);
end
