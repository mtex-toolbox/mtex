%% WP2 - grain boundary drawing
% test boundaryContours(grains) and smooth1(grains) functions
% boundaryContours() redraws grain boundary segments using a contouring 
% algorithm instead of following pixel edges
% smooth1() implements constrained laplacian smoothing of grain boundaries
% with a stopping criteria for based on boundary ebsdId positions
%
% Vivian Tong
% MATLAB R2023a, local MTEX version inside EBSD Interfaces project folder
%
% version 2024-07-23 - created and tested on mtexdata twins
% version 2024-07-24 - remove for-loops in smooth1 and boundaryContours

clear; close all; home

%% Load demo dataset
ebsd = mtexdata('twins');

%calculate grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'));

%% Describe relevant gb properties
% check you've understood the gB properties correctly
%{
% gB.ebsdInd;  -  EBSD IDs of neighbour segments
% gB.midPoint; - boundary midpoints
% gB.V       - [x,y] list of vertices - 3723 long
% gB.F       - [v1,v2] list of boundary segments (faces)- 3285 long
%}

%% replace V positions using halfway to midpoints of adjacent Fs
% similar but not exactly the same as marching squares solution, but keeps
% existing structure of F and V

tic; grainsContour = boundaryContours(grains); toc;

% % regression test when taking out for-loop
% tic; grainsContour2 = boundaryContoursFor(grains); toc;
% figure; plot(ebsd, label2rgb(ebsd.grainId,'jet','w')); hold on;  plot(grainsContour2.boundary,'lineColor','w','linewidth',2);
% plot(grainsContour.boundary,'lineColor','b'); 
%% Smooth boundaries
[grainsContourSmooth10,stablefraction10] = smooth1(grainsContour,10,ebsd('indexed'));
[grainsContourSmooth30,stablefraction30] = smooth1(grainsContour,30,ebsd('indexed'));
[grainsContourSmooth100,stablefraction100] = smooth1(grainsContour,100,ebsd('indexed'));

%% Plot stuff
figure; plot(ebsd, label2rgb(ebsd.grainId,'jet','w','shuffle')); hold on; plot(grains.boundary);
figure; plot(ebsd, label2rgb(ebsd.grainId,'jet','w','shuffle')); hold on; plot(grainsContour.boundary);
figure; plot(ebsd, label2rgb(ebsd.grainId,'jet','w','shuffle')); hold on; plot(grainsContourSmooth10.boundary);
figure; plot(ebsd, label2rgb(ebsd.grainId,'jet','w','shuffle')); hold on; plot(grainsContourSmooth30.boundary);
figure; plot(ebsd, label2rgb(ebsd.grainId,'jet','w','shuffle')); hold on; plot(grainsContourSmooth100.boundary);


figure; histogram(grains.boundary.direction);
figure; histogram(grainsContour.boundary.direction);
figure; histogram(grainsContourSmooth10.boundary.direction);
figure; histogram(grainsContourSmooth30.boundary.direction);
figure; histogram(grainsContourSmooth100.boundary.direction);

