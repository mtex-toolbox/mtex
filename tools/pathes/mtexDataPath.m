function p = mtexDataPath
% returns the default path to mtex sample data
%
% Syntax
%   mtexDataPath -
%   getMTEXpref('DataPath')      - long form of mtexDataPath
%   setMTEXpref('DataPath',path) - change the path to mtex data
%
% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getMTEXpref('DataPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
