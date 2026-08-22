function display(mg,varargin) %#ok<DISPLAY> every MTEX class overloads it
% standard output
%
% A @mapImage is almost always held as a sequence, so this is a table of the
% sequence rather than a dump of one object: how big each image is, how big
% its pixels are, which frame it is expressed in and which layout its array
% is stored in. Two entries are comparable pixel by pixel only where the
% layouts agree, so that column is the quick check that alignment worked.

displayClass(mg,inputname(1),varargin{:},'moreInfo',frameInfo(mg));

if isempty(mg), disp('  empty'); disp(' '); return; end

disp(' ')

matrix = cell(numel(mg),7);

for n = 1:numel(mg)

  m = mg(n);

  matrix{n,1} = int2str(n);
  matrix{n,2} = sizeStr(m.img);
  matrix{n,3} = pixelStr(m);
  matrix{n,4} = frameStr(m.frame);
  matrix{n,5} = frameStr(arrayFrameOf(m));
  matrix{n,6} = char(m.name);
  matrix{n,7} = ebsdStr(m.ebsd);

end

cprintf(matrix,'-L',' ','-Lc',...
  {'' 'image' 'pixel' 'frame' 'layout' 'name' 'EBSD'},...
  '-d','  ','-ic',true);

disp(' ')

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

% =========================================================================
function s = pixelStr(m)
% one number for a square pixel, two only for a genuinely rectangular one
%
% A relative tolerance, not equality: an entry built on a map takes its steps
% from the measured d1 and d2, which differ in the last few digits, so
% testing dy == dx reports every real map as rectangular and prints the same
% number twice. A cell that is actually rectangular differs by percent.

if isempty(m.img), s = '-'; return; end

dx = m.dx; dy = m.dy;

if dx == 0 || isnan(dx), s = '-'; return; end

% um rather than the symbol - MTEX gates its special characters on a
% preference and there is none for microns, and this is what scanUnit says
if isnan(dy) || abs(dy-dx) <= 1e-3*max(abs(dx),abs(dy))
  s = [xnum2str(dx) ' um'];
else
  s = [xnum2str(dx) ' x ' xnum2str(dy) ' um'];
end

end

% =========================================================================
function iF = arrayFrameOf(m)
% the layout, or nothing when there is no grid to have one

if isempty(m.img) || isempty(m.frame), iF = imageFrame.empty; return; end
iF = m.arrayFrame;

end

% =========================================================================
function s = frameStr(fr)
% the frame in its own axes names
%
% conventionChar writes a convention in the axes names of the frame it
% belongs to, so each kind of entry states itself in its own terms. An entry
% carrying a map is in a @specimenFrame, whose axes are X, Y, Z, so it reads
% 'y↓→x'; a layout is an @imageFrame, whose axes are col and row, so it reads
% 'row↓→col', or 'row←col↓' a quarter turn from that.

if isempty(fr), s = '-'; return; end

s = conventionChar(fr);

% a frame with no convention, or whose axes are off the screen axes
if isempty(s), s = char(fr); end

end

% =========================================================================
function s = ebsdStr(ebsd)
% the minerals the payload carries, or nothing if there is no payload

if isempty(ebsd) || isempty(ebsd.pos), s = '-'; return; end

mins = {};
for k = 1:numel(ebsd.CSList)
  cs = ebsd.CSList(k);
  if isa(cs,'crystalSymmetry'), mins{end+1} = char(cs.mineral); end %#ok<AGROW>
end

if isempty(mins), s = class(ebsd); else, s = strjoin(mins,', '); end

end

% =========================================================================
function s = frameInfo(mg)
% the plotting convention of the sequence, when they agree on one

s = '';
if isempty(mg) || isempty(mg(1).frame), return; end

pC = mg(1).how2plot;
for n = 2:numel(mg)
  if isempty(mg(n).frame) || ~isapprox(mg(n).how2plot,pC), return; end
end

s = char(pC);

end
