function odf = BinghamODF(Lambda,A,CS,SS,varargin)
% defines an fibre symmetric ODF
%
%% Description
% *BinhamODF* defines a Bingham distributed ODF with A and Lambda.
%
%% Syntax
%  odf = fibreODF(Lambda,A,CS,SS)
%
%% Input
%  Lambda - [double]
%  A      - 
%  CS, SS - crystal, specimen @symmetry
%
%% Output
%  odf -@ODF
%
%% See also
% ODF/ODF uniformODF unimodalODF fibreODF

error(nargchk(4, 6, nargin));
argin_check(Lambda,'double');
argin_check(A,{'double','quaternion'});
argin_check(CS,'symmetry');
argin_check(SS,'symmetry');

odf = ODF(A,Lambda,[],CS,SS,'Bingham');

% 
