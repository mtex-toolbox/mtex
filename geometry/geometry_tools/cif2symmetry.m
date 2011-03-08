function [cs,mineral] = cif2symmetry(fname,varargin)
% import crystal symmetry from cif file
%
% if cif file not found and input name is a valid COD entry, this function tries
% to download the file from [[http://www.crystallography.net/cif/,http://www.crystallography.net/cif/]]
%
%% Syntax
% cif2symmetry('5000035.cif')
% cif2symmetry(5000035)       % lookup online
%
%% See also
% symmetry

if isnumeric(fname)
  fname = copyonline(fname);
end

[pathstr, name, ext] = fileparts(fname);

if isempty(ext), ext = '.cif';end
if isempty(pathstr) && ~exist([name,ext],'file')
  pathstr = get_mtex_option('cif_path');
end

% load file
if ~exist(fullfile(pathstr,[name ext]),'file')
  fname = copyonline(fname);
else
  fname = fullfile(pathstr,[name ext]);
end

str = file2cell(fname);

try
  mineral = extract_token(str,'_chemical_name_mineral');
catch
  mineral = name;
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
  
  cs = symmetry(space_group,[a,b,c],[alpha,beta,gamma]*degree,'mineral',mineral);
  
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
  if isempty(t), t = s;end
end



function fname = copyonline(cod)

try
  if isnumeric(cod)
    cod = num2str(cod);
  end
  if ~isempty(str2num(cod))
    disp('CIF-File from Crystallography Open Database')
    disp(['> download : http://www.crystallography.net/cif/' cod '.cif'])
    cif = urlread(['http://www.crystallography.net/cif/' cod '.cif']);
  else
    cif = urlread(cod);
  end
catch
  error('CIF-file not valid online')
end

fname = fullfile(get_mtex_option('cif_path'),[cod '.cif']);

fid = fopen(fname,'w');
fwrite(fid,cif);
fclose(fid);
disp(['> copied to: ' fname]);




