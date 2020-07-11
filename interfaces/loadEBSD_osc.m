function ebsd = loadEBSD_osc(fname,varargin)
%

ebsd = EBSD;

try
  assertExtension(fname,'.osc');

  CS = get_option(varargin,'CS',oscHeader(fname));

  if check_option(varargin,'check')
    return
  end

  [data,Xstep,Ystep] = oscData( fname );

  %Need to handle data like prius or EDS
  nCols=size(data,2);

  colNames={'phi1','Phi','phi2','x','y','ImageQuality',...
    'ConfidenceIndex','Phase','SemSignal','Fit'};
  if nCols > 10
      for col = length(colNames)+1:nCols
          colNames{col}=strcat('unknown_',int2str(col));
      end
      disp('Warning: more column data was passed in than expected. Check your column names make sense!')
  elseif nCols < 5
      error('Error: need to pass in atleast position and orientation data')
  elseif nCols <9
      disp('Warning: Less column data was passed in than expected. Check your column names make sense!')
  end

  loader = loadHelper(data,'ColumnNames',colNames(1:nCols),'Radians');

  if Xstep ~= Ystep % probably hexagonal
    unitCell = [...
      -Xstep/2   -Ystep/3;
      -Xstep/2    Ystep/3;
      0         2*Ystep/3;
      Xstep/2     Ystep/3;
      Xstep/2    -Ystep/3;
      0        -2*Ystep/3];
  else
    unitCell = [...
      Xstep/2 -Ystep/2;
      Xstep/2  Ystep/2;
      -Xstep/2  Ystep/2;
      -Xstep/2 -Ystep/2];
  end

  ebsd = EBSD(loader.getRotations(),...
    loader.getColumnData('phase'),...
    CS,...
    loader.getOptions('ignoreColumns','phase'),...
    'unitCell',unitCell);

catch
  interfaceError(fname)
end


% change reference frame, same as for .ang files
rot = [...
  rotation.byAxisAngle(xvector+yvector,180*degree),... % setting 1
  rotation.byAxisAngle(xvector-yvector,180*degree),... % setting 2
  rotation.byAxisAngle(xvector,180*degree),...         % setting 3
  rotation.byAxisAngle(yvector,180*degree)];           % setting 4

% get the correction setting
corSettings = {'notSet','setting 1','setting 2','setting 3','setting 4'};
corSetting = get_flag(varargin,corSettings,'notSet');
corSetting = find(strcmpi(corSetting,corSettings))-1;

if check_option(varargin,'convertSpatial2EulerReferenceFrame')
  flag = 'keepEuler';
  opt = 'convertSpatial2EulerReferenceFrame';
elseif check_option(varargin,'convertEuler2SpatialReferenceFrame')
  flag = 'keepXY';
  opt = 'convertEuler2SpatialReferenceFrame';
