function export_ctf(ebsd,fName,varargin)
%function exportCTF(ebsd,fName,varargin)
%
% Export EBSD data to Channel 5 text file (ctf). The resulting ctf file
% can for instance be opened with Channel 5 and Atex or further converted
% to 'ang' format for opening with Edax OIM
%
% Dr. Frank Niessen, University of Wollongong, Australia, 2019
% contactnospam@fniessen.com (remove the nospam to make this email address work)
% Acknowledgements go to Dr. Azdiar A. Gazder, University of Wollongong, Australia
% Version 1.0 - Published 18/04/2019
%
% Syntax
%
%   export_ctf(ebsd,fileName)
%   export_ctf(ebsd,fileName,cprStruct)
%   export_ctf(ebsd,fileName,'manual')
%   export_ctf(ebsd,fileName,'flip')
%
% Input
%  ebsd - @EBSD
%  fileName - Filename, optionally including relative or absolute path
%  cprStruct - structure with properties from cpr-file import
%
% Flags
%  manual - prompt for manual import of microscopy parameters
%  cprStruct - structure with properties from cpr-file import
%  flipud - Flip ebsd spatial data upside down (not the orientation data)
%  fliplr - Flip ebsd spatial data left right (not the orientation data)
%

scrPrnt('SegmentStart','Exporting ''ctf'' file');

% initialize threshold for rounding negative close to 0 x and y coordinates
round0Thrsh = 1e-6;

% pre-processing
scrPrnt('Step','Collecting data');

ebsd = reduce(ebsd,1);
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

mtexId2ctfId = [1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,6,6,7,7,7,7,7,7,4,4,...
  4,5,5,5,5,5,8,8,8,9,9,9,9,9,10,10,11,11,11];


%Cell-String array with Acquisition parameters
AcquParam.Str = {'Mag','Coverage','Device','KV','TiltAngle','TiltAxis',...
  'DetectorOrientationE1','DetectorOrientationE2','DetectorOrientationE3',...
  'WorkingDistance','InsertionDistance'};

%Cell-String array with Acquisition parameter formats
AcquParam.Fmt = {'%.4f','%.0f','%s','%.4f','%.4f','%.0f','%.4f','%.4f',...
  '%.4f','%.4f','%.4f'};

% get microscope acquisition parameters
cprStruct = getClass(varargin,'struct');

if isstruct(cprStruct) && isfield(cprStruct,'job') &&  isfield(cprStruct,'semfields')

  %Cpr-file parameter structure from import
  scrPrnt('SubStep','Microscope acquisition parameters imported from Cpr-parameter structure');
  AcquParam.Data{1} = cprStruct.job.magnification;
  AcquParam.Data{2} = cprStruct.job.coverage;
  AcquParam.Data{3} = cprStruct.job.device;
  AcquParam.Data{4} = cprStruct.job.kv; % acceleration voltage
  AcquParam.Data{5} = cprStruct.job.tiltangle;
  AcquParam.Data{6} = cprStruct.job.tiltaxis;
  AcquParam.Data{7} = cprStruct.semfields.doeuler1; % detector orientation Euler 1
  AcquParam.Data{8} = cprStruct.semfields.doeuler2; % detector orientation Euler 2
  AcquParam.Data{9} = cprStruct.semfields.doeuler3; % detector orientation Euler 3
  AcquParam.Data{10} = 0;                        % working distance (information not available)
  AcquParam.Data{11} = 0;                        % insertion distance (information not available)

elseif check_option(varargin,'manual') %Manual prompt

  scrPrnt('SubStep','Insert microscope acquisition parameters manually');

  % input dialog box
  answer = inputdlg(strcat(AcquParam.Str,':'),'Input parameters - numeric only',...
    [1 100],sprintfc('%d',zeros(1,11)));

  % check if terminated
  if isempty(answer); error('Terminated by user'); end

  % convert to numbers
  AcquParam.Data = arrayfun(@str2double, answer, 'Uniform', false);

else % no microscope data available

  scrPrnt('SubStep','Microscope acquisition parameters not available');

  AcquParam.Data(1:11) = {0}; % filling in zeros

end

% Open ctf file
scrPrnt('Step','Opening file for writing');
filePh = fopen(fName,'w');                                                 %Open new ctf file for writing

% Write header
scrPrnt('Step','Writing file header');

% write file info
fprintf(filePh,'Channel Text File\r\n');
fprintf(filePh,'Prj %s\r\n',fName);
fprintf(filePh,'Author\t%s\r\n',getenv('USERNAME'));
fprintf(filePh,'JobMode\tGrid\r\n');

% write grid info
fprintf(filePh,'XCells\t%.0f\r\n',size(ebsdGrid,2));
fprintf(filePh,'YCells\t%.0f\r\n',size(ebsdGrid,1));
fprintf(filePh,'XStep\t%.4f\r\n',ebsdGrid.dx);
fprintf(filePh,'YStep\t%.4f\r\n',ebsdGrid.dy);
fprintf(filePh,'AcqE1\t%.4f\r\n',0);
fprintf(filePh,'AcqE2\t%.4f\r\n',0);
fprintf(filePh,'AcqE3\t%.4f\r\n',0);

% write acquisition parameters
fprintf(filePh,'Euler angles refer to Sample Coordinate system (CS0)!\t');
for i = 1:length(AcquParam.Str) %Loop over aquisition parameters
  if ~strcmp(AcquParam.Fmt{i},'%s') %if numeric format is required
    AcquParam.Data{i} = num2str(AcquParam.Data{i},AcquParam.Fmt{i});    %Convert number to string
  elseif strcmp(AcquParam.Fmt{i},'%s') %if string format is required
    if ~ischar(AcquParam.Data{i}) %check if manual input is numeric
      AcquParam.Data{i} = num2str(AcquParam.Data{i}); %Convert to string
    end
  end
  fprintf(filePh,'%s\t%s\t',AcquParam.Str{i},AcquParam.Data{i}); %Write parameter
