function s = get(p,vname,varargin)
% get some polygon properties

switch vname
  case 'xy'
    if check_option(varargin,'cell')
      s = {p.xy};
      return
    elseif check_option(varargin,'plot')
      lxy = cell(numel(p)*2,1);
      lxy(1:2:end) = {p.xy};
      lxy(2:2:end) = {[NaN NaN]};  
    else
      lxy = {p.xy};
    end

    parts = [0:1000:length(lxy)-1 length(lxy)];    
    s = cell(numel(parts)-1,1);
    for k=1:numel(parts)-1 % faster as at once      
      s{k} = vertcat(lxy{parts(k)+1:parts(k+1)});
    end
    s = vertcat(s{:});
    
  case {'holes'}
    s = horzcat(p(hashole(p)).(vname));
  case {'point_ids'}
    s = {p.(vname)};
  otherwise
    s = vertcat(p.(vname));
end
