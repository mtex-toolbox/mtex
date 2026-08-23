function display(job,varargin) %#ok<DISPLAY> every MTEX class overloads it
% standard output
%
% A @trueEbsd job is a sequence of maps plus the hops between them, so the
% display is one row per map: what it is called, how big it is, which
% distortion separates it from the next one, how far that hop moved it, and
% what was left over afterwards. The name is the one undistort writes the
% aligned image under, so it is also what to reach for afterwards -
% ebsd.fsdT1 rather than job.undistortedList(4).img. The residual is the diagnostic that says whether the
% registration worked - around a pixel or less is a success.

displayClass(job,inputname(1),varargin{:},'moreInfo',stageStr(job));

n = numel(job.imgList);
if n == 0, disp('  no maps here!'); disp(' '); return; end

disp(' ')

% the most advanced version of each map, so the table describes the job as
% it stands rather than as it was imported
list = job.imgList;
if ~isempty(job.undistortedList)
  list = job.undistortedList;
elseif ~isempty(job.resizedList)
  list = job.resizedList;
end

matrix = cell(n,6);

for k = 1:n

  matrix{k,1} = int2str(k);
  matrix{k,2} = nameStr(list(k),k);
  matrix{k,3} = sizeStr(list(k).img);
  % the hop's transform, not a name on the image - the reference has none
  if k <= numel(job.T)
    matrix{k,4} = shortChar(job.T(k));
  else
    matrix{k,4} = '';
  end

  % hop k joins map k to map k+1, so the last map has none
  matrix{k,5} = hopStr(job,k,'shifts');
  matrix{k,6} = hopStr(job,k,'fitError');

end

cprintf(matrix,'-L',' ','-Lc',...
  {'' 'name' 'image' 'distortion' 'shift' 'residual'},...
  '-d','  ','-ic',true);

disp(' ')

% the grid every map was put on, once there is one
if ~isempty(job.resizedList)
  d = job.resizedList(1);
  disp([' common grid: ' sizeStr(d.img) ' at ' xnum2str(d.dx) ' µm'])
  disp(' ')
end

end

% =========================================================================
function s = stageStr(job)
% how far through the workflow this job is

if isempty(job.imgList)
  s = 'empty';
elseif ~isempty(job.undistortedList)
  s = 'undistorted';
elseif ~isempty(job.shifts)
  s = 'shifts calculated';
elseif ~isempty(job.resizedList)
  s = 'pixel size matched';
else
  s = 'as imported';
end

end

% =========================================================================
function s = hopStr(job,k,what)
% mean length of hop k, in pixels, from job.shifts or job.fitError
%
% shifts is a cell of pairShifts arrays - one per distortion model stage,
% the last being the final fit - while fitError is a plain object array.

s = '-';

if k >= numel(job.imgList), return; end   % the reference has no hop

switch what
  case 'shifts'
    if isempty(job.shifts) || ~iscell(job.shifts) || k > numel(job.shifts), return; end
    ps = job.shifts{k};
    if isempty(ps), return; end
    ps = ps(end);
    x = ps.xShiftsMap; y = ps.yShiftsMap;
  case 'fitError'
    if isempty(job.fitError) || k > numel(job.fitError), return; end
    ps = job.fitError(k);
    x = ps.xShiftsXcf; y = ps.yShiftsXcf;
end

if isempty(x) || isempty(ps.dx) || isempty(ps.dy), return; end

len = sqrt((x(:)./ps.dx).^2 + (y(:)./ps.dy).^2);
len = len(~isnan(len));
if isempty(len), return; end

s = [xnum2str(mean(len)) ' px'];

end

% =========================================================================
function s = nameStr(mg,k)
% what the aligned image will be called, which is what undistort writes it
% under. An unnamed entry falls back to img<k>, as undistort does, so the
% table says what to reach for either way

if isempty(mg.name)
  s = sprintf('img%d',k);
else
  s = char(mg.name);
end

end

% =========================================================================
function s = sizeStr(img)
% r x c, with the channel count only when there is more than one

if isempty(img), s = '-'; return; end
sz = size(img);
if numel(sz) > 2 && sz(3) > 1
  s = sprintf('%d x %d x %d',sz(1),sz(2),sz(3));
else
  s = sprintf('%d x %d',sz(1),sz(2));
end

end
