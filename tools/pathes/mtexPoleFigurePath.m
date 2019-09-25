function p = mtexPoleFigurePath
% returns the default path to PoleFigure data files
%
% Syntax
%   mtexPoleFigurePath 
%   getMTEXpref('PoleFigurePath') % long form of mtexPoleFigurePath
%   setMTEXpref('PoleFigurePath',path) % change the path to Pole Figure files
%
% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath

DataPath = getMTEXpref('PoleFigurePath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
