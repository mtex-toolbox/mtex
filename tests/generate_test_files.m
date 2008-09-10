function generate_test_files(varargin)

cs = symmetry('-3m');
ss = symmetry('-1');

% crystal directions
h = [Miller(1,0,0,cs),Miller(0,0,1,cs)];

% specimen directions
r = S2Grid('equispaced','resolution',5*degree,'hemisphere');

% ODF
odf = unimodalODF(idquaternion,cs,ss);

% pole figures
pf = simulatePoleFigure(odf,h,r) %#ok<NOPRT>

% debug mode
set_mtex_option('debug_mode');

set_mtex_option('tempdir',[mtex_path,filesep,'c',filesep,'test',filesep]);

% generate files
disp('Press Strg-C to generate test files!')
calcODF(pf)

delete_mtex_option('debug_mode');
