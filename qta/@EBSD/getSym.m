function [CS,SS] = getSym(ebsd,varargin)
% get crystal and specimen symmetry of the EBSD data
%
%% Input
%  ebsd - @EBSD
%
%% Output
%  CS - crystal @symmetry
%  SS - specimen @symmetry
%

if check_option(varargin,'all')
  CS = [ebsd.CS];
else
  CS = ebsd(1).CS;
end
SS = ebsd(1).SS;
