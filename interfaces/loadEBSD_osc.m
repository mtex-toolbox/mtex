function ebsd = loadEBSD_osc(fname,varargin)
%
% Options
%  headerOnly - return only phase/header metadata, skip reading the data
%  debugPhases - print every candidate phase record found/rejected and why

assertExtension(fname,'.osc');

[CSdefault,header] = oscHeader(fname,check_option(varargin,'debugPhases'));
CS = get_option(varargin,'CS',CSdefault);

if check_option(varargin,'headerOnly')
  ebsd = emptyHeaderOnlyEBSD(CS,header);
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
unitCell = vector3d(unitCell(:,1),unitCell(:,2),0);

pos = loader.getPos;
rot = loader.getRotations;
phase = loader.getColumnData('phase');
ebsd = EBSD(pos,rot,phase,CS,loader.getOptions, 'unitCell',unitCell);
ebsd.opt.header = header;

ebsd = applyEulerCorrectionTable(ebsd,'.osc',varargin{:});




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
function [CS,header] = oscHeader(file,debugPhases)
if nargin < 2, debugPhases = false; end
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


% named fields at reverse-engineered byte offsets, so a failure to decode is not fatal
header = struct();
try
  breaks    = find(data == 0);
  nextBreak = @(x) breaks(find(breaks >= x,1,'first'));
  readChars = @(pos) strtrim(char(data(pos:nextBreak(pos)-1)));

  %Let's locate if there is any info the user typed in
  %There might be an issue here depending on how long the user types the
  %comments.  Will need further testing to see if it breaks the hard-coded
  %index locations of the SampleID, Operator, and ScanID

  header.info      = readChars(73);
  header.operator  = readChars(1096);
  header.Sample_ID = readChars(1351);
  header.Scan_ID   = readChars(1606);

  %This extracts the calibration info
  calibration = double(typecast(data(1861:1876)','single')); % single type
  %Here's the final calibration info
  header.x_star           = calibration(1);
  header.y_star           = calibration(2);
  header.z_star           = calibration(3);
  header.working_distance = calibration(4);
catch
end

headerStart  = hex2dec({'B9','0B','EF','FF','01','00','00','00'})';
headerStop   = hex2dec({'B9','0B','EF','FF','02','00','00','00'})';

headerStart  = strfind(data,headerStart);
headerStop   = strfind(data,headerStop)-1;

headerBytes = data(headerStart+8:headerStop);

% keep the raw bytes, the rest of the header is not self describing
header.rawBytes = headerBytes;

% one record per phase, in the order the file numbers them.
% Each record is NOT a fixed 288 bytes long: after the fixed-size name/
% symmetry/cell block, it carries numHKL hklFamily entries (variable
% count) plus a formula/name tail, so records must be advanced by their
% own true length or the scan drifts off alignment after the first phase.
CS = repmat(notIndexed,1,0);
o = 1;
while o + 287 <= numel(headerBytes)
  [cs,recLen,reason,symCode] = phaseRecord(headerBytes,o);
  if isempty(cs)
    if debugPhases && ~strcmp(reason,'no name')
      fprintf('oscHeader: rejected candidate at byte %d (%s)\n',o,reason);
    end
    o = o + 1;
  else
    if debugPhases
      try
        pgStr = char(cs.pointGroup);
      catch
        pgStr = '?';
      end
      fprintf('oscHeader: accepted phase "%s" at byte %d, symCode=%d, resolved symmetry=%s, record length=%d\n',...
        cs.mineral,o,symCode,pgStr,recLen);
    end
    CS(end+1) = cs; %#ok<AGROW>
    o = o + recLen;
  end
end

function [cs,recLen,reason,symCode] = phaseRecord(bytes,pos)
% the phase a record at pos describes: a name that reads as one, a symmetry
% code and a cell the crystal symmetry accepts; empty where the bytes are none
cs = [];
recLen = 288;
reason = 'no name';
symCode = [];
field = bytes(pos:pos+255);
stop = find(field == 0,1);
if isempty(stop), stop = 257; end
field = field(1:stop-1);
if isempty(field) || any(field < 32 | field > 126) || ~any(isletter(char(field))), return; end

% symCode is a single 4-byte field that TSL/EDAX overload two ways: a
% small value (1..43) is a "Symmetry" code naming one of 11 Laue classes,
% a value >=100 (100..131) is an EDAX PointGroupID naming one of the 32
% point groups directly (131 = m-3m, the code cubic phases report). See
% symCodeToGroup below for the full table; it mirrors MTEX's own
% interfaces/tools/TSL2pointGroup.m, reproduced here in case that
% function isn't on the path for a given MTEX install.
symCode = typecast(bytes(pos+256:pos+259),'int32');
cellBytes = double(typecast(bytes(pos+260:pos+283),'single'));
if ~(all(cellBytes(1:3) > 0 & cellBytes(1:3) < 1000) && ...
    all(cellBytes(4:6) > 0 & cellBytes(4:6) < 180))
  reason = 'cell constants out of range';
  return
end
if pos+287 > numel(bytes)
  reason = 'truncated record';
  return
end
numHKL = double(typecast(bytes(pos+284:pos+287),'int32'));
if numHKL < 0 || numHKL > 10000
  reason = 'numHKL out of range';
  return
end

laueGroup = symCodeToGroup(symCode);
if isempty(laueGroup)
  reason = sprintf('unrecognized symmetry code %d',symCode);
  return
end

% trigonal/hexagonal/monoclinic groups need an explicit crystal-axis
% alignment; MTEX's own loadEBSD_osc.m uses 'X||a' for all of these
% (cubic, tetragonal and orthorhombic groups are unambiguous without it)
switch laueGroup
  case {'2','m','2/m',...
      '3','-3','32','3m','-3m',...
      '6','-6','6/m','622','6mm','-62m','6/mmm'}
    options = {'X||a'};
  otherwise
    options = {''};
end

try
  % the crystal reference frame follows the EDAX convention, as for .ang files
  if exist('TSL2pointGroup','file')
    % prefer MTEX's own resolver when it is on the path - it also cross
    % -checks against an EDAX PointGroupID when one is available and
    % falls back to the Laue class alone otherwise
    resolved = TSL2pointGroup(double(symCode));
    if ~isempty(resolved), laueGroup = resolved; end
  end
  cs = crystalSymmetry(laueGroup,cellBytes(1:3),cellBytes(4:6)*degree, ...
    'mineral',strtrim(char(field)),options{:});
catch err
  cs = [];
  reason = ['crystalSymmetry failed: ' err.message];
  return
end

% each hklFamily entry is 4 ints + 1 single = 20 bytes (matching TSL's osc
% layout); the record also carries a trailing formula/name block, so keep
% the original fixed 288-byte block only as a floor when numHKL is 0
recLen = max(288, 288 + numHKL*20);

function pointGroup = symCodeToGroup(symCode)
% .osc stores ONE numeric field per phase that is overloaded two ways,
% matching MTEX's own TSL2pointGroup.m (interfaces/tools/TSL2pointGroup.m):
%
%  - a value 1..43 is a TSL "Symmetry" code naming one of the 11 Laue
%    classes (NOT a point-group symbol directly - code 3 is the Laue
%    class "-3", not the point group "3"):
%      '-1',1  '2/m',20 (or plain '2' on older files)  'mmm',22
%      '4/m',4  '4/mmm',42  '-3',3  '-3m',32  '6/m',6  '6/mmm',62
%      'm-3',23  'm-3m',43
%  - a value 100..131 is an EDAX PointGroupID, 100 + position in the 32
%    crystallographic point groups in this order:
%      1,-1,2,m,2/m,222,mm2,mmm, 4,-4,4/m,422,4mm,-42m,4/mmm,
%      3,-3,32,3m,-3m, 6,-6,6/m,622,6mm,-62m,6/mmm, 23,m-3,432,-43m,m-3m
%    so 131 (100+31) is the last entry, m-3m - exactly what a cubic
%    ferrite/austenite phase reports.
persistent laueCodes laueNames pgList
if isempty(laueCodes)
  laueNames = {'-1','2/m','mmm','4/m','4/mmm','-3','-3m','6/m','6/mmm','m-3','m-3m'};
  laueCodes = [1,20,22,4,42,3,32,6,62,23,43];
  pgList = {'1','-1','2','m','2/m','222','mm2','mmm',...
    '4','-4','4/m','422','4mm','-42m','4/mmm',...
    '3','-3','32','3m','-3m',...
    '6','-6','6/m','622','6mm','-62m','6/mmm',...
    '23','m-3','432','-43m','m-3m'};
end
code = double(symCode);
pointGroup = '';
if code >= 100 && code <= 99+numel(pgList)
  pointGroup = pgList{code-99};
  return
end
if code == 2, code = 20; end
i = find(laueCodes == code,1);
if ~isempty(i)
  pointGroup = laueNames{i};
end
