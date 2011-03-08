function [T,interface,options] = loadTensor_mpod(fname,varargin)
% import Tensor data
%
%% Description
% *loadTensor_mod* is a high level method for importing Tensor data from external
% files. 
% [[http://www.materialproperties.org/data/, Material Properties Open Database]]
%
%% Syntax
%  pf = loadTensor_mpod(fname,cs,ss,<options>)
%
%% Input
%  fname     - filename
%  cs, ss    - crystal, specimen @symmetry (optional)
%
%% Example 
% T = loadTensor_mpod('1000055.mpod')
%
%% See also
% loadTensor 

%% TODO
%  * allow import of not ij indexed single properties e.g. _prop_heat_capacity_C
%  * respect multiple measured properties i.e _prop_conditions (_prop_conditions_temperature)
%  * better symmetry import
%

% remove option "check"
varargin = delete_option(varargin,'check');


str = file2cell(fname);
try
  cs = mpod2symmetry(str,varargin{:});
catch
  cs = symmetry;
end

entry = regexp(str,'_prop_(?<property>\w*(?<=ij)(.*)) ''(?<index>\w*)''','names');
T = {};
for Entry = entry(~cellfun('isempty',entry))
  index = Entry{:}.index;
  property = deblank(regexprep(Entry{:}.property,['_|' index],' '));
  
  pos = strfind(str,index);
  index_ij = str(cellfun('prodofsize',pos)==1);
  index_ij = regexp(index_ij,[index,' (?<i>[0-9])(?<j>[0-9]) (?<value>[0-9.-]*)'],'names');
  index_ij = [index_ij{:}];

  
  M = [];
  for k=1:numel(index_ij)
    val = str2num(index_ij(k).value);
    if isempty(val), val = 0; end
    M(str2num(index_ij(k).i),str2num(index_ij(k).j)) = val;
  end
  
  if size(M,1) ~= size(M,2)
%    	warning('don''t know what about assymmetric tensors')
    if any(size(M) >3)
      [i,j,v]=find(M);
     	M = full(sparse(i,j,v,6,6));
    end
  end

  T{end+1} = tensor(M,cs,'propertyname',property,'unit','??');
end

if numel(T) == 1
  T = T{1};
end



function [cs,mineral] = mpod2symmetry(str,varargin)
% import crystal symmetry from cif file

try
  cod = sscanf(extract_token(str,'_cod_database_code'),'%s');
  cs = cif2symmetry(['http://www.crystallography.net/cif/' cod '.cif']);
  mineral = get(cs,'mineral');
  return
catch
end

% load file
try
  mineral = extract_token(str,'_phase_name');
catch
  mineral = name;
end

try
  point_group = extract_token(str,'_symmetry_point_group_name_H-M');
  
  % find a,b,c
  a = sscanf(extract_token(str,'_cell_length_a'),'%f');
  b = sscanf(extract_token(str,'_cell_length_b'),'%f');
  c = sscanf(extract_token(str,'_cell_length_c'),'%f');
  
  
  % find alpha, beta, gamma
  alpha = sscanf(extract_token(str,'_cell_angle_alpha'),'%f');
  beta = sscanf(extract_token(str,'_cell_angle_beta'),'%f');
  gamma = sscanf(extract_token(str,'_cell_angle_gamma'),'%f');
  
  if isempty(b)
    b = a;
  end
  
  if isempty([a b c])
    cs = symmetry(point_group,'mineral',mineral);
  elseif isempty([alpha beta gamma ])
    cs = symmetry(point_group,[a,b,c],[alpha,beta,gamma]*degree,'mineral',mineral);
  else
    cs = symmetry(point_group,'mineral',mineral);
  end
  
  
catch
  error(['Error reading cif file', fname]);
  
end

function t = extract_token(str,token)

pos = strmatch(token,str);
s = str(pos);
if ~isempty(s)
  t = char(regexp(s{1},['(?<=' token '\s).*'],'match'));
else
  t = '';
end