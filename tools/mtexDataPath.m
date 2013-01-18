function p = mtexDataPath
% returns the default path to mtex sample data
%
%% Syntax
% mtexDataPath -
% getpref('mtex','DataPath') - long form of mtexDataPath
% setpref('mtex','DataPath',path) - change the path to mtex data
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getpref('mtex','DataPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
