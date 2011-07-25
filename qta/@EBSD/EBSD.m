function ebsd = EBSD(varargin)
% constructor
%
% *EBSD* is the low level constructor for an *EBSD* object representing EBSD
% data. For importing real world data you might want to use the predefined
% [[ImportEBSDData.html,EBSD interfaces]]. You can also simulate EBSD data
% from an ODF using [[ODF.simulateEBSD.html,simulateEBSD]].
%
%% Syntax
%  ebsd = EBSD(orientations,CS,SS,...,param,val,...)
%
%% Input
%  orientations - @orientation
%  CS,SS        - crystal / specimen @symmetry
%
%% Options
%  Comment  - string
%  phases   - specifing the phase of the EBSD object
%  options  - struct with fields holding properties for each orientation
%  xy       - spatial coordinates n x 2, where n is the number of input orientations 
%  unitCell - for internal use
%
%% See also
% ODF/simulateEBSD EBSD/calcODF loadEBSD

if nargin==1 && isa(varargin{1},'EBSD') % copy constructor
  ebsd = varargin{1};
  return
else
  rotations = rotation(varargin{:});
end

ebsd.comment = [];

ebsd.comment = get_option(varargin,'comment',[]);
ebsd.rotations = rotations(:);
ebsd.phases = get_option(varargin,'phases',[]);
ebsd.SS = get_option(varargin,'SS',symmetry);

% set up crystal symmetries
CS = ensurecell(get_option(varargin,'CS',{}));
if numel(CS) < max(ebsd.phases),
  if isempty_cell(CS), CS = symmetry('cubic');end
  CS = repmat(CS(1),1,max(ebsd.phases));
end

ebsd.CS = CS;
ebsd.options = get_option(varargin,'options',struct);
ebsd.unitCell = get_option(varargin,'unitCell',[]);

ebsd = class(ebsd,'EBSD');
