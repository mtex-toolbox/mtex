function [m kappa v] = mean(odf,varargin)
% returns mean, kappas
%
%% Input
%  odf       - @ODF
%
%% Output
%  mean      - @orientation
%  kappa     - parameters of bingham distribution
%  v         - eigenvectors
%


S3G = extract_SO3grid(odf,varargin);
[m kappa v] = mean(S3G,'weights',eval(odf,S3G)); %#ok<EVLC>
