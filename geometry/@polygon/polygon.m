function p = polygon(varargin)
% polygon class for grains
%
% *polygon* is a low level constructor for polygons treating grain polygons
% in MTEX.
%
%% Syntax
%  p = polygon(xy)
%  p = polygon(x,y)
%  p = polygon(polygon)
%  p = polygon({[xy],[xy],[xy]})
%
%% Output
%  p - @polygon
%
%% See also
% grain_index

if nargin > 0 
  
  p = varargin{1};
  
  if isa(p,'polygon')
    return
    
  elseif isa(p,'struct')
    
    p = class(p,'polygon');
    return
    
  else
    
    if ~isa(p,'cell')
      if min(find(size(p)~=2)) == 2, p = p'; end
      pl.xy = p;
    else
      pl = polygon(p{1});
      pl.holes = repmat(polygon(0),1,length(p)-1);
      for k=2:length(xy)
        pl.holes(k-1) = polygon(p{k}); % check
      end
      p = pl;
      return
    end
    
    pl.point_ids = [];
    pl.holes = [];
    pl.envelope = reshape([min(p); max(p)],1,[]);
    
  end
  
  p = class(pl,'polygon');
  
else
  
  pl.xy = [];
  pl.point_ids = [];
  pl.holes = [];
  pl.envelope = [];
  
  p = class(pl,'polygon');
end


