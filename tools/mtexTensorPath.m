function p = mtexTensorPath
% returns the default path to tensor-files
%
%% Syntax
% mtexTensorPath -
% getpref('mtex','TensorPath') - long form of mtexTensorPath
% setpref('mtex','TensorPath',path) - change the path to Tensor files
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath


DataPath = getpref('mtex','TensorPath');

if exist(DataPath,'dir')
  p = DataPath;
else
  error('Data package not installed!');
end
