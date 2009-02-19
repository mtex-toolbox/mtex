function [m kappa v] = mean(odf,varargin)
% returns mean, kappas and sorted q of crystal symmetry euqal quaternions 
%
%% Input
%  q         - list of @quaternion
%  cs        - crystal @symmetry
%
%% Output
%  mean      - one equivalent mean orientation @quaternion
%  kappa     - parameters of bingham distribution
%  v         - eigenvectors
%


S3G = SO3Grid(get_option(varargin,'resolution',5*degree),odf(1).CS,odf(1).SS);
[m kappa v] = mean(S3G,'weights',eval(odf,S3G)); %#ok<EVLC>
