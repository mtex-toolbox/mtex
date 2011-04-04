function p = polygon(varargin)
% polygon class for grains
%
% *polygon* is a low level constructor for polygons treating grain polygons
% in MTEX.
%
%% Syntax
% p = polygon(Vertices) -
% p = polygon(x,y) -
% p = polygon(polygon) -
%
%% Output
%  p - @polygon
%
%% See also
% grain_index

if nargin > 0 
  
  p = varargin{1};
  
  
  if isa(p,'grain')
   
    p = polytope(p);
    return
    
  elseif isa(p,'polygon')
    
    p = struct(p);
    
  elseif isa(p,'double')
    
    if nargin == 1 && size(p,2) == 2
      
      p = polytope('Vertices',p);
      
    elseif nargin > 1 && isa(varargin{2},'double') && numel(p) == numel(varargin{2}) 
      
     p =  polytope('Vertices',[p(:) , varargin{2}(:)]);      
      
    else 
      error('don''t know what to do')
    end
    
    p = struct(p);
    
  end
  
  if isfield(p,'polygon')
    p = rmfield(p,'polygon');
  end
  if isfield(p,'polyeder')
    p = rmfield(p,'polyeder');
  end
  
  nd = find(~cellfun('isempty',{p.Holes}));
  for k=1:numel(nd)
    p(nd(k)).Holes = polygon(p(nd(k)).Holes);
  end
  
  p = class(p,'polygon');
    
end
  
%   if isa(p,'polygon')
%     return
%     
%   elseif isa(p,'struct')
%     
%     p = class(p,'polygon');
%     return
%     
%   else
%     
%     if ~isa(p,'cell')
%       if min(find(size(p)~=2)) == 2, p = p'; end
%       pl.Vertices = p;
%     else
%       pl = polygon(p{1});
%       pl.Holes = repmat(polygon(0),1,length(p)-1);
%       for k=2:length(Vertices)
%         pl.Holes(k-1) = polygon(p{k}); % check
%       end
%       p = pl;
%       return
%     end
%     
%     pl.VertexIds = [];
%     pl.Holes = [];
%     pl.Envelope = reshape([min(p); max(p)],1,[]);
%     
%   end
%   
%   p = class(pl,'polygon');
%   
% else
%   
%   pl.Vertices = [];
%   pl.VertexIds = [];
%   pl.Holes = [];
%   pl.Envelope = [];
%   
%   p = class(pl,'polygon');
% end


