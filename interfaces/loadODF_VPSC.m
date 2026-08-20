function [odf,options] = loadODF_VPSC(fname,varargin)
% import a VPSC texture file
%
% Syntax
%   odf = loadODF_VPSC('TEX_PH1.OUT','cs',cs)
%   odf = loadODF_VPSC('TEX_PH1.OUT','cs',cs,'halfwidth',10*degree)
%
% Input
%  fname - name of the VPSC texture file
%
% Output
%  odf - @SO3Fun, or a cell array of @SO3Fun if the file holds more than one
%        deformation step
%
% Description
% A VPSC texture file consists of one or more blocks of four header lines
% followed by one line per orientation. The only line the format guarantees
% is the fourth: it carries the Euler angle convention - |B| for Bunge, |K|
% for Kocks, |R| for Roe - and the number of orientations in the block. The
% marker |TEXTURE AT STRAIN| that VPSC writes on the first line of an output
% file is absent from the weight (|.wts|) files that are fed into VPSC, so
% it is not what identifies the format here.
%
% Every block becomes one ODF. The strain, the phase ellipsoid and the
% orientations themselves are kept in |odf.opt|, together with any further
% columns the file may carry (von Mises strain and stress, accumulated
% plastic work, Taylor factor).
%
% Note that a VPSC file carries no symmetry, so the crystal symmetry has to
% be passed in.
%
% See also
% SO3Fun/load orientation/export_VPSC SO3Fun/export_VPSC

options = delete_option(varargin,'check');

lines = file2cell(fname);

% locate the convention lines, e.g. "B      1000"
head = regexp(lines,'^\s*([BbKkRr])\s+(\d+)\s*$','tokens','once');
isHead = find(~cellfun(@isempty,head));

% VPSC prescribes exactly three lines ahead of the first convention line -
% requiring that keeps this interface from claiming files that merely happen
% to contain such a line somewhere
assert(~isempty(isHead) && isHead(1) == 4,...
  'Interface VPSC does not fit file format!');

if check_option(varargin,'check')
  odf = ODF;
  return;
end

cs = getClass(varargin,'crystalSymmetry',crystalSymmetry('432'));

odf = cell(1,numel(isHead));

for k = 1:numel(isHead)

  h = isHead(k);
  nOri = str2double(head{h}{2});
  convention = eulerAngleConvention(head{h}{1});

  % the data lines of this block
  block = sprintf('%s\n',lines{h+(1:nOri)});
  d = sscanf(block,'%f');
  nCol = numel(d) / nOri;
  assert(nCol == round(nCol) && nCol >= 4,...
    'VPSC file is corrupted - block %d does not hold %d orientations.',k,nOri);
  d = reshape(d,nCol,nOri).';

  ori = orientation.byEuler(d(:,1:3) * degree,convention,cs);
  weights = d(:,4);

  odf{k} = calcDensity(ori,'weights',weights,varargin{:});

  % the three lines above the convention line: the strain, and the length
  % and the orientation of the phase ellipsoid axes. They are free format -
  % a weight file written by hand carries comments here instead - so read
  % what is there and report NaN for the rest
  strain = regexp(lines{h-3},'STRAIN\s*=?\s*([-+.0-9eEdD]+)','tokens','once');
  if isempty(strain)
    odf{k}.opt.strain = NaN;
  else
    odf{k}.opt.strain = str2double(strain{1});
  end
  odf{k}.opt.strainEllipsoid = readNumbers(lines{h-2},3);
  odf{k}.opt.strainEllipsoidAngles = readNumbers(lines{h-1},3);

  % also store data (individual orientations, ellipsoids, Taylor factors)
  odf{k}.opt.orientations = ori;
  odf{k}.opt.data = d(:,5:end);

end

if numel(odf) == 1, odf = odf{1}; end

end

% ---------------------------------------------------------------------------
function convention = eulerAngleConvention(letter)
% the fourth header line names the Euler angle convention of the file

switch upper(letter)
  case 'B', convention = 'Bunge';
  case 'K', convention = 'Kocks';
  case 'R', convention = 'Roe';
end

end

% ---------------------------------------------------------------------------
function num = readNumbers(line,n)
% the leading numbers of a free format header line, padded with NaN

num = sscanf(regexprep(line,'^[^0-9+\-.]*',''),'%f',n).';

num = [num, NaN(1,n-numel(num))];

end