end
fprintf(filePh,'\r\n');


% extract crystal system information
CSlst = ebsd.CSList(ebsd.indexedPhasesId);

% write phase info
fprintf(filePh,'Phases\t%.0f\r\n',length(CSlst)); %Write nr of phases
for i = 1:length(CSlst)
  mineral = CSlst{i}.mineral;
  a = CSlst{i}.aAxis.abs;
  b = CSlst{i}.bAxis.abs;
  c = CSlst{i}.cAxis.abs;
  alpha = CSlst{i}.alpha / degree;
  beta = CSlst{i}.beta / degree;
  gamma = CSlst{i}.gamma / degree;
  laueGr = mtexId2ctfId(CSlst{i}.id);     %Get Laue Group
  spaceGr = 0;                            %Space Group (information not available)
  comment = 'Created from mtex';          %Phase information comment
  fprintf(filePh,'%.3f;%.3f;%.3f\t%.3f;%.3f;%.3f\t%s\t%.0f\t%.0f\t\t\t%s\r\n',...
    a,b,c,alpha,beta,gamma,mineral,laueGr,spaceGr,comment);%Write phase info
end

% Check for deleted phases
phase = ebsdGrid.phase;
maxPhID = max(max(phase));   %Check maximum phase ID in phase list
k = maxPhID-1;
while k > 0
    if ~any(any(ebsdGrid.phase == 1)) %Empty phase ID, i.e. deleted phase
       phase(phase > k) = phase(phase > k)-1; %Reduce phase ID
    end
    k = k-1;
end

% assemble data array
scrPrnt('Step','Assembling data array');

% write data header
fprintf(filePh,'Phase\tX\tY\tBands\tError\tEuler1\tEuler2\tEuler3\tMAD\tBC\tBS\r\n'); %Data header

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

ebsdList = reduce(ebsdGrid,1);
%Compute X and Y data
X = repmat(1:size(ebsdGrid,1),size(ebsdGrid,2),1);
X = round(ebsdGrid.dx,5).*X(:);
Y = repmat(1:size(ebsdGrid,1),1,size(ebsdGrid,2));
Y = round(ebsdGrid.dy,5).*Y(:);

%Gather data
flds{1} = phase(:);
flds{2} = X;
flds{3} = Y;
if isfield(ebsd.prop,'bands')
  flds{4} = ebsdList.prop.bands;
else
  flds{4} = zeros(size(ebsdList));
  warning('Bands values were set to 0');
end
if isfield(ebsd.prop,'error')
  flds{5} = ebsdList.prop.error;
else
  flds{5} = zeros(size(ebsdList));
  warning('error values were set to 0');
end
flds{6} = ebsdList.rotations.phi1/degree;
flds{7} = ebsdList.rotations.Phi/degree;
flds{8} = ebsdList.rotations.phi2/degree;
if isfield(ebsd.prop,'mad')
  flds{9} = ebsdList.prop.mad;
elseif isfield(ebsd.prop,'fit')
  flds{9} = ebsdList.prop.fit;
  warning('mad values were set to fit values');
else
  flds{9} = zeros(size(ebsdList));
  warning('mad values were set to 0');
end
if isfield(ebsd.prop,'bc')
  flds{10} = ebsdList.prop.bc;
% elseif isfield(ebsd.prop,'imagequality')
%   flds{10} = ebsdList.prop.imagequality;
%   warning('bc values were set to imagequality values');
else
  flds{10} = zeros(size(ebsdList));
  warning('bc values were set to 0');
end
if isfield(ebsd.prop,'bs')
  flds{11} = ebsdList.prop.bs;
elseif isfield(ebsd.prop,'semsignal')
  flds{11} = ebsdList.prop.semsignal;
  warning('bs values were set to semsignal values');
else
  flds{11} = zeros(size(ebsdList));
  warning('bs values were set to 0');
end

% Set nan data points to 0
for ii = 1:length(flds), flds{ii}(isnan(flds{ii})) = 0; end
% Make X increase first
[~,ind] = sort(ebsdList.prop.y);

%Write data
A = zeros(ebsdList.length,11); %initialize
for i = 1:length(flds)
    temp = flds{i};
    temp = temp(ind);
    %Transpose matrices if required
    if abs(dim.x == 2) && abs(dim.y) == 1
        temp = temp';
    end
    %Flip matrices if required
    if dim.x < 0, temp = fliplr(temp); end
    if dim.y < 0, temp = flipud(temp); end
    %Make vector
    A(:,i) = reshape(temp,ebsdList.length,1);
end

A(find(all([A(:,2)>-round0Thrsh,A(:,2)<round0Thrsh],2)),2) = 0;            %Rounding close to 0 X coordinates
A(find(all([A(:,3)>-round0Thrsh,A(:,3)<round0Thrsh],2)),3) = 0;            %Rounding close to 0 Y coordinates
A(isnan(A)) = 0;                                                           %Set NaN to 0
A(:,2) =  A(:,2) - A(1,2);                                                 %Set first x-value to 0
A(:,3) =  A(:,3) - A(1,3);                                                 %Set first y-value to 0

% write data array
scrPrnt('Step','Writing data array to ''ctf'' file');
fprintf(filePh,'%.0f\t%.4f\t%.4f\t%.0f\t%.0f\t%.4f\t%.4f\t%.4f\t%.4f\t%.0f\t%.0f\r\n',A.');

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


% MIT License
%
% Copyright (c) 2019 Frank Niessen
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
