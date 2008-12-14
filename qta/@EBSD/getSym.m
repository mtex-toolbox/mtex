function [CS,SS] = getSym(ebsd)
% get crystal and specimen symmetry of the EBSD data
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  CS - crystal @symmetry
%  SS - specimen @symmetry
%

CS = get(ebsd,'CS');
SS = get(ebsd,'SS');
