function export_ang(ebsd,fName,varargin)
% Export EBSD data to TSL/EDAX text file (ang).
%
% Syntax
%   export_ang(ebsd,fName,varargin)
%
% Input
%  ebsd  - @EBSD
%  fName - Filename, optionally including relative or absolute path
%
% Flags
%  flipud - Flip ebsd spatial data upside down (not the orientation data)
%  fliplr - Flip ebsd spatial data left right (not the orientation data)
%


roundOff = 3; %Rounding coordinates to 'roundOff' digits

scrPrnt('SegmentStart','Exporting ''ang'' file');

% pre-processing
scrPrnt('Step','Collecting data');

ebsd.phaseMap = ebsd.phaseMap - (min(ebsd.phaseMap)+1); %Adapt *.ang phase map convention
if check_option(varargin,'flipud') %Flip spatial ebsd data
  ebsd = flipud(ebsd);
  scrPrnt('Step','Flipping EBSD spatial data upside down');
end
if check_option(varargin,'fliplr') %Flip spatial ebsd data
  ebsd = fliplr(ebsd);
  scrPrnt('Step','Flipping EBSD spatial data left right');
end

% get gridified version of ebsd map
ebsdGrid = ebsd.gridify;

% Open ang file
scrPrnt('Step','Opening file for writing');
filePh = fopen(fName,'w'); %Open new ang file for writing

% Write header
scrPrnt('Step','Writing file header');

% Write SEM info
fprintf(filePh,'# %-22s%.6f\n','TEM_PIXperUM',1);
fprintf(filePh,'# %-22s%.6f\n','x-star',0);
fprintf(filePh,'# %-22s%.6f\n','y-star',0);
fprintf(filePh,'# %-22s%.6f\n','z-star',0);
fprintf(filePh,'# %-22s%.6f\n','WorkingDistance',0);
fprintf(filePh,'#\n');

% Write phase info
for phaseId = fliplr(ebsd.indexedPhasesId)
  cs = ebsd.CSList{phaseId};
  fprintf(filePh,'# %s %.0f\n','Phase',ebsd.phaseMap(phaseId));
  fprintf(filePh,'# %s  \t%s\n','MaterialName',cs.mineral);
  fprintf(filePh,'# %s     \t%s\n','Formula','');
  fprintf(filePh,'# %s \t\t%s\n','Info','');
  fprintf(filePh,'# %-22s%s\n','Symmetry',cs.pointGroup);
  fprintf(filePh,'# %-22s %4.3f %5.3f %5.3f %7.3f %7.3f %7.3f\n',...
    'LatticeConstants',cs.aAxis.abs,cs.bAxis.abs,cs.cAxis.abs,...
    cs.alpha/degree,cs.beta/degree,cs.gamma/degree);
  fprintf(filePh,'# %-22s%.0f\n','NumberFamilies',0);
  for jj = 1:6
    fprintf(filePh,'# %s \t%.6f %.6f %.6f %.6f %.6f %.6f\n',...
      'ElasticConstants',0,0,0,0,0,0);
  end
  fprintf(filePh,'# %s%.0f %.0f %.0f %.0f %.0f \n','Categories',0,0,0,0,0);
  fprintf(filePh,'#\n');
end

% Write map info
if length(ebsd.unitCell)==6 %hex Grid
  fprintf(filePh,'# %s: %s\n','GRID','HexGrid');
else
  fprintf(filePh,'# %s: %s\n','GRID','SqrGrid');
end
fprintf(filePh,'# %s: %.6f\n','XSTEP',round(ebsdGrid.dx,roundOff));
fprintf(filePh,'# %s: %.6f\n','YSTEP',round(ebsdGrid.dy,roundOff));
if length(ebsd.unitCell)==6 %hex Grid
  fprintf(filePh,'# %s: %.0f\n','NCOLS_ODD',ebsdGrid.size(2)-1);
  fprintf(filePh,'# %s: %.0f\n','NCOLS_EVEN',ebsdGrid.size(2)-2);
else
  fprintf(filePh,'# %s: %.0f\n','NCOLS_ODD',ebsdGrid.size(2));
  fprintf(filePh,'# %s: %.0f\n','NCOLS_EVEN',ebsdGrid.size(2));
end
fprintf(filePh,'# %s: %.0f\n','NROWS',ebsdGrid.size(1));
fprintf(filePh,'#\n');
fprintf(filePh,'# %s: \t%s\n','OPERATOR','Administrator');
fprintf(filePh,'#\n');
fprintf(filePh,'# %s: \t%s\n','SAMPLEID','');
fprintf(filePh,'#\n');
fprintf(filePh,'# %s: \t%s\n','SCANID','');
fprintf(filePh,'#\n');

