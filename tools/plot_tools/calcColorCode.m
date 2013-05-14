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
    case {'orientation','mis2mean','orientations'}

      colorcoding = lower(get_option(varargin,'colorcoding','ipdfHSV'));
      
      try
        o = get(obj,prop);
      catch %#ok<CTCH>
        o = [];
      end
      
      if ischar(get(obj,'CS')) || isempty(obj)
        d = NaN(numel(obj),1);
      else
              
        if strcmpi(prop,'mis2mean'), varargin = [varargin 'r','auto']; end
        [d,opts] = orientation2color(o,colorcoding,varargin{:});
      
      end

      prop = ['orientation.' colorcoding];
        
            
    case 'phase'

      cmap = getMTEXpref('EBSDColors');
      colorNames = getMTEXpref('EBSDColorNames');

      phase = get(obj,'phase');
      phases = get(obj,'phases');

      cs =get(obj,'CSCell');
      d = ones(numel(phase),3);

      for i = 1:numel(phases)

        ph = phases(i);
        if ~ischar(cs{i})

          if isempty(get(cs{i},'color'))

            index = i;

          else

            index = strmatch(get(cs{i},'color'),colorNames);

          end
          d(phase==ph,1) = cmap{index}(1);
          d(phase==ph,2) = cmap{index}(2);
          d(phase==ph,3) = cmap{index}(3);
        end
      end

    case lower(get(obj))

      d = get(obj,prop);

    case 'angle'

      d = angle(get(obj,'orientations'))/degree;

    otherwise

      error('Unknown colorcoding!')

  end
else
  if size(prop,2) == 3
    d = prop(subset,:);
  else
    d = prop(subset);
  end
  prop = 'user';
end

if any(size(d)==1) && numel(obj) > 1
  d = d(:);
end
