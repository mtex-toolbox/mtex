function [gr id] = grain(id,varargin)
% constructor
%
% *grain* is the low level constructor for an *grain* object representing
% grains. Grains are derived from the segmentation of @EBSD data.
%
%% Syntax
%  [grain ebsd] = grain(ebsd, ... )
%
%% Input
%  ebsd    - @EBSD
%
%% See also
% EBSD/segment2d

  gr.checksum = [];
  gr.id = [];
  gr.cells = [];
  gr.neighbour = [];
	%geometry
  gr.polygon.xy = [];
  gr.polygon.hxy = []; 
  %subfractions
  gr.subfractions.xx = [];
  gr.subfractions.yy = [];
  gr.subfractions.pairs = [];
  %allow arbitrary properties
  gr.properties = struct;

if nargin > 0 
  
  %pre-allocation
  if isa(id,'double') && nargin == 1
    gr = repmat(gr,1,id);
  elseif isa(id,'EBSD')
    [gr id] = segment2d(id,varargin{:});
    return
  elseif nargin == 4
    gr.id = id;    
    gr.cells = varargin{1};
   %geometry  
    gr.polygon = varargin{2};
    gr.checksum = varargin{3};
    
  elseif nargin >= 5
   %ebsd ids
    gr.id = id;    
    gr.cells = varargin{1};
    gr.neighbour = varargin{2};
   %geometry  
    gr.polygon = varargin{3};
    gr.checksum = varargin{4};
    if nargin == 6
      gr.subfractions = varargin{5};
    end
    gr.properties = get_option(varargin,'properties',struct);
  else
    error('wrong usage')
  end
end

superiorto('EBSD');
gr = class(gr,'grain');
