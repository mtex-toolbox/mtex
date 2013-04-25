function ebsd = loadEBSD_osc(fname,varargin)
%

ebsd = EBSD;

try

  CS = oscHeader(fname);
  
  if check_option(varargin,'check')
    return
  end
  
  [data,Xstep,Ystep] = oscData( fname );
  unitCell = {};  
  
  % there seems to exist different formats
  if numel(unique(data(:,8)))<12
    loader = loadHelper(data,...
      'ColumnNames',{'phi1','Phi','phi2','x','y','ImageQuality','ConfidenceIndex','Phase','SemSignal','Fit'},...
      'Radians');
        
    % grid info should contain the grid type .. todo
    % unitCell = {'unitCell',[ Xstep/2 -Ystep/2;  Xstep/2  Ystep/2;  -Xstep/2  Ystep/2;  -Xstep/2 -Ystep/2]};
  else
    % here we are not sure about correct naming of the columns
    loader = loadHelper(data,...
      'ColumnNames',{'Fit','phi1','Phi','phi2','x','y','ImageQuality','ConfidenceIndex','Phase','SemSignal'},...
      'Radians');
  end
  
  ebsd = EBSD( loader.getRotations(),...
    'cs',      CS,...
    'phase',   loader.getColumnData('phase'),...
    'options', loader.getOptions('ignoreColumns','phase'),...
    unitCell{:});
  
catch
  interfaceError(fname)
end



%% taken from ANYSTITCH
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
%% BSD License:
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

%% Osc2Ang( OscFile )
function [data, Xstep, Ystep] = oscData( file )
%  [RelevantData,Xstep,Ystep ] = Osc2Ang(OscFile) reads the *.osc file
%  whose path is defined by the string OscFile into a variable RelevantData in the matlab workspace.
%  The X and Y step sizes are also extracted.
%
%   The variable RelevantData contains all of the data normally found in
%   an *.ang file
%
%
%% Open the Current Osc for reading as binary
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


%% faster version

% look for a certain pattern
startBytes = hex2dec({'B9','0B','EF','FF','02','00','00','00'});
stopBytes  = hex2dec({'B9','0B','EF','FF','40','00','00','00'});


% open fild
fid = fopen(file,'rb');

% read the first 8 uint32 vals
header = fread(fid,8,'uint32','l');
%{
nx = header(5);
ny = header(6);
%}
n  = header(7);

% default start pos
startPos = 6100;

bufferLength = 2^15;
fseek(fid,startPos,-1);
startData = fread(fid, bufferLength, '*uint8', 'l');
startPos  = startPos + strfind(startData',startBytes') - 1;

fseek(fid,startPos,-1);
data = double(fread(fid,n*10+4,'single','l'));
fclose(fid);

% Collect the values for Xstep and Ystep, from the .osc file
Xstep = data(3);
Ystep = data(4);

% Delete the first four data points because they are no longer used
data(1:4) = [];

% Break the data up into an array that resembles the .ang
% file format being sure to transpose
data = reshape(data,10,n)';


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
bufferLength = 2^16;

fid=fopen(file,'rb');
data = transpose(fread( fid,bufferLength,'*uint8','l' ));
fclose(fid);

% do when loading the data
%{
d =  typecast(data(17:28)','uint32');
nx = d(1);
ny = d(2);
n  = d(3);
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

headerBytes = data(headerStart:headerStop);

% would need a multiface osc data to check this
phaseStartByBytes = hex2dec({'00','00','80','3F','01','00','00','00'})';

phaseStart = strfind(headerBytes,phaseStartByBytes);
phaseStart = [phaseStart;numel(headerBytes)];

for k=1:numel(phaseStart)-1
  
  % bytes used to describe one phase
  phaseBytes = headerBytes(phaseStart(k)+8:phaseStart(k+1));
  % offset relative to phaseBytes
  % [1:256]   for phase
  % [257:260] for symmetrygroup
  % [261:284] for symmetry cell
  % [285:288] num hkl
  % [289:289+3*4*numhkl-1] hkl families int32
  % formula
  % next?
  
  phaseName  = phaseBytes(1:256);
  phaseName  = char(phaseName(1:find(phaseName==0,1,'first')-1));
  
  laueGroup = num2str(typecast(phaseBytes(257:260),'int32'));
  
  startByteCell = 261;
  cellBytes = phaseBytes(startByteCell:startByteCell+6*4-1);
  axLength  = double(typecast(cellBytes(1:12),'single'));
  axAngle   = double(typecast(cellBytes(13:end),'single'))*degree;
  
  %{
  % hklFamilies
  startByteHKL = startByteCell+6*4;
  numHKL       = typecast(phaseBytes(startByteHKL:startByteHKL+3),'int32');
  
  stopByteHKL  = startByteHKL+3*(numHKL)*4-1+4;
  
  hkls = typecast(phaseBytes((startByteHKL+4:stopByteHKL)),'int32');
  hkls = reshape(hkls,3,[])';
  
  % is this a bug in the hkl software when exporing *.ang?
  % hkls((1:numel(hkls))>127) = hkls(127);
  %}
  
  %{
  startByteFormula = stopByteHKL+1;
  stopByteFormula = startByteFormula+...
    find(phaseBytes(startByteFormula:startByteFormula+100)==0,1,'first')-2;
  formula = char(phaseBytes(startByteFormula:stopByteFormula));
  
  
  phaseBytes(startByteFormula:startByteFormula+79);
  
  startByteOther = startByteFormula+80;
  
  otherBytes = phaseBytes(startByteOther:end);
  
   % 5th ang row
  hklrow = typecast(otherBytes(12*numHKL+1:16*numHKL),'int32')';
  % structure factor
  hklrow = typecast(otherBytes(16*numHKL+1:20*numHKL),'single')';
  
  
  % what are the other bytes?
  hklrow = typecast(otherBytes( 4*numHKL+1: 8*numHKL),'int32')';
  hklrow = typecast(otherBytes( 8*numHKL+1:12*numHKL),'int32')';
  hklrow = typecast(otherBytes(20*numHKL+1:24*numHKL),'int32')';
  %}
  
  % maybe from ang convention? should ask the vendor ...
  switch laueGroup
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
      if any(round(axAngle(3)/degree) ~= 90)
        options = {'X||a'};
      else
        options = {};
      end
  end
  
  CS{k} = symmetry(laueGroup,axLength,axAngle,'mineral',phaseName,options{:});

end


