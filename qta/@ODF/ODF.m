function odf = ODF(center,c,psi,CS,SS,varargin)
% constructor
%
% An @ODF can be defined in various ways. The most general method is using
% the constructor *ODF*. It allows to define superpositions of uniform, 
% unimodal and fibre symmetric components. 
%
%% Syntax
% odf = ODF(center,weigths,kernel,CS,SS,...) - setup an ODF specified by center 
%    @orientation, weights and an @kernel, see [[unimodalODF.html,unimodalODF]]
%
% odf = ODF({h,r},weigths,kernel,CS,SS,'Fibre',...) - constructs an [[fibreODF.html,fibre ODF]]
%    by given specimen and crystal direction and a kernel.
%
% odf = ODF([A],[Lambda],[],CS,SS,'Bingham',...) - constructs an [[binghamODF.html,Bingham ODF]]
%    with an orthogonal 4x4 matrix A and form parameters Lambda.
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
%  BINGHAM - Bingham @ODF
%
%% See also
%  uniformODF unimodalODF fibreODF BinghamODF FourierODF

if nargin == 0
  
  odf = struct('comment',{},'center',{},'c',{},'c_hat',{},'psi',{},...
    'CS',{},'SS',{},'options',{});  
	odf = class(odf,'ODF');
	return
  
elseif isa(center,'ODF')
  
  odf = center;
  return
  
end

% default values
if nargin <= 3, CS = symmetry('triclinic'); end
if nargin <= 4, SS = symmetry('triclinic'); end
if isa(center,'quaternion') && ~isa(center,'orientation') 
  center = orientation(center,CS,SS);
end
if nargin <= 1 || isempty(c) && isa(center,'SO3Grid'), c = [1,ones(1,numel(center))]; end
if nargin <= 2, psi = kernel; end
if nargin <= 3, CS = get(center,'CS'); end
if nargin <= 4, SS = get(center,'SS'); end
c_hat = [];

% check completness of parameters
option = extract_option(varargin,{'UNIFORM','FIBRE','FOURIER','Bingham'});

switch lower(char(option))
  case 'fourier'
    c_hat = center;
    c = c_hat(1);
    center = [];
  case 'fibre'
    if ~((isa(center{1},'Miller') || isa(center{1},'vector3d')) && isa(center{2},'vector3d')...
        && isa(c,'double') && isa(psi,'kernel')...
        && isa(CS,'symmetry') && isa(CS,'symmetry'))
      error('wrong Arguments: {Miller,vector3d}, data, kernel, crystal-symmetry, specimen-symmetry');
    end
    lg = length(center{1});
  case 'uniform'
    lg = 1;
  case 'bingham'
    lg = 1;
    center = orientation(quaternion(center),CS,SS);
    
    if ~isappr(abs(det(squeeze(double(center)))),1) %orthogonality check
       warning('MTEX:BinghamODF','center seems not to be orthogonal');
    end
  otherwise
    if ~(isa(center,'quaternion') && isa(c,'double') && isa(psi,'kernel')...
          && isa(CS,'symmetry') && isa(CS,'symmetry'))
        error('wrong Arguments: SO3Grid, data, kernel, crystal-symmetry, specimen-symmetry');
    end
    lg = numel(center);  
    option = {'unimodal'};
end



% check amount of coefficients
if ~check_option(varargin,'FOURIER') && lg ~= length(c)
  error(['number of gridpoints and coefficients missmatch: ',int2str(lg),'-',int2str(length(c))]);
end

% check symmetries
if isa(center,'SO3Grid') && (~(get(center,'CS') == CS) || ~(get(center,'SS') == SS))
  qwarning('symmetry of the grid does not fit to the given symmetry');
end



odf.comment = get_option(varargin,'comment',[]);
odf.center = center;
odf.c = c;
odf.c_hat = c_hat;
odf.psi = psi;
odf.CS = CS;
odf.SS = SS;
odf.options = option;
odf = class(odf,'ODF');
