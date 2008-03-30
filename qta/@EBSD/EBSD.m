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
%  orientations - @SO3Grid single orientations
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
    ebsd.orientations = [];
    ebsd.CS = symmetry;
    ebsd.SS = symmetry;
    ebsd.options = {};
    ebsd = class(ebsd,'EBSD');
    return
elseif isa(orientations,'EBSD')
    ebsd = orientations;
    return
elseif isa(orientations,'quaternion')
    orientations = SO3Grid(orientations,CS,SS);
elseif ~isa(orientations,'SO3Grid')
    error('first argument should be of type SO3Grid or quaternion');
end

ebsd.comment = get_option(varargin,'comment',[]);
ebsd.orientations = orientations;
ebsd.CS = CS;
ebsd.SS = SS;
ebsd.options = extract_option(varargin,{});
ebsd = class(ebsd,'EBSD');