%Get data order x
if ebsdGrid.prop.x(1,1)< ebsdGrid.prop.x(1,2)
  dim.x = 2;
elseif ebsdGrid.prop.x(1,1)> ebsdGrid.prop.x(1,2)
  dim.x = -2;
elseif ebsdGrid.prop.x(1,1)< ebsdGrid.prop.x(2,1)
  dim.x = 1;
elseif ebsdGrid.prop.x(1,1)> ebsdGrid.prop.x(2,1)
  dim.x = -1;
end
%Get data order y
if ebsdGrid.prop.y(1,1)< ebsdGrid.prop.y(1,2)
  dim.y = 2;
elseif ebsdGrid.prop.y(1,1)> ebsdGrid.prop.y(1,2)
  dim.y = -2;
elseif ebsdGrid.prop.y(1,1)< ebsdGrid.prop.y(2,1)
  dim.y = 1;
elseif ebsdGrid.prop.y(1,1)> ebsdGrid.prop.y(2,1)
  dim.y = -1;
end
%Gather data
flds{1} = ebsdGrid.rotations.phi1;
flds{2} = ebsdGrid.rotations.Phi;
flds{3} = ebsdGrid.rotations.phi2;
flds{4} = ebsdGrid.prop.x;
flds{5} = ebsdGrid.prop.y;
if isfield(ebsd.prop,'iq')
  flds{6} = ebsdGrid.prop.iq;
elseif isfield(ebsd.prop,'bc')
  flds{6} = ebsdGrid.prop.bc;
  warning('Band contrast values were assigned to the image quality property');
else
  flds{6} = zeros(size(ebsdGrid));
  warning('Image quality values were set to 0');
end
if isfield(ebsd.prop,'ci')
  flds{7} = ebsdGrid.prop.ci;
elseif isfield(ebsd.prop,'bs')
  flds{7} = ebsdGrid.prop.bs;
  warning('Band slope values were assigned to the confidence index property');
else
  flds{7} = zeros(size(ebsdGrid));
  warning('Confidence index values were set to 0');
end
flds{8} = ebsdGrid.phase;
if isfield(ebsd.prop,'sem_signal')
  flds{9} = ebsdGrid.prop.sem_signal;
else
  flds{9} = ones(size(ebsdGrid));
  warning('SEM signal was set to 1');
end
if isfield(ebsd.prop,'fit')
  flds{10} = ebsdGrid.prop.fit;
elseif isfield(ebsd.prop,'mad')
  flds{10} = ebsdGrid.prop.mad;
  warning('Mean angular deviation values were assigned to the fit property');
else
  flds{10} = zeros(size(ebsdGrid));
  warning('Fit values were set to 0');
end
% Find empty coordinates in hexGrid
idDel = false(size(ebsdGrid));
if length(ebsd.unitCell)==6 %hex Grid 
    idDel(:,end) = true;
    idDel(2:2:end,end-1) = true;
end
%Write data
A = zeros(ebsdGrid.length,10); %initialize
for i = 1:length(flds)
  temp = flds{i};
  temp(idDel) = nan;
  %Transpose matrices if required
  if abs(dim.x) == 2 && abs(dim.y) == 1
    temp = temp';
  end
  
  %Flip matrices if required
  if dim.x < 0, temp = fliplr(temp); end
  if dim.y < 0, temp = flipud(temp); end
  
  %Make vector
  A(:,i) = temp(:);
end

%Fix coordinates
A(all(isnan(A),2),:) = [];        % Delete empty coordinates from hex grid
A(isnan(A)) = 0;                  % Set remaining NaN values to 0
A(:,4) =  A(:,4) - A(1,4);        % Set first x-value to 0
A(:,5) =  A(:,5) - A(1,5);        % Set first y-value to 0
A(:,4) = round(A(:,4),roundOff);  % Round of x-values
% write data array
scrPrnt('Step','Writing data array to ''ang'' file');
fprintf(filePh,'%9.5f %9.5f %9.5f %12.5f %12.5f %6.1f %6.3f %2.0f %6.0f %6.3f \n',A.');

% close ctf file
scrPrnt('Step','Closing file');
fclose(filePh);
scrPrnt('Step','All done',fName);

end

% *** Function scrPrnt - Screen Printing
function scrPrnt(mode,varargin)
%function scrPrnt(mode,varargin)
switch mode
  case 'SegmentStart'
    titleStr = varargin{1};
    fprintf('\n------------------------------------------------------');
    fprintf(['\n     ',titleStr,' \n']);
    fprintf('------------------------------------------------------\n');
  case 'Step'
    titleStr = varargin{1};
    fprintf([' -> ',titleStr,'\n']);
  case 'SubStep'
    titleStr = varargin{1};
    fprintf(['    - ',titleStr,'\n']);
end
end
