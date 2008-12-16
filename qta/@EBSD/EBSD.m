function ebsd = EBSD(orientations,varargin)
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
%  orientations - @SO3Grid single orientations
%  CS,SS        - crystal / specimen @symmetry
%
%% Options
%  Comment - string
%
%% See also
% ODF/simulateEBSD EBSD/calcODF loadEBSD

if (nargin == 0)
  ebsd.comment = '';
  ebsd.orientations = [];
  %ebsd.CS = symmetry;
  %ebsd.SS = symmetry; 
  ebsd.xy = [];
  ebsd.phase = [];
  ebsd.options = struct;
  ebsd.grainid = [];
  ebsd = class(ebsd,'EBSD');
  return
elseif isa(orientations,'EBSD')
  ebsd = orientations;
  return
elseif isa(orientations,'quaternion')
  if nargin >= 2
    CS = varargin{1};
  else
    CS = symmetry('triclinic');
  end
  if nargin >= 3
    SS = varargin{2}; 
  else   
    SS = symmetry('triclinic');
  end
  orientations = SO3Grid(orientations,CS,SS);
elseif ~isa(orientations,'SO3Grid')
  error('first argument should be of type SO3Grid or quaternion');
end

ebsd.comment = get_option(varargin,'comment','');
ebsd.orientations = orientations;
ebsd.xy = get_option(varargin,'xy');
ebsd.phase = get_option(varargin,'phase',mat2cell(1:numel(orientations),1,ones(1,numel(orientations))));

opt = delete_option(varargin,{'comment','xy','phase'},1);
if ~isempty(opt), ebsd.options = struct(opt{:}); 
else ebsd.options = struct; end
ebsd.grainid = [];

ebsd = class(ebsd,'EBSD');
