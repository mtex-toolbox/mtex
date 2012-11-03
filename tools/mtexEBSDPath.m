function p = mtexEBSDPath
% returns the default path to EBSD data files
%
%% Syntax
% mtexEBSDPath -
% getpref('mtex','EBSDPath') - long form of mtexEBSDPath
% setpref('mtex','EBSDPath',path) - change the path to EBSD files
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getpref('mtex','EBSDPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
