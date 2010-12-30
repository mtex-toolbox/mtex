function p = polyeder(varargin)
% polyeder class for grains
%
% *polyeder* is a low level constructor for polyeders treating grain polyeders
% in MTEX.
%
%% Syntax
%  p = polyeder(xy)
%  p = polyeder(x,y)
%  p = polyeder(polyeder)
%  p = polyeder({[xy],[xy],[xy]})
%
%% Output
%  p - @polyeder
%
%% See also
% grain_index


if nargin > 0 
  
  p = varargin{1};
  
  if isa(p,'grain')
   
    p = polytope(p);
    return
    
  elseif isa(p,'polytope') || isa(p,'polyeder')
    
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
  
  p = class(p,'polyeder');
  
end
  

