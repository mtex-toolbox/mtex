function odf = unimodalODF(mod,CS,varargin)
% define a unimodal ODF
%
%% Description
% *unimodalODF* defines a radially symmetric, unimodal ODF 
% with respect to a crystal orientation |mod|. The
% shape of the ODF is defined by a @kernel function.
%
%% Syntax
%  odf = unimodalODF(mod,CS,'halfwidth',hw)
%  odf = unimodalODF(mod,CS,SS,'halfwidth',hw)
%  odf = unimodalODF(mod,CS,SS,kernel)
%
%% Input
%  mod    - @quaternion modal orientation
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default - 10°)
%  kernel - @kernel function (default - de la Vallee Poussin)
%
%
%% Output
%  odf - @ODF
%
%% See also
% ODF/ODF uniformODF fibreODF

if nargin == 0, mod = orientation(idquaternion);end
argin_check(mod,'quaternion');
if ~isa(mod,'orientation'), mod = orientation(mod);end
if nargin <= 1, CS = get(mod,'CS'); else mod = ensureCS(CS,{mod}); end
if nargin >2 && isa(varargin{1},'symmetry')
  mod = set(mod,'SS',SS);
else
  SS = get(mod,'SS');
end
argin_check(CS,'symmetry');
argin_check(SS,'symmetry');

if ~isempty(varargin) && isa(varargin{1},'kernel')
  psi = varargin{1};
else
  hw = get_option(varargin,'halfwidth',10*degree);
  psi = kernel('de la Vallee Poussin','halfwidth',hw);
end

odf = ODF(mod,ones(size(mod)),psi,CS,SS);
