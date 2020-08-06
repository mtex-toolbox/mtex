%% Orientation Sections
%
%% Sections of the orientations space
%
% A third possibility are two dimensional sections through the Euler angle
% space. The most popular type of such sections are the so called phi2
% sections.

% cubic crystal symmetry
cs = crystalSymmetry('432');

% orthotropic specimen symmetry
ss = specimenSymmetry('222');

% 100 random orientations
ori = orientation.rand(100,cs,ss)

% plotted as as phi2 sections
plotSection(ori,'phi2')


%% Sigma Sections
%
% A different type of sections through the orientation space are the so
% called <SigmaSections.html sigma sections>. One of its central advantages
% is its equal volume projection.

plotSection(ori,'sigma')

