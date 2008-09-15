function [cs,mineral] = load_cif(fname,varargin)
% import crystal symmetry from cif file

[pathstr, name, ext] = fileparts(fname);

if isempty(ext), ext = '.cif';end
if isempty(pathstr) && ~exist([name,ext],'file')
  pathstr = get_mtex_option('cif_path'); 
end

% load file
str = file2cell([pathstr filesep name ext]);

try
  mineral = extract_token(str,'_chemical_name_mineral');
catch 
  mineral = [];
end

try
  
  % find space group
  space_group = extract_token(str,'_symmetry_space_group_name_H-M ');
    
  % find a,b,c
  a = extract_token(str,'_cell_length_a');
  b = extract_token(str,'_cell_length_b');
  c = extract_token(str,'_cell_length_c');
  
  % find alpha, beta, gamma
  alpha = extract_token(str,'_cell_angle_alpha');
  beta = extract_token(str,'_cell_angle_beta');
  gamma = extract_token(str,'_cell_angle_gamma');
  
  cs = symmetry(space_group,[a,b,c],[alpha,beta,gamma]*degree);

catch
  error(['Error reading cif file', fname]);
  
end
  
function t = extract_token(str,token)

pos = strmatch(token,str);
s = str(pos);


s = regexp(s,[token '\s* (.*)'],'tokens');
s = char(s{1}{1});
if s(1) == ''''
  t = s(2:end-1);
else
  t = sscanf(s,'%f');
end
