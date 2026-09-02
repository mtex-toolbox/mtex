function display(job,varargin) %#ok<DISPLAY> every MTEX class overloads it
% standard output
%
% A @trueEbsd job is a sequence of maps plus the hops between them, so the
% display is one row per map: what it is called, how big it is, which
% distortion separates it from the next one, how far and which way that hop
% moved it, and what was left over afterwards. The name is the one undistort
% writes the aligned image under, so it is also what to reach for afterwards -
% ebsd.fsdT1 rather than job.undistortedList(4).img. The residual is the
% diagnostic that says whether the registration worked - around a pixel or
% less is a success.

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
  matrix{k,2} = char(list(k).name);
  matrix{k,3} = size2str(list(k).img);
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
  {'' 'name' 'image' 'distortion' 'shift, px' 'residual, px'},...
  '-d','  ','-ic',true);

disp(' ')

% the grid every map was put on, once there is one
if ~isempty(job.resizedList)
  d = job.resizedList(1);
  disp([' common grid: ' size2str(d.img) ' at ' xnum2str(d.dx) ' µm'])
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
% hop k as a length and the signed x and y behind it, in pixels, from
% job.shifts or job.fitError
%
% shifts is a cell of pairShifts arrays - one per distortion model stage,
% the last being the final fit - while fitError is a plain object array.

s = '-';

if k >= numel(job.imgList), return; end   % the reference has no hop

switch what
  case 'shifts'
    if k > numel(job.shifts) || isempty(job.shifts{k}), return; end
    ps = job.shifts{k}(end);
  case 'fitError'
    if k > numel(job.fitError), return; end
    ps = job.fitError(k);
end

if isempty(ps.u), return; end

s = pxStr(meanShift(ps,job.resizedList(k).dx));

end
