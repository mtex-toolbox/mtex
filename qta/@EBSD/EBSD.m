function ebsd = EBSD(orientations,CS,SS,varargin)
% constructor
%
% *EBSD* is the low level constructor for an *EBSD* object representing EBSD
% data. For importing real world data you might want to use the predefined
% [[interfacesEBSD_index.html,EBSD interfaces]]. You can also simulate EBSD data
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

if nargin <= 1, CS = symmetry('triclinic'); end
if nargin <= 2, SS = symmetry('triclinic'); end

if (nargin == 0)
  ebsd.comment = [];
  ebsd.orientations = orientation;
  ebsd.CS = symmetry;
  ebsd.SS = symmetry;  
  ebsd.xy = [];
  ebsd.phase = [];
  ebsd.options = struct;
  ebsd = class(ebsd,'EBSD');
  return
elseif isa(orientations,'EBSD')
  ebsd = orientations;
  return
elseif isa(orientations,'SO3Grid')
  orientations = orientation(orientations);
elseif isa(orientations,'quaternion')
  orientations = orientation(orientations,CS,SS);
else
  error('first argument should be of type orientation or quaternion');
end

ebsd.comment = get_option(varargin,'comment',[]);
ebsd.orientations = orientations;
ebsd.CS = CS;
ebsd.SS = SS;
ebsd.xy = get_option(varargin,'xy');
ebsd.phase = get_option(varargin,'phase');
ebsd.options = get_option(varargin,'options',struct);
ebsd = class(ebsd,'EBSD');
