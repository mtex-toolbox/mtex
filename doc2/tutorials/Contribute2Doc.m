%% MTEX Documentation Tutorial
%
%% Documentation Location
%
% The documentation files are stored in the mtex/doc folder which is added
% to your MTEX search path by default. Hence you can open the script file
% corresponding to any help file by typing into the command window

edit Contribute2Doc

%%
%
% The correct file name of the help script file you find by clicking on "Open in
% Editor" in the offline Matlab documentation. If you are on the online
% documentation you will find the filename on the bottom of each page.
%
%% Publish command
%
% The documentation files are processed via the publish command which takes
% the m-file and creates an html-file. The basic syntax can be found here:
% <https://de.mathworks.com/help/matlab/matlab_prog/publishing-matlab-code.html>.
% To verify that your modified documentation page works you can type

publish filename

%%
% which creates an folder, named 'hmtl', in your current directory where
% you can find your modified documentation page.

%% Contributing to MTEX
%
% If you made some contributions to the documentation which you think
% should be included into the official documentation you can open a pull
% request to the mtex-GitHub repository or simply send the documentation
% file and we will make sure you can admire you changes in the official
% documentation.
