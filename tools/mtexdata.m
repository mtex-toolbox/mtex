function out = mtexdata(name,varargin)
% load of data provided with mtex and often used in documentation
%
% Syntax
%   mtexdata        % displays a list of available loading routines
%   mtexdata name   % loads specified data set
%
% Input
%  name - name of the sample data
%

% read list of all available sample data
list = readtable(fullfile(mtexDataPath,'summary.txt'),'ReadRowNames',true);

type2var = containers.Map({'PoleFigure', 'EBSD', 'grain2d'}, {'pf','ebsd','grains'});

if nargin < 1

  if nargout == 0
    disp('available loading routines for mtex sample data');
    disp(list)
  else
    out = list.Properties.RowNames;
  end
  return

elseif strcmpi(name,'clear')

  files = dir(fullfile(mtexDataPath,'*.mat'));
  files = files(~strncmp('testgrains.mat',{files.name},14));
  for k=1:numel(files)
    delete(fullfile(mtexDataPath,[files(k).name]));
  end
  return
end

%
if isempty(strmatch(name,list.Properties.RowNames))
  warning('mtex:missingData','data not found, please choose one listed below')
  disp(list)
  return
end

type = char(list(name,:).type);

% try to load as mat file

% change warning to error to make it catchable
w = warning('error','MATLAB:load:cannotInstantiateLoadedVariable');
try
  
  matFile = fullfile(mtexDataPath,[ lower(name) '.mat']);
  load(matFile,'out');

