function pf = loadPoleFigure_xrdml(fname,varargin)
% load xrdMeasurement (xrdml) file
%
% Syntax
%   pf = loadPoleFigure_xrdml(fname)
%
% Input
%  fname - file name
%
% Output
%  pf    - @PoleFigure
%
% See also
% ImportPoleFigureData

assertExtension(fname,'.xml','.xrdml');

try
  doc = xmlread(fname);
catch
  interfaceError(fname);
end

root = doc.getDocumentElement();

if strcmp(char(root.getTagName()),'xrdMeasurements')
  
  xrdMeasurment = root.getElementsByTagName('xrdMeasurement');
  
  for k=1:xrdMeasurment.getLength
    
    [allH{k},allR{k},allI{k}] = localParseMeasurement(xrdMeasurment.item(k-1),varargin{:}); %#ok<AGROW>
    
  end
  
  pf = PoleFigure(allH,allR,allI,varargin{:});
  
else
  
  interfaceError(fname);
  
end

end

function [h,r,d] = localParseMeasurement(measurement,varargin)

% measurement.getElementsByTagName('comment');
scan = measurement.getElementsByTagName('scan');

% extract intensities
for k=1:scan.getLength() 
  data(k) = localParseScan( scan.item(k-1) );  
end
d = vertcat(data.intensities);

% extract specimen directions
r = vertcat(data.r);

% extract Miller indices
hkl = unique(vertcat(data.h),'rows');
h = Miller(hkl(:,1),hkl(:,2),hkl(:,3),crystalSymmetry);

% check for constant 2Theta angle
if numel(unique([data.position_2Theta]))>1
  warning('data may be corrupted, I recognized different 2Theta angles for one measurement')
end

end

function data = localParseScan(scan)

% header = scan.getElementsByTagName('header');
dataPoints = scan.getElementsByTagName('dataPoints').item(0);

data = localParsePositions( dataPoints );

data.commonCountingTime = str2num(...
  dataPoints.getElementsByTagName('commonCountingTime').item(0).getFirstChild.getNodeValue);

try
  data.intensities = str2num(...
    dataPoints.getElementsByTagName('intensities').item(0).getFirstChild.getNodeValue).';
catch
  data.intensities = str2num(...
    dataPoints.getElementsByTagName('counts').item(0).getFirstChild.getNodeValue).';
end

% normalize against measurment time
data.intensities = data.intensities./data.commonCountingTime;

data.h = localParseReflection( scan );
data.r = localConvertScanToSpecimenDirection(data);

end

function hkl = localParseReflection(scan)

reflection = scan.getElementsByTagName('reflection').item(0);

if ~isempty(reflection)
  h = str2num(reflection.getElementsByTagName('h').item(0).getFirstChild.getNodeValue);
  k = str2num(reflection.getElementsByTagName('k').item(0).getFirstChild.getNodeValue);
  l = str2num(reflection.getElementsByTagName('l').item(0).getFirstChild.getNodeValue);
  hkl = [h k l];
else
  hkl = [0,0,1];
end

end

function r = localConvertScanToSpecimenDirection(data)

n = numel(data.intensities);

if isfield(data,'position_Psi')
  x = 'Psi';
else
  x = 'Chi';
end

theta2 = linspace(data.position_2Theta(1),data.position_2Theta(end),n);
omega  = linspace(data.position_Omega(1),data.position_Omega(end),n);
try
  psi    = linspace(data.(['position_' x])(1),data.(['position_' x])(end),n);
  if strcmpi(data.(['position_' x '_unit']),'deg')
    psi = psi*degree;
  end
catch %#ok<CTCH>
  psi = 0;
end
try
  phi    = linspace(data.position_Phi(1),data.position_Phi(end),n);
  if strcmpi(data.position_Phi_unit,'deg')
    phi= phi*degree; 
  end
catch %#ok<CTCH>
  phi = 0;
end

if strcmpi(data.position_2Theta_unit,'deg')
  theta2= theta2*degree; 
end
if strcmpi(data.position_Omega_unit,'deg')
  omega= omega*degree; 
end

q = axis2quat(zvector,phi) .* ...
  axis2quat(yvector,psi)   .* ...
  axis2quat(xvector,omega) .* ...
  axis2quat(xvector,(pi-theta2)/2);

r = q*yvector;

end

function pos = localParsePositions(dataPoints)

positions = dataPoints.getElementsByTagName('positions');

for k = 1:positions.getLength()
  position = positions.item(k-1);
  
  ax   = ['position_' char(position.getAttribute('axis'))];
  unit = char(position.getAttribute('unit'));
  
  commonPosition = position.getElementsByTagName('commonPosition').item(0);
  
  if ~isempty(commonPosition)
    
    val = str2num(commonPosition.getFirstChild.getNodeValue);
    
  else
    startPosition  = position.getElementsByTagName('startPosition').item(0);
    endPosition   = position.getElementsByTagName('endPosition').item(0);
    
    if ~isempty(startPosition) && ~isempty(endPosition)
      val = [str2num(startPosition.getFirstChild.getNodeValue) ...
        str2num(endPosition.getFirstChild.getNodeValue)];
    end
  end
  
  pos.(ax) = val;
  pos.([ax '_unit']) = unit;
  
end

end
