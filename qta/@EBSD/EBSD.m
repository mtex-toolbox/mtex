function ebsd = EBSD(orientations,CS,SS,varargin)
% constructor
%
% An @EBSD can be defined in various ways. The most general method is using
% the constructor *EBSD*. It allows to define superpositions of uniform, 
% unimodal and fibre symmetric components. 
%
%% Syntax
% odf = EBSD(orientations,CS,SS,<options>)
%
%% Input
%  orientations - @SO3Grid single orientations
%  CS,SS        - crystal / specimen @symmetry
%
%% Options
%  Comment - string
%
%% See also
% ODF/simulateEBSD EBSD/calcODF

if nargin <= 1, CS = symmetry('tricline'); end
if nargin <= 2, SS = symmetry('tricline'); end

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
