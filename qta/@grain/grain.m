function gr = grain(gr,ply)
% constructor
%
% *grain* is the low level constructor for an *grain* object representing
% grains. Grains are derived from the segmentation of @EBSD data.
%
%% Input
%  ebsd    - @EBSD
%
%% See also
% EBSD/segment2d

if nargin == 0

  gr = struct('id',{},'cells',{},'neighbour',{},'checksum',{},...
  'subfractions',{},'phase',{},'orientation',{},'properties',{},...
  'comment',{});
  
  poly = polytope;
  
  gr = class(gr,'grain',poly);
     
elseif nargin == 2
  
  gr = class(gr,'grain',ply);
    
end

