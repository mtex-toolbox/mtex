function export_crc(ebsd,pfName)
%% Function description:
% Export EBSD map orientation data from Mtex to proprietary
% Oxford Instruments HKL Channel 5 *.cpr and *.crc file format.
% Version 1.0 - Published 08/08/2020

% Dr Azdiar Gazder, University of Wollongong, Australia
% azdiarnospam@uow.edu.au (delete "nospam" for a valid email address)
% Dr Frank Niessen, Technical University of Denmark, Denmark
% contactnospam@fniessen.com  (delete "nospam" for a valid email address)

%% Acknowledgements:
% Dr Mark Pearce, CSIRO Mineral Resources, Australia

%% Syntax:
% export_ctf(ebsd,fileName)

%% General notes:
% 1. In Mtex's "loadEBSD_CRC" code, any EDS data contained in the original
% cpr/crc file needs to be imported and the elemental windows defined.

% 2. Consequently, this code does not account for EDS data in the ebsd variable.
% If/when point (1) is implemented in Mtex, a check could be introduced
% to see if "ebsd.opt.cprData.edxwindows.count" is zero or not. If it is not
% zero, then that many number of columns should be defined in the "ebsdData"
% variable in the "Process *.crc file" part of the code.
%%

screenPrint('SegmentStart','Export ebsd data to *.cpr/crc files');

%% Process the input data
tic
screenPrint('Step','Process ebsd data before writing to files');
%% Define the file path, name and extension
[filePath,fileName,fileExt] = fileparts(pfName);
%%

%% Process *.cpr data
% Define a structure containing the cpr data
cprStruct = ebsd.opt.cprInfo;
% Find the first level field names of the structure
headerNames = fieldnames(cprStruct);
%%


%% Process *.crc data
% Column-wise list of fields in a *.crc file
% C1 = phaseIndex;
% C2 = Euler1; C3 = Euler2; C4 = Euler3
% C5 = MAD; C6 = BC; C7 = BS;
% C8 = Number of bands; C9 = Error;
% C10 = is or is not indexed
% As per OI convention: 0 = indexed, 1 = zero solution
% So the "reliabilityIndex" column data is used in C10
% C11...Cx = edsWindow_1... edsWindow_x
% classType = {'int8' 'single' 'single' 'single' 'single' 'int8' 'int8' 'int8' 'int8' 'single' 'single' ... 'single'};
% byteLength = [1 4 4 4 4 1 1 1 1 4 4 ... 4];

% In case the ebsd variable only contains indexed data, use the gridified
% version of ebsd variable
ebsdGrid = ebsd.gridify;

