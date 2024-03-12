function export_crc(ebsd,pfName)

% Re-number any strange phase numbers (*.ang file error)
ebsd.phaseMap = (0:(length(ebsd.phaseMap)-1))';



%% Re-number any strange phase numbers (*.ang file error)
ebsd.phaseMap = [0:(length(ebsd.phaseMap)-1)]';
%%

%% Re-grid the ebsd grid
% Done to ensure no rounding-off errors in grid values.
% This step is especially necessary when converting from hexagonal to
% square grid types
ebsd = EBSD(ebsd);
stepSize = calcStepSize(ebsd);
ebsd = regrid(ebsd,stepSize);
%%


%% Process *.cpr data
% Define a structure containing the cpr data
if isfield(ebsd.opt,'cprInfo') == 1
end
% Find the first level field names of the structure
headerNames = fieldnames(cprStruct);

%% Interpolate NaNs after changing from hexagonal to square grid types
% From https://au.mathworks.com/matlabcentral/answers/34346-interpolating-nan-s
% After applying the gridify command, grid points in the regular grid that
% do not have a correspondence in the regular grid are set to NaN.
% However, this causes an issue with OI Channel-5 as the software does not
% work with NaNs in the map data.
% This is why interpolation of grid changed map data is necessary.
ebsd.prop.phi1 = interpolateNaNs(ebsd.rotations.phi1);
ebsd.prop.Phi = interpolateNaNs(ebsd.rotations.Phi);
ebsd.prop.phi2 = interpolateNaNs(ebsd.rotations.phi2);

if isfield(ebsd.prop,'fit') == 1
  ebsd.prop.fit = interpolateNaNs(ebsd.prop.fit);
end
if isfield(ebsd.prop,'iq') == 1
  ebsd.prop.iq = interpolateNaNs(ebsd.prop.iq);
end
if isfield(ebsd.prop,'imagequality') == 1
  ebsd.prop.imagequality = interpolateNaNs(ebsd.prop.imagequality);
end
if isfield(ebsd.prop,'ci') == 1
  ebsd.prop.ci = interpolateNaNs(ebsd.prop.ci);
end
if isfield(ebsd.prop,'confidenceindex') == 1
  ebsd.prop.confidenceindex = interpolateNaNs(ebsd.prop.confidenceindex);
end

%% In case of the ANG file format, pre-rotate the ebsd data
if flagOIFormat == false
  rot = rotation.byAxisAngle(zvector,90*degree); % counterclockwise
  ebsd = rotate(ebsd,rot,'keepEuler');
  rot = rotation.byAxisAngle(xvector,180*degree);
  ebsd = rotate(ebsd,rot,'keepXY');
end


%% Interpolate NaNs after changing from hexagonal to square grid types
% From https://au.mathworks.com/matlabcentral/answers/34346-interpolating-nan-s
% After applying the gridify command, grid points in the regular grid that
% do not have a correspondence in the regular grid are set to NaN.
% However, this causes an issue with OI Channel-5 as the software does not
% work with NaNs in the map data.
% This is why interpolation of grid changed map data is necessary.
ebsd.prop.phi1 = interpolateNaNs(ebsd.rotations.phi1);
ebsd.prop.Phi = interpolateNaNs(ebsd.rotations.Phi);
ebsd.prop.phi2 = interpolateNaNs(ebsd.rotations.phi2);

if isfield(ebsd.prop,'fit') == 1
    ebsd.prop.fit = interpolateNaNs(ebsd.prop.fit);
end
if isfield(ebsd.prop,'iq') == 1
    ebsd.prop.iq = interpolateNaNs(ebsd.prop.iq);
end
if isfield(ebsd.prop,'imagequality') == 1
    ebsd.prop.imagequality = interpolateNaNs(ebsd.prop.imagequality);
end
if isfield(ebsd.prop,'ci') == 1
    ebsd.prop.ci = interpolateNaNs(ebsd.prop.ci);
