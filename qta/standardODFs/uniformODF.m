function odf = uniformODF(CS,SS,varargin)
% defines a uniform ODF
%
%% Description
% *uniformODF* defines ODF that is constant 1 for all orientations.
%
%% Input
%  CS, SS  - crystal, specimen symmetry
% 
%% Output
%  odf - @ODF
%
%% Options
%  WEIGHTS - total mass
%
%% See also
% ODF/ODF unimodalODF fibreODF

w = get_option(varargin,'WEIGHT',1);
if nargin < 2, SS = symmetry;end

argin_check(CS,'symmetry');
argin_check(SS,'symmetry');

odf = ODF([],w,[],CS,SS,'UNIFORM',varargin{:});
