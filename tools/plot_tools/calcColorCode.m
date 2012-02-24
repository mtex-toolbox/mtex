function [d,prop,opts] = calcColorCode(obj,subset,varargin)

prop = get_option(varargin,'property','orientation',{'char','double'});
opts = {};

if isempty(subset) || (numel(subset) == 1 && subset == 0)
  d = []; 
  return
else
  obj = obj(subset);
end

if numel(obj) == 0  % empty object
  
  d = [];
  
elseif isa(prop,'char')
  switch lower(prop)
    case {'orientation','mis2mean'}
      
      o = get(obj,prop);      
      
      colorcoding = lower(get_option(varargin,'colorcoding','ipdf'));
      if ischar(get(o,'CS')) || isempty(o)
        d = ones(numel(obj),3);  % ;NaN(numel(obj),3);
      else
        if strcmpi(prop,'mis2mean'), varargin = [varargin 'r','auto']; end
        [d,opts] = orientation2color(o,colorcoding,varargin{:});
      end
      
      prop = ['orientation.' colorcoding];
      
    case 'phase'
      
      cmap = get_mtex_option('phaseColorMap');
      
      phase = get(obj,'phase');     

      d = ones(numel(phase),3);
      d(phase>0,:)   = cmap(phase(phase>0),:); 
      
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

