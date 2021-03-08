function cS = ice_VI

%
cs_Ic = crystalSymmetry('6/mmm',[4.51 4.51 7.34],'X||a*', 'Y||b', 'Z||c*'); % Abbreviation not valid
N = Miller({1,0,0},{0,0,1},{1,0,1},{1,1,1},cs_Ic);
dist = [0.65, 0.06, 0.69, 1.27];
cS = crystalShape(N./dist);