catch
 
  fName = fullfile(mtexDataPath,type,char(list(name,:).files));
  
  % load from internet when required
  if isempty(dir(fName))
    
    url = ['https://raw.githubusercontent.com/mtex-toolbox/mtex/develop/data/' type '/' char(list(name,:).files)];
    disp('  downloading data from ')
    disp(' ');
    disp(['   <a href="' url '">' url '</a>'])
    disp(' ');
    disp(['  and saving it to ',fName]);
    
    websave(fName,url);
    
    if strcmp(url(end-2:end),'cpr')
      url(end-2:end) = 'crc';
      fName(end-2:end) = 'crc';
      disp('  downloading data from ')
      disp(' ');
      disp(['   <a href="' url '">' url '</a>'])
      disp(' ');
      disp(['  and saving it to ',fName]);
      websave(fName,url);
    end
  end
  
  switch type
    case 'PoleFigure'
      switch name
        case 'dubna'
          CS = loadCIF('quartz');
          c = {1,1,[0.52 ,1.23],1,1,1,1};
          out = PoleFigure.load(fName,'superposition',c,CS);
        case 'geesthacht'
          CS = crystalSymmetry('m-3m');
          out = PoleFigure.load(fName,CS);
        case 'ptx'
          CS = crystalSymmetry('mmm');
          out = PoleFigure.load(fName,CS);
      end
      
    case 'EBSD'
      switch lower(name)
        
        case 'aachen'
          CS = {...
            'notIndexed',...
            crystalSymmetry('m-3m','mineral','Fe','color','light blue'),...
            crystalSymmetry('m-3m','mineral','Mg','color','light red')};

          out = EBSD.load(fName,...
            'CS',CS,'ColumnNames', { 'Index' 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC' 'BS' 'Bands' 'Error' 'ReliabilityIndex'});

        case  'sharp'
          CS = {...
            'notIndexed',...
            crystalSymmetry('-3m',[5,5,17],'mineral','calcite','color','light blue')};

          out = EBSD.load(fName,'CS',CS,...
            'ColumnNames', {'Euler 1' 'Euler 2' 'Euler 3' 'Phase' 'x' 'y' });

        case 'csl'
          
          CS = crystalSymmetry('m-3m','mineral','iron');
          out = loadEBSD_generic(fName,'CS',CS,...
            'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3' 'IQ' 'CI' 'Error'});
          
        case 'mylonite'

          CS = {...
            crystalSymmetry('-1',[8.169,12.851,7.1124],[93.63,116.4,89.46]*degree,'mineral','Andesina'),...
            crystalSymmetry('-3m',[4.913,4.913,5.504],'mineral','Quartz'),...
            crystalSymmetry('2/m11',[5.339,9.249,20.196],[95.06,90,90]*degree,'mineral','Biotite'),...
            crystalSymmetry('12/m1',[8.5632,12.963,7.2099],[90,116.07,90]*degree,'mineral','Orthoclase')};

          plotx2east;
          plotzOutOfPlane
          out = loadEBSD_generic(fName,'CS',CS, ...
            'ColumnNames', { 'Phase' 'x' 'y' 'Euler 1' 'Euler 2' 'Euler 3'});
          
        case 'olivine'
          
          out = EBSD.load(fName);

          % correct data to fit the reference frame
          rot = rotation.byEuler(90*degree,180*degree,180*degree);
          out = rotate(out,rot,'keepEuler');
          rot = rotation.byEuler(0*degree,0*degree,90*degree);
          out = rotate(out,rot);

          % plotting conventions
          plotx2east; plotzOutOfPlane;
          
          % rotate only the spatial data about the y-axis
          % ebsd = rotate(ebsd,rotation('axis',xvector,'angle',180*degree),'keepEuler');
          
        case 'twins'
          
          plotx2east; plotzOutOfPlane
          out = EBSD.load(fName,'convertEuler2spatialReferenceFrame');
        
        case 'copper'

          plotx2east; plotzOutOfPlane
          out = EBSD.load(fName,'convertEuler2spatialReferenceFrame');

        case 'single'

          CS = crystalSymmetry('Fm3m',[4.04958 4.04958 4.04958],'mineral','Al');

          out = EBSD.load(fName, 'CS', CS, ...
            'RADIANS','ColumnNames', { 'Euler 1' 'Euler 2' 'Euler 3' 'x' 'y'},...
            'Columns', [1 2 3 4 5]);
          
        case 'alu'

          CS = crystalSymmetry('Fm3m',[4.04958 4.04958 4.04958],'mineral','Al');

          out = EBSD.load(fName,'CS', CS,...
            'RADIANS','ColumnNames', { 'Euler 1' 'Euler 2' 'Euler 3' 'x' 'y'},...
            'Columns', [1 2 3 4 5],'ignorePhase', 0);

        case 'titanium'

          CS = crystalSymmetry('622',[3,3,4.7],'x||a','mineral','Titanium (Alpha)');
          out = EBSD.load(fName,'CS', CS,...
            'ColumnNames', {'phi1' 'Phi' 'phi2' 'phase' 'ci' 'iq' 'sem_signal' 'x' 'y' 'grainId'});

        case 'ferrite'

          out = EBSD.load(fName,'convertEuler2SpatialReferenceFrame','setting 2');

        case 'epidote'

          out = EBSD.load(fName,'ignorePhase',[0 3 4],'convertEuler2SpatialReferenceFrame');
          
        case 'forsterite'

          plotx2east; plotzOutOfPlane
          out = EBSD.load(fName,'convertEuler2spatialReferenceFrame');

        case 'small'

          plotx2east; plotzOutOfPlane
          out = EBSD.load(fName,'convertEuler2spatialReferenceFrame');
          out = out(out.inpolygon([33 4.5 3 3]*10^3));

        case lower('alphaBetaTitanium')

          out = EBSD.load(fName,'convertSpatial2EulerReferenceFrame');
          out('Ti (alpha)').CS = out('Ti (alpha)').CS.properGroup;
          out('Ti (beta)').CS = out('Ti (beta)').CS.properGroup;

        case 'martensite'

          out = EBSD.load(fName,'convertEuler2SpatialReferenceFrame');
          out('Iron bcc').CS = out('Iron bcc').CS.properGroup;
          out('Iron bcc').CSList{3} = out('Iron bcc').CSList{3}.properGroup;

        case 'emsland'

          out = EBSD.load(fName,'convertEuler2SpatialReferenceFrame');
          
      end
      
  end    
  disp([' saving data to ' matFile])
  save(matFile,'out');
end

if nargout == 0
  assignin('base',type2var(type),out); 
  if ~check_option(varargin,'silent')
    evalin('base',type2var(type));
  end
  clear out;
end

% restore warning style
warning(w);

end
