function S = mtexdata(name,varargin)
% load of data provided with mtex and often used in documentation
%
% Syntax
%   mtexdata        % displays a list of available loading routines
%   mtexdata name   % loads specified data set
%
% Input
%
% Flags
%    aachen -
%        3d - serial section 3d EBSD data from Leo Kestens
%  mylonite - collected by Daniel Rutte (Brad R. Hacker)
%   epidote - data provided by David Mainprice
%
%     dubna - collected by Florian Wobbe at Dubna
%       ptx -
% geesthacht -
%
%
% See also
%

list = listmtexdata;

if nargin < 1

  disp('available loading routines for mtex sample data');
  cprintf({'TYPE', list.type; 'NAME',list.name}');
  return

elseif strcmpi(name,'clear')

  files = dir(fullfile(mtexDataPath,'*.mat'));
  for k=1:numel(files)
    fullfile(mtexDataPath,[files(k).name]);
    delete(fullfile(mtexDataPath,[files(k).name]));
  end
  return

elseif strcmpi(name,'all')

  for files = list
    mtexdata(files.name)
  end
  return

end


ndx = strmatch(name,{list.name});

if any(ndx)
  file = fullfile(mtexDataPath,[ lower(list(ndx).name) '.mat']);
else
  warning('mtex:missingData','data not found, please choose one listed below')
  mtexdata
  return
end

% change warning to error to make it catchable
w = warning('error','MATLAB:load:cannotInstantiateLoadedVariable');

% try to load
try
  S = load(file);
  
  % ensure classes where loaded correctly
  assert(all(structfun(@(x) ~isstruct(x),S)));
    
catch %#ok<CTCH> % if can not load -> import

  if any(ndx) 

    disp(' loading data ...')
    switch list(ndx).type
      case 'ebsd'
        S.ebsd = feval(['mtexdata_' list(ndx).name]);        
      case 'pf'
        [S.CS,S.h,S.c,S.pf] = feval(['mtexdata_' list(ndx).name]);
    end
    disp([' saving data to ' file])
    save(file,'-struct','S');
  end
  
end

% restore warning style
warning(w);

% copy to workspace
fld = fields(S);
for k=1:numel(fld)
  assignin('base',fld{k},S.(fld{k}));
end

% display
if ~getMTEXpref('generatingHelpMode')
  disp([ upper(list(ndx).name) ' data loaded in variables']);
  disp(fld)
  evalin('base',fld{end});
end

if nargout == 0, clear S; end

% -----------------------------------------------------------------------
function data = listmtexdata

fid = fopen([mfilename('fullpath') '.m'],'r');
A = char(fread(fid,'char')');
fclose(fid);

data = regexp(A,'function(.*?)(?<type>(ebsd|pf))(.*?)mtexdata_(?<name>\w*)','names');
data(cellfun('isempty',{data.name})) = [];


% -------------------- PoleFigure data ----------------------------------
function [CS,h,c,pf] = mtexdata_dubna

CS = loadCIF('quartz');

fname = {...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(02-21)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-10)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-11)(01-11)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-12)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-20)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-21)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-22)_amp.cnv')};

h = {...
  Miller(0,2,-2,1,CS),...
  Miller(1,0,-1,0,CS),...
  [Miller(0,1,-1,1,CS),Miller(1,0,-1,1,CS)],... % superposed pole figures
  Miller(1,0,-1,2,CS),...
  Miller(1,1,-2,0,CS),...
  Miller(1,1,-2,1,CS),...
  Miller(1,1,-2,2,CS)};

c = {1,1,[0.52 ,1.23],1,1,1,1};

pf = loadPoleFigure(fname,h,'interface','dubna','superposition',c,CS);

% ------------------------------------------------------------------
function [CS,h,c,pf] = mtexdata_geesthacht

CS = crystalSymmetry('m-3m');
SS = specimenSymmetry('-1');

fname = fullfile(mtexDataPath,'PoleFigure','geesthacht','ST42-104-110.dat');

h = { ...
  Miller(1,0,4,CS), ...
  Miller(1,0,4,CS), ...
  Miller(1,1,0,CS), ...
  Miller(1,1,0,CS), ...
  };

c = ones(size(h));

pf = loadPoleFigure(fname,h,CS,SS);

%
function   [CS,h,c,pf] = mtexdata_ptx

CS = crystalSymmetry('mmm');
SS = specimenSymmetry('-1');

pname = fullfile(mtexDataPath,'PoleFigure','ptx');
fname = {...
  [pname '/gt9104.ptx'], ...
  [pname '/gt9110.ptx'], ...
  [pname '/gt9202.ptx'], ...
  };

pf = loadPoleFigure(fname,CS,SS);
h = pf.allH;
c = ones(size(h));

