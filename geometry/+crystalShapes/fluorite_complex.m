function cS = fluorite_complex
% complex morphology

%
cs_Fl = crystalSymmetry('m3m');
N = Miller({1,0,0},{1,1,0},cs_Fl);
dist = [1, 1.75];
cS = crystalShape(N./dist);