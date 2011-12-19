function [d,prop] = calcColorCode(obj,subset,varargin)

prop = get_option(varargin,'property','orientation',{'char','double'});

obj = obj(subset);

if numel(obj) == 0  % empty object
  
  d = [];
  
elseif isa(prop,'char')
  switch lower(prop)
    case {'orientation','mis2mean'}
      
      o = get(obj,prop);
      
      if ischar(get(o,'CS')) || isempty(o)
        d = ones(numel(obj),3);  % ;NaN(numel(obj),3);
      else
        if strcmpi(prop,'mis2mean'), varargin = [varargin 'r','auto']; end
        d = orientation2color(o,lower(get_option(varargin,'colorcoding','ipdf')),varargin{:});
      end
      
    case lower(get(obj))
      
      d = get(obj,prop);
      
    case 'angle'
      
      d = angle(get(obj,'orientations'))/degree;
      
    otherwise
      
      error('Unknown colorcoding!')
      
  end
else
  d = prop(subset,:);
  prop = 'user';
end

if any(size(d)==1) && numel(obj) > 1
  d = d(:);
end