% Transpose row & column data first
% Then flip column data from left-to-right
grid.phase = fliplr(ebsdGrid.phase.');
grid.phi1 = fliplr(ebsdGrid.rotations.phi1.');
grid.Phi = fliplr(ebsdGrid.rotations.Phi.');
grid.phi2 = fliplr(ebsdGrid.rotations.phi2.');
grid.mad = fliplr(ebsdGrid.prop.mad.');
grid.bc = fliplr(ebsdGrid.prop.bc.');
grid.bs = fliplr(ebsdGrid.prop.bs.');
grid.bands = fliplr(ebsdGrid.prop.bands.');
grid.error = fliplr(ebsdGrid.prop.error.');
grid.reliabilityindex = fliplr(ebsdGrid.prop.reliabilityindex.');

% Organise map information into single columns and as per
% the required data formats for writing the *.crc file
ebsdData{1} = uint8(grid.phase(:));
ebsdData{2} = single(grid.phi1(:));
ebsdData{3} = single(grid.Phi(:));
ebsdData{4} = single(grid.phi2(:));
ebsdData{5} = single(grid.mad(:));
ebsdData{6} = uint8(grid.bc(:));
ebsdData{7} = uint8(grid.bs(:));
ebsdData{8} = uint8(grid.bands(:));
ebsdData{9} = uint8(grid.error(:));
ebsdData{10} = single(grid.reliabilityindex(:));

% Find the classes of the column data
for ii = 1:length(ebsdData)
    classType{ii} = class(ebsdData{ii});
end

% Define the total number of data records to write
data2Write = length(ebsdData{1})*length(classType);
toc
%%



%% Write *.cpr file
tic
screenPrint('Step','Start writing *.cpr file');
cprName = fullfile(filePath,[fileName '.cpr']);
fid = fopen(cprName,'W');

for ii=1:length(headerNames)
  % Upper case the first alphabet of first level field names & convert to
  % a string
  % headerString = [upper(headerNames{ii}(1)), headerNames{ii}(2:end)];
  headerString = strrep(headerNames{ii},'_',' ');
  % Write the first level field name of the structure as a string into the file
  fwrite(fid,['[',headerString,']']);
  % Write a carriage return for a new line into the file
  fwrite(fid,sprintf('\n'));
  
  % Check if the first level field name is a nested structure
  if isstruct(eval(['cprStruct.' headerNames{ii}]))
    % Find the second level field names of the structure
    subheaderNames = fieldnames(eval(['cprStruct.' headerNames{ii}]));
    for jj=1:length(subheaderNames)
      % Upper case the first alphabet of second level field names & convert to
      % a string
      % subheaderString = [upper(subheaderNames{jj}(1)), subheaderNames{jj}(2:end)];
      subheaderString = strrep(subheaderNames{jj},'_',' ');
      
      % Check if the second level field contains a string value
      subheaderValue_isString = eval(['ischar(','cprStruct.' headerNames{ii} '.' subheaderNames{jj},')']);
      % Check if the second level field contains a numeric value
      subheaderValue_isNumeric = eval(['isnumeric(','cprStruct.' headerNames{ii} '.' subheaderNames{jj},')']);
      % Define the second level field value as a string
      if(subheaderValue_isString)
        subheaderValue = eval(['cprStruct.' headerNames{ii} '.' subheaderNames{jj}]);
        subheaderValue = strrep(subheaderValue,'_',' ');
      end
      if(subheaderValue_isNumeric)
        subheaderValue = eval(['num2str(','cprStruct.' headerNames{ii} '.' subheaderNames{jj},')']);
      end
      % Write the second level field name of the structure & its value as strings into the file
      fwrite(fid,[subheaderString,'=',subheaderValue]);
      % Write a carriage return for a new line into the file
      fwrite(fid,sprintf('\n'));
    end
  end
  progress(ii,length(headerNames));
end
%Close *.cpr file
fclose(fid);
screenPrint('Step','End writing *.cpr file');
toc
%%



%% Write *.crc file
tic
screenPrint('Step','Start writing *.crc file');
crcName = fullfile(filePath,[fileName '.crc']);
fid = fopen(crcName,'W');

% Write individual data records to the *.crc file
for ii=1:length(ebsdData{1})
    for jj = 1:length(classType)
        % Write data to file with the appropriate number of bits
        fwrite(fid, ebsdData{jj}(ii), ['*' classType{jj}]);
        
        % Update progress at intervals
        if mod(jj+((ii-1)*length(classType)),data2Write/20) == 0
            progress(ii,length(ebsdData{1}));
        end
    end
end
% Close *.crc file
fclose(fid);
screenPrint('Step','End writing *.crc file');
toc

screenPrint('SegmentEnd','Export ebsd data to *.cpr/crc files complete');
end
%%



%% *** Function screenPrint - Print to command window
function screenPrint(mode,varargin)
%function screenPrint(mode,varargin)
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
    case 'SegmentEnd'
        titleStr = varargin{1};
        fprintf([' -> ',titleStr,'\n']);
        fprintf('------------------------------------------------------\n');
end
end
%%


%% MIT License
% Copyright (c) 2020 Azdiar Gazder, Frank Niessen
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
%%