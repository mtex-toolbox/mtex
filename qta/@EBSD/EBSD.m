function ebsd = EBSD(varargin)
% constructor
%
% *EBSD* is the low level constructor for an *EBSD* object representing EBSD
% data. For importing real world data you might want to use the predefined
% [[ImportEBSDData.html,EBSD interfaces]]. You can also simulate EBSD data
% from an ODF using [[ODF_simulateEBSD.html,simulateEBSD]].
%
%% Syntax
%  ebsd = EBSD(orientations,CS,SS,<options>)
%
%% Input
%  orientations - @orientation
%  CS,SS        - crystal / specimen @symmetry
%
%% Options
%  Comment - string
%
%% See also
% ODF/simulateEBSD EBSD/calcODF loadEBSD

if (nargin == 0)
  ebsd.comment = [];
  ebsd.orientations = orientation;
  ebsd.X = [];
  ebsd.phase = [];
  ebsd.options = struct;
  ebsd = class(ebsd,'EBSD');
  return
elseif isa(varargin{1},'EBSD')
  ebsd = varargin{1};
  return
else
  orientations = orientation(varargin{:});
end

ebsd.comment = get_option(varargin,'comment',[]);
ebsd.orientations = orientations;
ebsd.X = get_option(varargin,'xy');
ebsd.phase = get_option(varargin,'phase',1);
ebsd.options = get_option(varargin,'options',struct);
ebsd = class(ebsd,'EBSD');
