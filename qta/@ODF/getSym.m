function [CS,SS] = getSym(odf)
% get crystal and specimen symmetry of the ODF
%
%% Input
%  odf - @ODF
%
%% Output
%  CS - crystal @symmetry
%  SS - specimen @symmetry
%

CS = odf(1).CS;
SS = odf(1).SS;
