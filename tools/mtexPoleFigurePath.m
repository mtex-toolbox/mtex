function p = mtexPoleFigurePath
% returns the default path to PoleFigure data files
%
%% Syntax 
% mtexPoleFigurePath - 
% get_mtex_option('PoleFigurePath') - long form of mtexPoleFigurePath
% set_mtex_option('PoleFigurePath',path) - change the path to Pole Figure files 
%
%% See also
% mtexDataPath mtexCifPath mtexEBSDPath mtexPoleFigurePath mtexODFPath
% mtexTensorPath get_mtex_option set_mtex_option

mtex_data_path = get_mtex_option('PoleFigurePath');

if exist(mtex_data_path,'dir')
  p = mtex_data_path;
else
  error('Data package not installed!');
end
