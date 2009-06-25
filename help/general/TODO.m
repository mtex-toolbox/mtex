%% TODO List
%
%
%% MTEX 2.0
%
% * ---fix edit m-file in documentation---
% * fix flipud,... in plotxy
% * better exportODF function
% * fix crystal coordinate system for symmetry 2/m
% * fix empty ebsd object does not give an error in any function
% * finish ODF import wizard
% * document new functionality
% * work on compatibility issues, i.e. make an directory that will be added
% to path when necassary
% * m-file generated from import wizard should contain also some sceme what
% todo next, i.e. append something like [grains ebsd] = segment2s(ebsd);
% grains = copyproperty(grains,ebsd,'all')
% * say explicetly in generic wizard which columns has to be specified
%
%% Sudent projects
%
% * grain analysis 
% * robust mean
% * cluster analysis of EBSD data
% * cluster analysis of ODF
%
%
%% BUGS
%
%% Class Miller
%
% cs * Miller and symvec should return Miller indece 
%
%% class symmetry
%
% 
%
%% class kernel
%
% * double kernelwidth
% * addapt standard ODFs
% * add standard names by Matthies
%
%
%% EBSD
%
%
%% class PoleFigure
%
% * extend hist to show neg. values
% * calculate std
%
%% class ODF
%
% * approximate ODF by components
% * calculate means and std
% * calculate mean specimen properties
%
%% Plotting:
%
%
%% S1Grid
%
%
%% S2Grid
%
%
%% SO3Grid
%
% * make mean more resistent against symmetry
% * implement find/dist for local grids
% * implement rotated local grid
%
%% quaternion
%
% * define some ideal lagen
%
