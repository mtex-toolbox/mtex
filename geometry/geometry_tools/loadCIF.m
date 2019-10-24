function [cs,mineral] = loadCIF(fname,varargin)
% import crystal symmetry from cif file
%
% if cif file not found and input name is a valid COD entry, this function
% tries to download the file from <http://www.crystallography.net/cif/
% http://www.crystallography.net/cif/>
%
% Syntax
%   loadCIF('5000035.cif')
%   loadCIF(5000035)       % lookup online
%
% See also
% symmetry


if ~iscell(fname)
  if isnumeric(fname)
    fname = copyonline(fname);
  end
  [pathstr, name, ext] = fileparts(char(fname));
  
  if isempty(ext), ext = '.cif';end
  if isempty(pathstr) && ~exist([name,ext],'file')
    pathstr = mtexCifPath;
  end
  
  % load file
  if ~exist(fullfile(pathstr,[name ext]),'file')
    try
      fname = copyonline(fname);
    catch %#ok<CTCH>
      dir(fullfile(mtexCifPath,'*.cif'))
      error('I could not find the corresponding cif. Above you see the list of localy avaible cif files.')
    end
  else
    fname = fullfile(pathstr,[name ext]);
  end
  str = file2cell(fname);
else
  str = fname;
  name = '';
end

try
  % get a name for it
  mineral_names = {...
    '_chemical_name_mineral',...
    '_chemical_name_systematic',...
    '_chemical_formula_structural',...
    '_chemical_formula_sum'};
  
  for alias = mineral_names
    mineral = extract_token(str,alias{:});
    if ~isempty(mineral), break; end
  end
  
  % find space group
  group_aliases = {...
    '_symmetry_space_group_name_H-M',...
    '_symmetry_point_group_name_H-M',...
    '_symmetry_cell_setting'};
  for gp = group_aliases
    group = extract_token(str,gp{:});
    if ~isempty(group), break; end
  end
  
  % find a,b,c
  axis = [extract_token(str,'_cell_length_a',true) ...
    extract_token(str,'_cell_length_b',true) ...
    extract_token(str,'_cell_length_c',true)];
  
  % find alpha, beta, gamma
  angles = [extract_token(str,'_cell_angle_alpha',true) ...
    extract_token(str,'_cell_angle_beta',true) ...
    extract_token(str,'_cell_angle_gamma',true)];
  
  if length(axis)<3,
%     warning('crystallographic axis mismatch');    
    axis = [1 1 1];
  end
  if length(angles)<3,
%     warning('crystallographic angles mismatch');
    angles = [90 90 90];    
  end
  
  assert(~isempty(group));
      
  cs = crystalSymmetry(group,axis,angles*degree,'mineral',mineral);
  
catch
  error(['Error reading cif file', fname]);
end




function t = extract_token(str,token,numeric)

pos = strmatch(token,str);
if ~isempty(pos)
  t = strtrim(regexprep(str{pos(1)},[token '|'''],''));
  if ~isempty(t)
    if nargin>2 && numeric
      t = sscanf(t,'%f');
    end
  end
else
  t = '';
end

function fname = copyonline(cod)

try
  if isnumeric(cod)
    cod = num2str(cod);    
  end
  
  fname = fullfile(mtexCifPath,[cod '.cif']);
  if exist(fname,'file')
    return
  end
    
  if ~isempty(str2num(cod))
    disp('CIF-File from Crystallography Open Database')
    disp(['> download : http://www.crystallography.net/cif/' cod '.cif'])
    cif = urlread(['http://www.crystallography.net/cif/' cod '.cif']);
  else
    cif = urlread(cod);
  end
catch
  disp('> unluckily failed to find cif-file')
  error('CIF-file not valid online')
end

fname = fullfile(mtexCifPath,[cod '.cif']);

fid = fopen(fname,'w');
fwrite(fid,cif);
fclose(fid);
disp(['> copied to: ' fname]);




