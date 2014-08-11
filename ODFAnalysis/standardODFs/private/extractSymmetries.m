function [CS,SS] = extractSymmetries(varargin)
% extract crystal and specimen symmetry from input arguments

CS = getClass(varargin,'crystalSymmetry',crystalSymmetry);
SS = getClass(varargin,'specimenSymmetry',specimenSymmetry);