% -------------------------- EBSD data ---------------------------------
function ebsd = mtexdata_aachen
CS = {...
  'notIndexed',...
  crystalSymmetry('m-3m','mineral','Fe','color','light blue'),...
  crystalSymmetry('m-3m','mineral','Mg','color','light red')};

ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','85_829grad_07_09_06.txt'),...
  'CS',CS,'interface','generic' , ...
  'ColumnNames', { 'Index' 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC' 'BS' 'Bands' 'Error' 'ReliabilityIndex'});

%
function ebsd = mtexdata_sharp

CS = {...
  'notIndexed',...
  crystalSymmetry('-3m',[5,5,17],'mineral','calcite','color','light blue')};

ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','sharp.txt'),'CS',CS,...
  'ColumnNames', {'Euler 1' 'Euler 2' 'Euler 3' 'Phase' 'x' 'y' });

function ebsd = mtexdata_small

plotx2east
ebsd = mtexdata_forsterite;
region = [33 4.5 3 3]*10^3;
ebsd = ebsd(ebsd.inpolygon(region));

% --------------------------------------------------------------
function ebsd = mtexdata_csl

CS = crystalSymmetry('m-3m','mineral','iron');
ebsd = loadEBSD_generic(fullfile(mtexDataPath,'EBSD','CSL.txt'),'CS',CS,...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'IQ' 'CI' 'Error'});


% ----------------------------------------------------------------------
function ebsd = mtexdata_3d

ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','3dData','*.ANG'),...
  '3d', (0:58)*0.12,'convertEuler2SpatialReferenceFrame');

% ----------------------------------------------------------------------
function ebsd = mtexdata_mylonite

CS = {...
  crystalSymmetry('-1',[8.169,12.851,7.1124],[93.63,116.4,89.46]*degree,'mineral','Andesina'),...
  crystalSymmetry('-3m',[4.913,4.913,5.504],'mineral','Quartz'),...
  crystalSymmetry('2/m',[5.339,9.249,20.196],[95.06,90,90]*degree,'mineral','Biotite'),...
  crystalSymmetry('2/m',[8.5632,12.963,7.2099],[90,116.07,90]*degree,'mineral','Orthoclase')};

ebsd = loadEBSD_generic(fullfile(mtexDataPath,'EBSD','P5629U1.txt'),'CS',CS, ...
  'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3'});

% ----------------------------------------------------------------------
function ebsd = mtexdata_epidote

ebsd = loadEBSD([mtexDataPath '/EBSD/data.ctf'],'ignorePhase',[0 3 4],...
  'convertEuler2SpatialReferenceFrame');

% ----------------------------------------------------------------------
function ebsd = mtexdata_forsterite

plotx2east; 
plotzOutOfPlane
ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','Forsterite.ctf'),'convertEuler2spatialReferenceFrame');

% rotate only the spatial data about the y-axis
% ebsd = rotate(ebsd,rotation('axis',xvector,'angle',180*degree),'keepEuler');


function ebsd = mtexdata_olivine

plotx2east; 
plotzOutOfPlane
ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','olivineopticalmap.ang'));

% correct data to fit the reference frame
rot = rotation('Euler',90*degree,180*degree,180*degree);
ebsd = rotate(ebsd,rot,'keepEuler');
rot = rotation('Euler',0*degree,0*degree,90*degree);
ebsd = rotate(ebsd,rot);

% plotting conventions
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','outOfPlane');

% rotate only the spatial data about the y-axis
% ebsd = rotate(ebsd,rotation('axis',xvector,'angle',180*degree),'keepEuler');


function ebsd = mtexdata_twins

plotx2east; plotzOutOfPlane
CS = crystalSymmetry('6/mmm',[3.2 3.2 5.2],'mineral','Magnesium','x||a*')
ebsd = loadEBSD(fullfile(mtexDataPath,'EBSD','twins.ctf'),CS,'convertEuler2spatialReferenceFrame');


% -----------------------------------------------------------------------
function ebsd = mtexdata_single

CS = crystalSymmetry('Fm3m',[4.04958 4.04958 4.04958],'mineral','Al'); 

fname = fullfile(mtexDataPath,'EBSD','single_grain_aluminum.txt');
ebsd = loadEBSD(fname, 'interface','generic', 'CS', CS, ...
   'RADIANS','ColumnNames', { 'Euler 1' 'Euler 2' 'Euler 3' 'x' 'y'},...
  'Columns', [1 2 3 4 5]);

% ----------------------------------------------------------------------
function ebsd = mtexdata_alu

CS = crystalSymmetry('Fm3m',[4.04958 4.04958 4.04958],'mineral','Al');

fname = fullfile(mtexDataPath,'EBSD','polycrystalline_aluminum.txt');
ebsd = loadEBSD(fname, 'interface','generic', 'CS', CS,...
   'RADIANS','ColumnNames', { 'Euler 1' 'Euler 2' 'Euler 3' 'x' 'y'},...
  'Columns', [1 2 3 4 5],'ignorePhase', 0);

% ----------------------------------------------------------------------
function ebsd = mtexdata_titanium

CS = crystalSymmetry('622',[3,3,4.7],'x||a','mineral','Titanium (Alpha)');

fname = fullfile(mtexDataPath,'EBSD','titanium.txt');
ebsd = loadEBSD(fname, 'interface','generic', 'CS', CS,...
   'ColumnNames', {'phi1' 'Phi' 'phi2' 'phase' 'ci' 'iq' 'sem_signal' ...
   'x' 'y' 'grainId'});