end
if isfield(ebsd.prop,'confidenceindex') == 1
    ebsd.prop.confidenceindex = interpolateNaNs(ebsd.prop.confidenceindex);
end
%%


%% In case of the ANG file format, pre-rotate the ebsd data
if flagOIFormat == false
    rot = rotation.byAxisAngle(zvector,90*degree); % counterclockwise
    ebsd = rotate(ebsd,rot,'keepEuler');
    rot = rotation.byAxisAngle(xvector,180*degree);
    ebsd = rotate(ebsd,rot,'keepXY');
end
%%


%% Process *.crc data
% Column-wise list of fields in a *.crc file
% C1 = phaseIndex;
% C2 = Euler1; C3 = Euler2; C4 = Euler3;
% C5 = MAD; C6 = BC; C7 = BS;
% C8 = Number of bands; C9 = Error;
% C10 = is or is not indexed;
% C11...Cx = edsWindow_1... edsWindow_x
% classType = {'int8' 'single' 'single' 'single' 'single' 'int8' 'int8' 'int8' 'int8' 'single' 'single' ... 'single'};
% byteLength = [1 4 4 4 4 1 1 1 1 4 4 ... 4];

% In case the ebsd variable only contains indexed data, use the gridified
% version of ebsd variable
ebsdGrid = ebsd.gridify;

% Transpose row & column data first
% Then flip column data from left-to-right


