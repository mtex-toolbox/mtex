function job = setOptions(job,varargin)
% set the registration settings, for every hop or for one
%
% These describe how the job should register rather than what an image is,
% which is why they live on the job and not on @mapImage.
%
% Syntax
%
%   job.setOptions('roiSize',5,'numROI',24)   % 5 um tiles on every hop
%   job.setOptions(3,'registerOn','raw')      % hop 3 only
%   job.setOptions(1,'registerOn','edge')     % match hop 1 on edges
%   job.setOptions(1,'roiSize',[4 8])         % per fit stage of hop 1
%
% Input
%  job - @trueEbsd
%  n   - which map the settings apply to, all of them if omitted
%
% Options
%  roiSize      - correlation tile width, a LENGTH in the sequence's
%                 scanUnit. One value, or one per fit stage. Zero means
%                 this map correlates against nothing, as the reference does
%  numROI       - tiles across the image; the number down follows from the
%                 aspect ratio
%  registerOn   - 'edge' to correlate the edge transform, 'raw' for the
%                 values as they are. Not measured: 'edge' is the method's
%                 premise and raw is the exception, for a pair that already
%                 shares contrast - which the person who collected them
%                 knows and no cheap proxy reliably does. See PARAMETERS.md
%  edgeWidth    - neighbour distance of the edge transform, a LENGTH
%  highContrast - whether this image can be registered on directly. true,
%                 false, or 'auto' to measure it
%  pixelTime    - dwell time per pixel, carried but not used
%
% Description
% Lengths, not pixels. A pixel count means a different thing before and
% after pixelSizeMatch, which is what forces a settings block to sit wedged
% between that call and calcDistortion; a length does not, so this may be
% called at any point.
%
% Anything left at 'auto' is measured from a cheap coarse correlation when
% calcDistortion first needs it, and what it chose is printed. Anything set
% here is used untouched and nothing is measured for it.
%
% See also
% trueEbsd trueEbsd/calcDistortion mapImage/edgeMap

% an index may lead, otherwise every map
if ~isempty(varargin) && isnumeric(varargin{1})
  idx = varargin{1};
  varargin(1) = [];
else
  idx = 1:numel(job.imgList);
end

assert(all(idx >= 1 & idx <= numel(job.imgList)),'MTEX:trueEbsd:badIndex',...
  'This job has %d maps, asked for %s.',numel(job.imgList),mat2str(idx));

known = fieldnames(job.opt);

assert(mod(numel(varargin),2) == 0,'MTEX:trueEbsd:badOption',...
  'Options come in name value pairs.');

for k = 1:2:numel(varargin)

  name = varargin{k};
  value = varargin{k+1};

  % match case insensitively, but store under the canonical name
  hit = find(strcmpi(name,known),1);

  assert(~isempty(hit),'MTEX:trueEbsd:unknownOption',...
    'There is no setting called ''%s''. There is: %s.',...
    name,strjoin(known',', '));

  value = checkValue(known{hit},value);

  for n = idx, job.opt(n).(known{hit}) = value; end

end

end

% =========================================================================
function value = checkValue(name,value)
% refuse a value that would only fail much later, inside the correlation

switch name

  case {'roiSize','edgeWidth'}
    if ischar(value) || isstring(value)
      value = lower(char(value));
      assert(strcmp(value,'auto'),'MTEX:trueEbsd:badOption',...
        '%s is a length, or ''auto''. Got ''%s''.',name,value);
    else
      % zero is meaningful for roiSize: the reference correlates against
      % nothing, and autoTune writes the same
      assert(all(value >= 0),'MTEX:trueEbsd:badOption',...
        '%s is a length in the map''s own unit, so it cannot be negative.',name);
    end

  case 'numROI'
    assert(isnumeric(value) && isscalar(value) && value >= 1,...
      'MTEX:trueEbsd:badOption',...
      ['numROI is how many tiles fit across the image, one number - the '...
      'count down follows from the aspect ratio.']);

  case 'registerOn'
    value = lower(char(value));
    assert(any(strcmp(value,{'edge','raw'})),'MTEX:trueEbsd:badOption',...
      'registerOn is ''edge'' or ''raw''. Got ''%s''.',value);

  case 'highContrast'
    if ischar(value) || isstring(value)
      value = lower(char(value));
      assert(strcmp(value,'auto'),'MTEX:trueEbsd:badOption',...
        'highContrast is true, false or ''auto''. Got ''%s''.',value);
    else
      value = logical(value);
    end

end

end
