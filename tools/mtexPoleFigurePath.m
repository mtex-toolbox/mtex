function p = mtexPoleFigurePath
% returns the default path to PoleFigure data files
%
%% Syntax
% mtexPoleFigurePath -
% getpref('mtex','PoleFigurePath') - long form of mtexPoleFigurePath
% setpref('mtex','PoleFigurePath',path) - change the path to Pole Figure files
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getpref('mtex','PoleFigurePath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