%% C5 = MAD
if flagOIFormat && isfield(ebsdGrid.prop,'mad') == 1
    grid.mad = fliplr(ebsdGrid.prop.mad.');
elseif isfield(ebsdGrid.prop,'fit') == 1
    grid.mad = fliplr(ebsdGrid.prop.fit.');
else
    grid.mad = zeros(size(fliplr(ebsdGrid.isIndexed.')));
end


%% C6 = BC
if flagOIFormat && isfield(ebsdGrid.prop,'bc') == 1
    grid.bc = fliplr(ebsdGrid.prop.bc.');
elseif isfield(ebsdGrid.prop,'iq') == 1
    iq = round(255 * mat2gray(ebsdGrid.prop.iq));
    grid.bc = fliplr(iq.');
elseif isfield(ebsdGrid.prop,'imagequality') == 1
    imagequality = round(255 * mat2gray(ebsdGrid.prop.imagequality));
    grid.bc = fliplr(imagequality.');
else
    grid.bc = zeros(size(fliplr(ebsdGrid.isIndexed.')));
end


%% C7 = BS
if flagOIFormat && isfield(ebsdGrid.prop,'bs') == 1
    grid.bs = fliplr(ebsdGrid.prop.bs.');
    ci = round(255 * mat2gray(ebsdGrid.prop.ci));
    grid.bs = fliplr(ci.');
elseif isfield(ebsdGrid.prop,'confidenceindex') == 1
    confidenceindex = round(255 * mat2gray(ebsdGrid.prop.confidenceindex));
    grid.bs = fliplr(confidenceindex.');
else
    grid.bs = zeros(size(fliplr(ebsdGrid.isIndexed.')));
end

%% C8 = Number of bands
if flagOIFormat && isfield(ebsdGrid.prop,'bands') == 1
    grid.bands = fliplr(ebsdGrid.prop.bands.');
else
    numBands = 6 * ones(size(ebsdGrid.isIndexed)); % assign the OI minimum of 6 bands to indexed points
    numBands(ebsdGrid.isIndexed == 0) = 1; % assign zero bands to zero solution points
    grid.bands = fliplr(numBands.');
end

%% C9 = Error
if flagOIFormat && isfield(ebsdGrid.prop,'error') == 1
    grid.error = fliplr(ebsdGrid.prop.error.');
else
    grid.error = zeros(size(fliplr(ebsdGrid.isIndexed.')));
end


%% C10 = is or is not indexed
% As per OI convention: 0 = indexed, 1 = zero solution
grid.isIndexed = fliplr(double(~ebsdGrid.isIndexed).');



%% Organise map information
% Convert into single columns and as per the required data variable
% formats for writing to the *.crc file
% classType = {'int8' 'single' 'single' 'single' 'single' 'int8' 'int8' 'int8' 'int8' 'single' 'single' ... 'single'};
% byteLength = [1 4 4 4 4 1 1 1 1 4 4 ... 4];
ebsdData{1} = uint8(grid.phase(:));
ebsdData{2} = single(grid.phi1(:));
ebsdData{3} = single(grid.Phi(:));
ebsdData{4} = single(grid.phi2(:));
ebsdData{5} = single(grid.mad(:));
ebsdData{6} = uint8(grid.bc(:));
ebsdData{7} = uint8(grid.bs(:));
ebsdData{8} = uint8(grid.bands(:));
ebsdData{9} = uint8(grid.error(:));
ebsdData{10} = single(grid.isIndexed(:));


%% Find the classes of the column data
for ii = 1:length(ebsdData)
    classType{ii} = class(ebsdData{ii});
end
%%


%% Define the total number of data records to write
data2Write = length(ebsdData{1})*length(classType);

%% Write *.cpr file
cprName = fullfile(filePath,[fileName '.cpr']);
fid = fopen(cprName,'W');

for ii=1:length(headerNames)

end
% Close the *.cpr file
fclose(fid);

%% Write *.crc file
crcName = fullfile(filePath,[fileName '.crc']);
fid = fopen(crcName,'W');

% Write individual data records to the *.crc file
for ii=1:length(ebsdData{1})

    end
  end
end
% Close the *.crc file
fclose(fid);

end

%% Calculate the ebsd map step size
function stepSize = calcStepSize(inebsd)

xx = [inebsd.unitCell(:,1);inebsd.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
yy = [inebsd.unitCell(:,2);inebsd.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
unitPixelArea = polyarea(xx,yy);
if size(inebsd.unitCell,1) == 6 % hexGrid
  stepSize = sqrt(unitPixelArea/sind(60));
else % squareGrid
  stepSize = sqrt(unitPixelArea);
end
end


end



%% Interpolate NaNs
% From https://au.mathworks.com/matlabcentral/answers/34346-interpolating-nan-s
function out = interpolateNaNs(in)
in_notNaN = ~isnan(in);
inLength = (1:numel(in)).';
pp = interp1(inLength(in_notNaN),in(in_notNaN),'linear','pp');
out = fnval(pp,inLength);
% plot(iLength,in,'ko',iLength,out,'b-');
% box on; grid on;
end


%% Calculate the ebsd map step size
function stepSize = calcStepSize(inebsd)
xx = [inebsd.unitCell(:,1);inebsd.unitCell(1,1)]; % repeat the 1st x co-ordinate to close the unit pixel shape
yy = [inebsd.unitCell(:,2);inebsd.unitCell(1,2)]; % repeat the 1st y co-ordinate to close the unit pixel shape
unitPixelArea = polyarea(xx,yy);
if size(inebsd.unitCell,1) == 6 % hexGrid
    stepSize = sqrt(unitPixelArea/sind(60));
else % squareGrid
    stepSize = sqrt(unitPixelArea);
end
end
%%



%% Regrid the ebsd data
function outebsd = regrid(inebsd,stepSize)
% Re-calculating the grid values as multiples of the calculated step size
% this step mitigates any rounding-off errors during subsequent gridding
% operations
outebsd = inebsd;
outebsd.prop.x = stepSize.*floor(outebsd.prop.x./stepSize);
outebsd.prop.y = stepSize.*floor(outebsd.prop.y./stepSize);
end



%% Interpolate NaNs
% From https://au.mathworks.com/matlabcentral/answers/34346-interpolating-nan-s
function out = interpolateNaNs(in)
in_notNaN = ~isnan(in);
inLength = (1:numel(in)).';
pp = interp1(inLength(in_notNaN),in(in_notNaN),'linear','pp');
out = fnval(pp,inLength);
% plot(iLength,in,'ko',iLength,out,'b-');
% box on; grid on;
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
