function p = mtexTensorPath
% returns the default path to tensor-files
%
%% Syntax 
% mtexTensorPath - 
% get_mtex_option('TensorPath') - long form of mtexTensorPath
% set_mtex_option('TensorPath',path) - change the path to Tensor files 
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath get_mtex_option set_mtex_option


mtex_data_path = get_mtex_option('TensorPath');

if exist(mtex_data_path,'dir')
  p = mtex_data_path;
else
  error('Data package not installed!');
end
