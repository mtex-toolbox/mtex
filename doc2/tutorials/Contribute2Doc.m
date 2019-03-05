%% MTEX Documentation Tutorial
%
%% Documentation Location
%
% The documentation files are stored in the mtex/doc folder which is not added to your path by default.
% To add this path simply change into the mtex directory and type

%  addpath doc

%% Edit some file
%
% To edit a page you find in the documentation you can simply click on "Open in Editor" for the offline Matlab documentation.
% If you are on the online documentation you will find the filename on the bottom of each page and you can simply type 'edit filename' into the Matlab commandline where you replace filename with the actual filename.
%
%% Publish command
%
% The documentation files are processed via the publish command which takes the m-file and creates an html-file.
% The basic syntax can be found here: <https://de.mathworks.com/help/matlab/matlab_prog/publishing-matlab-code.html>.
% To verify that your modified documentation page works you can type

%  publish filename

%%
% which creates an folder, named 'hmtl', in your current directory where you can find your modified documentation page.

%% Further processing
%
% If you made some contributions to the documentation which you think should be included into the official documentation you can make a pull request to the mtex-GitHub repository or simply send the documentation file and we will make sure you can admire you changes in the official documentation.
