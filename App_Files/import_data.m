%-----------------
% This function reads a file and passes on the 
% contained data
% 
% Used in: MApp.mlapp
%-----------------

function [data, fileName] = import_data()
% initialize variables in case of termination of uigetfile
% window
data = [];
fileName = '';

% create fileFilter to filter for EBSD formats

fileFilter = getMTEXpref('EBSDExtensions');
fileFilter = strjoin("*" + fileFilter,";");

% open dialog window to choose data
[file, path] = uigetfile(fileFilter,'Choose Data');
% check for termination of dialog window
if isequal(file, 0) || isequal(path, 0)
  disp('Import vom Nutzer abgebrochen.');
  return;
end

% save fullPath in order to load data later on
fullPath = fullfile(path,file);

fileName = file;

% try to load EBSD data for chosen path
try
  data = EBSD.load(fullPath,'wizard');
catch ME
  errordlg(['Error while MTEX-Data-Import: ' ME.message]);
  data = [];
end
end

