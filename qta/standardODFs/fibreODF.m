function odf = fibreODF(h,r,psi,CS,SS)
% defines an fibre symmetric ODF
%
%% Description
% *fibreODF* defines a fibre symmetric ODF with respect to 
% a crystal direction |h| and a specimen directions |r|. The
% shape of the ODF is defined by a @kernel function.
%
%% Input
%  h      - @Miller / @vector3d crystal direction
%  r      - @vector3d specimen direction
%  kernel - @kernel function
%  CS, SS - crystal, specimen @symmetry
%
%% Output
%  odf -@ODF
%
%% See also
% ODF/ODF uniformODF unimodalODF

error(nargchk(5, 5, nargin));

odf = ODF({h,r},1,psi,CS,SS,'fibre');
