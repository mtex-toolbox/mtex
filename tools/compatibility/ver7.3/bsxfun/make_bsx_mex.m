function make_bsx_mex
%make_bsx_mex: Make MEX files for generalized arithmetic operators.
%	make_bsx_mex creates the MEX files from the source file
%   bsx_mex.c by calling mex with the appropriate complier directives.
%	make_bsx_mex.m should be in the same directory as bsx_mex.c.

% Version: 1.0, 25 January 2009
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})


current_dir = pwd;
src_dir = fileparts(which(mfilename));
disp('Building mex files in')
disp(['  ',src_dir])
cd(src_dir)

fcns = {'plus','minus','times','rdivide','ldivide',...
	'eq','ne','lt','gt','le','ge'};

try
	for i = 1:length(fcns)
		output = ['bsx_',fcns{i}];
		disp(['Making ',output])
		mex('bsx_mex.c',['-D',upper(fcns{i}),'_MEX'],'-output',output)
	end
	cd(current_dir)
catch
	cd(current_dir)
end
