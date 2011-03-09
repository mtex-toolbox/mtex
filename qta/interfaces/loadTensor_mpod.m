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
% T = loadTensor_mpod(1000055)        % download form MPOD
%
%% See also
% loadTensor

%% TODO
%  * allow import of not ij indexed single properties e.g. _prop_heat_capacity_C
%  * respect multiple measured properties i.e _prop_conditions (_prop_conditions_temperature)
%  * better symmetry import
%  * do it right for combined ijE,ijS notation (e.g. _prop_piezoelectric_*)

if isnumeric(fname)
  fname = copyonline(fname);
end
[pathstr, name, ext] = fileparts(fname);
if isempty(ext), ext = '.mpod';end
if isempty(pathstr) && ~exist([name,ext],'file')
  pathstr = mtexTensorPath;
end

% load file
if ~exist(fullfile(pathstr,[name ext]),'file')
  fname = copyonline(fname);
else
  fname = fullfile(pathstr,[name ext]);
end
str = file2cell(fname);

cs = mpod2symmetry(str,varargin{:});



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
  
  T{end+1} = symmetrise(tensor(M,cs,'propertyname',property,'unit','??')); %#ok<AGROW>
end

if numel(T) == 1
  T = T{1};
end



function [cs,mineral] = mpod2symmetry(str,varargin)
% import crystal symmetry from cif file

pattern = '_cod_database_code';
pos = strmatch(pattern,str);
if ~isempty(pos)
  cod = strtrim(regexprep(str{pos},pattern,''));
  if  ~isempty(cod) && ~strcmpi(cod,'?')
    cs = cif2symmetry(cod);
    return
  end
end

[cs,mineral] = cif2symmetry(str);


function fname = copyonline(cod)

try
  if isnumeric(cod)
    cod = num2str(cod);
  end
  if ~isempty(str2num(cod))
    disp('MPOD-File from Material Properties Open Database (MPOD)')
    disp(['> download : http://www.materialproperties.org/datafiles/' cod '.mpod'])
    cif = urlread(['http://www.materialproperties.org/datafiles/' cod '.mpod']);
  else
    cif = urlread(cod);
  end
catch
  error('MPOD-file not valid online')
end

fname = fullfile(mtexTensorPath,[cod '.mpod']);

fid = fopen(fname,'w');
fwrite(fid,cif);
fclose(fid);
disp(['> copied to: ' fname]);


