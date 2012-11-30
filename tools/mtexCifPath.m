function p = mtexCifPath
% returns the default path to crystallographic information files (CIF)
%
%% Syntax
% mtexCifPath -
% getpref('mtex','CIFPath') - long form of mtexCifPath
% setpref('mtex','CIFPath',path) - change the path to CIF files
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getpref('mtex','CIFPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
