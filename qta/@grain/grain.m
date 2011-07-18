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

  gr.id = [];
  gr.cells = [];
  gr.neighbour = [];
  gr.checksum = [];
  gr.subfractions = [];
  gr.phase = [];
  gr.orientation = orientation;
  gr.properties = struct;
  gr.comment = char;
  poly = polytope;
  
  gr = class(gr,'grain',poly);
     
elseif nargin == 2
  
  gr = class(gr,'grain',ply);
    
end

superiorto('EBSD');
