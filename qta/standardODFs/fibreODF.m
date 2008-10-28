function odf = fibreODF(h,r,CS,SS,varargin)
% defines an fibre symmetric ODF
%
%% Description
% *fibreODF* defines a fibre symmetric ODF with respect to 
% a crystal direction |h| and a specimen directions |r|. The
% shape of the ODF is defined by a @kernel function.
%
%% Syntax
%  odf = fibreODF(h,r,CS,SS,'halfwidth',hw)
%  odf = fibreODF(h,r,CS,SS,kernel)
%
%% Input
%  h      - @Miller / @vector3d crystal direction
%  r      - @vector3d specimen direction
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default - 10°)
%  kernel - @kernel function (default - de la Vallee Poussin)
%
%% Output
%  odf -@ODF
%
%% See also
% ODF/ODF uniformODF unimodalODF

error(nargchk(4, 6, nargin));
argin_check(h,'Miller');
argin_check(r,'vector3d');
argin_check(CS,'symmetry');
argin_check(SS,'symmetry');

if ~isempty(varargin) && isa(varargin{1},'kernel')
  psi = varargin{1};
else
  hw = get_option(varargin,'halfwidth',10*degree);
  psi = kernel('de la Vallee Poussin','halfwidth',hw);
end

odf = ODF({h,r},1,psi,CS,SS,'fibre');
