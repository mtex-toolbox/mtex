function T = loadTensor_mpod(fname,varargin)
% import Tensor data
%
% Description
% *loadTensor_mod* is a high level method for importing Tensor data from external
% files.
% <http://www.materialproperties.org/data/ Material Properties Open
% Database>
%
% Syntax
%   T = loadTensor_mpod(fname,cs,ss)
%
% Input
%  fname     - filename
%  cs, ss    - crystal, specimen @symmetry (optional)
%
% Example
% download form MPOD
%    T = loadTensor_mpod(1000055)
%    T = loadTensor_mpod('1000055.mpod')
%
% See also
% loadTensor

% Remarks
% TODO
%
%  * allow import of not ij indexed single properties e.g. _prop_heat_capacity_C
%  * respect multiple measured properties i.e _prop_conditions (_prop_conditions_temperature)
%  * better symmetry import
%  * do it right for combined ijE,ijS notation (e.g. _prop_piezoelectric_*)

if isnumeric(fname), fname = copyonline(fname);end

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

try
  cs = mpod2symmetry(str,varargin{:});
catch
  cs = specimenSymmetry;
end

T = {};
prop = get_option(varargin,'property','',{'char','cell'});
if ~iscell(prop), prop = {prop}; end

%second, third or forth order tensors
entry = regexp(str,'_prop_(?<property>\w*(?<=ij)(.*)) ''(?<index>\w*)''','names');

for Entry = entry(~cellfun('isempty',entry))
  
  index = Entry{:}.index;
  
  property = deblank(regexprep(Entry{:}.property,['_|' index],' '));
  
  if all(cellfun('isempty',prop)) || any(~cellfun('isempty',regexp(property,prop)))
    
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
    
    [i,j,v]=find(M);
    
    if (size(M,1)==6) && (size(M,2)==6)
      rank = 4;
      s = [6 6];
    elseif (size(M,1) < 4) && (size(M,2) > 3)
      rank = 3;
      s = [3 6];
    elseif all(size(M) == 3)
      rank = 2;
      s = [3 3];
    end

    M = full(sparse(i,j,v,s(1),s(2)));
    
    [u,s] = units(index);
    
    %T{end+1,1} = s*symmetrise(tensor(M,cs,'rank',rank,'propertyname',[property ' ' index],'unit',u)); %#ok<AGROW>
    T{end+1,1} = s*tensor(M,cs,'rank',rank,'propertyname',[property ' ' index],'unit',u); %#ok<AGROW>
    
  end
end

% one rank or second rank tensors
entry = regexp(str,'_prop_(?<property>\w*(?<=i|ii)) ''(?<index>\w*)''','names');

for Entry = entry(~cellfun('isempty',entry))
  
  index = Entry{:}.index;
  
  property = deblank(regexprep(Entry{:}.property,['_|' index],' '));
  
  if all(cellfun('isempty',prop)) || any(~cellfun('isempty',regexp(property,prop)))
    
    pos = strfind(str,index);
    index_i = str(cellfun('prodofsize',pos)==1);
    index_i = regexp(index_i,[index,' (?<i>[0-9]) (?<value>[0-9.-]*)'],'names');
    index_i = [index_i{:}];
 
    M = zeros(3,1);
    rank = 1;
    for k=1:numel(index_i)
      val = str2num(index_i(k).value);
      if isempty(val), val = 0; end
      M(str2num(index_i(k).i),1) = val;
    end
   
    [u,s] = units(index);
    T{end+1,1} = s*(tensor(M,cs,'rank',rank,'propertyname',[property ' ' index],'unit',u)); %#ok<AGROW>
    
  end
end

if numel(T) == 1, T = T{1};end

if isempty(T), interfaceError(fname); end

function [cs,mineral] = mpod2symmetry(str,varargin)
% import crystal symmetry from cif file

pattern = '_cod_database_code';
pos = strmatch(pattern,str);
if ~isempty(pos)
  cod = strtrim(regexprep(str{pos},pattern,''));
  if  ~isempty(cod) && ~strcmpi(cod,'?')
    cs = loadCIF(cod);
    return
  end
end

try
  [cs,mineral] = loadCIF(str);
catch
end



function [u s] = units(index)

u = 'pure number';
s = 1;
switch index
  case {'cij','cijD','cijE'} % elastic
    u = 'GPa';
  case {'sij','sijD','sijE'}
    u = 'm^2.Pa^-1';
    s = 10^-12;
  case {'rhoij'}
    u = 'Ohm.cm';
    s = 10^-6;
  case {'Dij','Dprimeij'}
    u = 'm^2.V^-2 and m^4.C';
    s = 10^-20;
  case {'C'}
    u = 'Jg^-1.K^-1';
  case {'dij'} % piezo
    u = 'm.V^-1';
  case {'eij'}
    u = 'C.N^-1';
  case {'gij'}
    u = 'C.m^-2';
  case {'hij'}
    u = 'V.m.N^-1';
  case {'Qij','betrijS','betrijT'}
    s = 10^-4;
  case {'kappaij'}
    u = 'W.K^-1.m^-1';
  case {'kappadij'}
    u = 'm^2.s^-1';
  case {'alphaij'}
    u = 'K^-1';
    s = 10^-6;
  case {'lambdaai','ksij'}
    u = 'nm';
    
  case {'Hc1i','Hc2i'}
    u = 'T';
    
  case {'Tco','Tcon90','Tcm50','Tcof10','Tr0','Tcth',...
     'Rtw','RRTh','RRR','RRTl'}
    u = 'K';
   
end



function fname = copyonline(cod)

try
  if isnumeric(cod)
    cod = num2str(cod);
  end
  
  fname = fullfile(mtexTensorPath,[cod '.mpod']);
  if exist(fname,'file')
    return
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


