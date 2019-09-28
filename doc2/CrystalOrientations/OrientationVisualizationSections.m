%% Orientation Sections
%
%%


%% Sections of the orientations space
%
% A third possibility are two dimensional sections through the Euler angle
% space. The most popular type of such sections are the so called phi2
% sections.

cs = crystalSymmetry('432')
ss = specimenSymmetry('222')


ori = orientation.rand(100,cs,ss)

% as phi2 sections
plotSection(ori,'phi2')


%%



plotSection(ori,'sigma')

