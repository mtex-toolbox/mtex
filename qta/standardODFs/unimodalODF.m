function odf = unimodalODF(mod,psi,CS,SS,varargin)
% define a unimodal ODF
%
%% Description
% *unimodalODF* defines a radially symmetric, unimodal ODF 
% with respect to a crystal orientation |mod|. The
% shape of the ODF is defined by a @kernel function.
%
%% Input
%  mod    - @quaternion modal orientation
%  kernel - @kernel function
%  CS, SS - crystal, specimen @symmetry
%
%% Output
%  odf - @ODF
%
%% See also
% ODF/ODF uniformODF fibreODF

odf = ODF(mod,ones(size(mod)),psi,CS,SS);
