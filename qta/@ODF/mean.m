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


S3G = extract_SO3grid(odf,varargin);
[m kappa v] = mean(S3G,'weights',eval(odf,S3G)); %#ok<EVLC>
