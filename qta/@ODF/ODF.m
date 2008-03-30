function odf = ODF(center,c,psi,CS,SS,varargin)
% constructor
%
% An @ODF can be defined in various ways. The most general method is using
% the constructor *ODF*. It allows to define superpositions of uniform, 
% unimodal and fibre symmetric components. 
%
%% Syntax
% odf = ODF(center,weigths,kernel,CS,SS,<options>)
% odf = ODF({h,r},weigths,kernel,CS,SS,<options>)
%
%% Input
%  center  - @SO3Grid of modal orientations
%  h       - @Miller or @vector3d crystal direction
%  r       - @vector3d specimen direction
%  weights - weights of the components (double) 
%  kernel  - @kernel function
%  CS,SS   - crystal / specimen @symmetry
%
%% Flags
%  UNIFORM - uniform @ODF
%  RADIAL  - radially symetric @ODF
%  FIBRE   - fibre symetric @ODF
%
%% See also
%  uniformODF unimodalODF fibreODF

if (nargin == 0)
  odf.comment = [];
	odf.center = [];
	odf.c = 1;
  odf.c_hat = [];
	odf.psi = [];
	odf.CS = symmetry;
	odf.SS = symmetry;
  odf.options = {'uniform'};
	odf = class(odf,'ODF');
	return
elseif isa(center,'ODF')
  odf = center;
  return
end

% default values
if isa(center,'quaternion') 
  if nargin <= 3, CS = symmetry('triclinic'); end
  if nargin <= 4, SS = symmetry('triclinic'); end
	center = SO3Grid(center,CS,SS); 
end
if nargin <= 1 || isempty(c), c = [1,ones(1,GridLength(center))]; end
if nargin <= 2, psi = kernel; end
if nargin <= 3, CS = getCSym(center); end
if nargin <= 4, SS = getSSym(center); end


% check completness of parameters
if check_option(varargin,'FIBRE')
  if ~((isa(center{1},'Miller') || isa(center{1},'vector3d')) && isa(center{2},'vector3d')...
      && isa(c,'double') && isa(psi,'kernel')...
      && isa(CS,'symmetry') && isa(CS,'symmetry'))
    error('wrong Arguments: {Miller,vector3d}, data, kernel, crystal-symmetry, specimen-symmetry');
  end
  lg = length(center{1});
elseif check_option(varargin,'UNIFORM')
  lg = 1;
else
  if ~(isa(center,'SO3Grid') && isa(c,'double') && isa(psi,'kernel')...
      && isa(CS,'symmetry') && isa(CS,'symmetry'))
    error('wrong Arguments: SO3Grid, data, kernel, crystal-symmetry, specimen-symmetry');
  end
  lg = sum(GridLength(center));
end 

% check amount of coefficients
if lg ~= length(c)
  error(['number of gridpoints and coefficients missmatch: ',int2str(lg),'-',int2str(c)]);
end

% check symmetries
if isa(center,'SO3Grid') && (~(getCSym(center) == CS) || ~(getSSym(center) == SS))
  qwarning('symmetry of the grid does not fit to the given symmetry');
end

odf.comment = get_option(varargin,'comment',[]);
odf.center = center;
odf.c = c;
odf.c_hat = [];
odf.psi = psi;
odf.CS = CS;
odf.SS = SS;
odf.options = extract_option(varargin,{'uniform','fibre'});
odf = class(odf,'ODF');