else
  if ~check_option(varargin,'wizard')
    warning(['.ang files have usualy inconsistent conventions for spatial ' ...
      'coordinates and Euler angles. You may want to use one of the options ' ...
      '''convertSpatial2EulerReferenceFrame'' or ''convertEuler2SpatialReferenceFrame'' to correct for this']);
  end
  return
end

if corSetting == 0
  warning('%s\n\n ebsd = EBSD.load(fileName,''%s'',''setting 2'')',...
    ['You have choosen to correct your EBSD data for differently aligned '...
    'reference frames for the Euler angles and the map coordinates. '...
    'However, you have not specified which reference system setting has been used on your Edax system . ' ...
    'I''m going to assume "setting 1". '...
    'Be careful, the default setting of EDAX is "setting 2". '...
    'Click <a href="matlab:MTEXdoc(''EBSDReferenceFrame'')">here</a> for more information.'...
    'Please make sure you have chosen the correct setting and specify it explicitely using the syntax'],...
    opt)
  corSetting = 1;
end
ebsd = rotate(ebsd,rot(corSetting),flag);


% taken from ANYSTITCH
%
% A.L. PILCHAK, A.R. SHIVELEY, J.S. TILEY, and D.L. BALLARD,
% AnyStitch: a tool for combining electron backscatter diffraction data sets.
% Journal of Microscopy, 244 (1), 2011, pp. 38-44.
%
% More complete documentation can be found in the User's manual and in the
% Journal of Microscopy article itself.
%
% adam.pilchak@wpafb.af.mil
% adam.shiveley@wpafb.af.mil
%
% BSD License:
%  * ================================================================================
%  * Copyright (c) 2011, Adam L. Pilchak, Adam R. Shiveley (USAF Research Laboratory)
%  * All rights reserved.
%  *
%  * Redistribution and use in source and binary forms, with or without modification,
%  * are permitted provided that the following conditions are met:
%  *
%  * Redistributions of source code must retain the above copyright notice, this
%  * list of conditions and the following disclaimer.
%  *
%  * Redistributions in binary form must reproduce the above copyright notice, this
%  * list of conditions and the following disclaimer in the documentation and/or
%  * other materials provided with the distribution.
%  *
%  * Neither the name of the software, AnyStitch, nor the names of its contributors may
%  * be used to endorse or promote products derived from this software without
%  * specific prior written permission from Adam L. Pilchak.
%  *
%  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%  * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
%  * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
%  * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
%  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
%  * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
%  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
%  * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
%

% Osc2Ang( OscFile )
function [data, Xstep, Ystep] = oscData( file )
%  [RelevantData,Xstep,Ystep ] = Osc2Ang(OscFile) reads the *.osc file
%  whose path is defined by the string OscFile into a variable RelevantData in the matlab workspace.
%  The X and Y step sizes are also extracted.
%
%   The variable RelevantData contains all of the data normally found in
%   an *.ang file
%
%
% Open the Current Osc for reading as binary
% % fid = fopen(OscFile,'rb');

% read the data stored in the .osc file as 8 bit
% % data = transpose(fread( fid, '*int8' ));
% Close the currently open .osc file
% % fclose(fid);

% Search the data read in from the .osc for the starting
% location of the real data in the .osc.  The data at this point
% is an array of ascii values.  Searching for this unqiue
% grouping will locate the beginning of the Relevant Data.
%%% NOTE: This string may change in other versions of TSL OIM
% % start_euler_indices = strfind(data,[-71 11 -17 -1 2]);

% the location of the eurler angles.  The .osc always has 3 or
% more matches with this command.  The first match is the
% location of the first phase, but parsing the data out for the
% first phase requires converting between *bit8, hex, and
% readable strings.  The second match, as with TSL 5.2 and TSL
% 5.3 contains the starting location of the real data.  The 3
% match contains the ending location of the real data.  Any
% other matches in this array indicate ending locations for the
% Hough Transfomrs. This may change for later versions.
% % end_euler_indices = strfind(data, [-71 11 -17 -1]);
% % end_euler = end_euler_indices(find(end_euler_indices == start_euler_indices)+1);
% % euler_angles_ascii = data(start_euler_indices:end_euler-1);

% Reshape the euler data into arrays, 4 chracters in
% length to be used in the typecast function
% % final_euler_angles = reshape(euler_angles_ascii,[4,length(euler_angles_ascii)/4]);
% % RelevantData = typecast(final_euler_angles(:), 'single');


% faster version

% look for a certain pattern
startBytes = hex2dec({'B9','0B','EF','FF','02','00','00','00'});
% stopBytes  = hex2dec({'B9','0B','EF','FF','40','00','00','00'});


% open fild
fid = fopen(file,'rb');

% read the first 8 uint32 vals
header = fread(fid,8,'uint32','l');
%{
nx = header(5);
ny = header(6);
%}
n  = header(7);

% default start pos?
startPos = 0; %6100;

bufferLength = 2^20;
fseek(fid,startPos,-1);
startData = fread(fid,bufferLength,'*uint8', 'l');
startPos  = startPos + strfind(startData',startBytes') - 1;

fseek(fid,startPos+8,-1);

% there different osc file versions, one does have some count of data
% another proceeds with x/ystep
dn = double(fread(fid,1,'uint32','l'));
if round(((dn/4-2)/10) /n ) ~= 1
  fseek(fid,startPos+8,-1);
end

% Collect the values for Xstep and Ystep, from the .osc file
%for some reason there can be a misalignment here
Xstep = double(fread(fid,1,'single','l'));
if Xstep==0
   Xstep = double(fread(fid,1,'single','l'));
   Ystep = double(fread(fid,1,'single','l'));
else
   Ystep = double(fread(fid,1,'single','l'));

end

% Break the data up into an array that resembles the .ang
% file format being sure to transpose
%Problem is on a per version basis, you get different number of columns and
%depending on your analysis, you may have EDS or Prius columns..
position = ftell(fid);
for i=5:30
    data = reshape(double(fread(fid,n*i,'single','l')),i,n)';
    if round(data(2,4),4)==round(Xstep,4) && round(data(2,5),4)==0
        break;
    end
    assert(i~=30,'max number of columns reached, formate not handled')
    fseek(fid,position,'bof');
end
% data = reshape(double(fread(fid,n*10,'single','l')),10,n)'; %DS


% many thanks to adam shiveley
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%coded by: Adam Shiveley   28 Nov 11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% original file was Decode_Header(OscFile, foutname)
% I (florian) rewrote it a little.
%
function CS = oscHeader(file)
% some remarksAdam Shiveley
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%So, the file is structured like this:
%Phase 1 name
%Phase 1 symmetry
%Phase 1 LatticeConstants
%Phase 1 Number of Families
%Phase 1 hklFamilies (read in every third one)
%Phase 1 Formula name
%This repeats for each phase in the scan
%sounds simple, right? Wrong the values are stored in decimal
%because of the way I choose to read the file in.
%This means data(10) = 70 which is actually the letter
%F as explained in this example:
%This is in decimal!!!!
%Example: data(10) = 70
%char(data(10)) = F         Look at ASCII table, Dec 70 = F
%This is where the fun begins.  Most of the header information
%can be extracted directly using the decimal values and running
%the char command, however, the Euler angles must be extracted
%and converted into columns of length 4  tthenypecasted to a single
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Now let's get the handle to open the scan file
%This is in decimal!!!!
%Example: data(10) = 70
%char(data(10)) = F         Look at ASCII table, Dec 70 = F

% buffer some chars... hopefully enough
bufferLength = 2^20;

fid  = fopen(file,'rb');
data = transpose(fread( fid,bufferLength,'*uint8',0,'l' ));
fclose(fid);

% do when loading the data

%{
d =  typecast(data(1:32),'uint32');
nx = d(5)
ny = d(6)
n  = d(7)
%}


% we down need the following in mtex
%{

breaks    = find(data == 0);
nextBreak = @(x) breaks(find(breaks >= x,1,'first'));
readChars = @(pos) char(data(pos:nextBreak(pos)-1));

%Let's locate if there is any info the user typed in
%There might be an issue here depending on how long the user types the
%comments.  Will need further testing to see if it breaks the hard-coded
%index locations of the SampleID, Operator, and ScanID

options.info      = readChars(73);
options.operator  = readChars(1096);
options.Sample_ID = readChars(1351);
options.Scan_ID   = readChars(1606);

%This extracts the calibration info
calibration = typecast(data(1861:1876)','single'); % single type
%Here's the final calibration info
x_star = calibration(1);
y_star = calibration(2);
z_star = calibration(3);
working_distance = calibration(4);
%}

headerStart  = hex2dec({'B9','0B','EF','FF','01','00','00','00'})';
headerStop   = hex2dec({'B9','0B','EF','FF','02','00','00','00'})';

headerStart  = strfind(data,headerStart);
headerStop   = strfind(data,headerStop)-1;

headerBytes = data(headerStart+8:headerStop);

osc_phases = file2cell([mtex_path filesep 'interfaces' filesep 'osc_phases.txt']);
nPhase=0;
for i=1:length(osc_phases)
  phaseLoc=strfind(lower(char(headerBytes)),[char(0) lower(osc_phases{i}) char(32) char(32) char(32)]);
  if ~isempty(phaseLoc)
    nPhase=nPhase+1;
    PhaseStart(nPhase)=phaseLoc+1;
    PhaseName{nPhase}=osc_phases{i};
  end
end
if nPhase==0
  for i=1:length(osc_phases)
    phaseLoc=strfind(lower(char(headerBytes)),[char(0) lower(osc_phases{i}) char(0)]);
    if ~isempty(phaseLoc)
      nPhase=nPhase+1;
      PhaseStart(nPhase)=phaseLoc+1;
      PhaseName{nPhase}=osc_phases{i};
    end
  end
end
CS = cell(nPhase,1); %if nPhase is zero then interface catches the error

for k = 1:nPhase

  phaseBytes = headerBytes(PhaseStart:PhaseStart+288);

  laueGroup = num2str(typecast(phaseBytes(257:260),'int32'));

  cellBytes = phaseBytes(261:284);
  axLength  = double(typecast(cellBytes(1:12),'single'));
  axAngle   = double(typecast(cellBytes(13:end),'single'))*degree;
  numHKL    = typecast(phaseBytes(285:288),'int32');


  % maybe from ang convention? should ask the vendor ...
  switch laueGroup
    case {'126'}
      laueGroup = '622';
      options = {'X||a'};
    case {'-3m' '32' '3' '62' '6'}
      options = {'X||a'};
    case '2'
      options = {'X||a*'};
      warning('MTEX:unsupportedSymmetry','symmetry not yet supported!')
    case '1'
      options = {'X||a'};
    case '20'
      laueGroup = {'2'};
      options = {'X||a'};
    otherwise
      if any(axAngle ~= pi/2)
        options = {'X||a'};
      else
        options = {''};
      end
  end

  CS{k} = crystalSymmetry(laueGroup,axLength,axAngle,'mineral',PhaseName{k},options{:});

end
