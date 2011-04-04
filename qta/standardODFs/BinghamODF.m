function odf = BinghamODF(Kappa,A,CS,SS,varargin)
% defines an fibre symmetric ODF
%
%% Description
% *BinhamODF* defines a Bingham distributed ODF with A and Lambda.
%
%% Syntax
%  odf = BinghamODF(Kappa,A,CS,SS)
%
%% Input
%  Kappa  - form parameter
%  A      - 
%  CS, SS - crystal, specimen @symmetry
%
%% Output
%  odf - @ODF
%
%% See also
% ODF/ODF uniformODF unimodalODF fibreODF

error(nargchk(4, 6, nargin));
argin_check(Kappa,'double');
argin_check(A,{'double','quaternion'});
argin_check(CS,'symmetry');
argin_check(SS,'symmetry');

if length(Kappa) < 4
  Kappa = [Kappa(:);zeros(4-length(Kappa),1)];
end

odf = ODF(A,1,Kappa,CS,SS,'Bingham');

% 
