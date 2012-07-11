function p = mtexODFPath
% returns the default path to ODF-files
%
%% Syntax
% mtexODFPath -
% getpref('mtex','ODFPath') - long form of mtexODFPath
% setpref('mtex','ODFPath',path) - change the path to ODF files
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getpref('mtex','ODFPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
