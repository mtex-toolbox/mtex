function p = mtexEBSDPath
% returns the default path to EBSD data files
%
%% Syntax 
% mtexEBSDPath - 
% get_mtex_option('EBSDPath') - long form of mtexEBSDPath
% set_mtex_option('EBSDPath',path) - change the path to EBSD files 
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath get_mtex_option set_mtex_option

mtex_data_path = get_mtex_option('EBSDPath');

if exist(mtex_data_path,'dir')
  p = mtex_data_path;
else
  error('Data package not installed!');
end
