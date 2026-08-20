function exportEBSD_h5(ebsd,fName,varargin)
% export EBSD data to an HDF5 file
%
% Description
%
% There is no such thing as "the" EBSD HDF5 format - every vendor nests its
% data differently and stores far more than MTEX imports, from the raw
% patterns to the acquisition settings. Writing one from scratch therefore
% loses everything MTEX does not model. This function instead takes the
% file the data was imported from as a reference, copies it, and writes the
% changed data into the copy, so the result is still a file of the vendor's
% own format that its software reads.
%
% The reference file is the one the data came from - |EBSD.load| remembers
% it in |ebsd.opt.h5| together with the data sets it read - or one named
% explicitly. Only measurements that are still there are written, and only
% into the data sets the import resolved, so anything else in the file is
% passed through untouched.
%
% A reference file is therefore required. MTEX used to write a flat layout
% of its own when there was none, but nothing could read it back - not MTEX
% and no vendor tool - so it was removed. To carry a map between MTEX
% sessions use a |.mat| file, which keeps everything this one dropped.
%
% Syntax
%
%   % round trip - the reference is the file the data came from
%   ebsd = EBSD.load('myfile.h5oina')
%   ebsd = ebsd.denoise(halfQuadraticFilter)
%   export(ebsd,'denoised.h5oina')
%
%   % name the reference explicitly
%   exportEBSD_h5(ebsd,'denoised.h5oina','reference','myfile.h5oina')
%
% Input
%  ebsd  - @EBSD
%  fName - file name of the file to be written
%
% Options
%  reference   - file to copy and write the changed data into
%
% Flags
%  noProp      - write orientations and phases only, leave properties alone
%
% See also
% EBSD.load exportEBSD_ctf exportEBSD_ang

refFile = get_option(varargin,'reference','');

if isempty(refFile) && isfield(ebsd.opt,'h5') && isfield(ebsd.opt.h5,'fileName')
  refFile = ebsd.opt.h5.fileName;
end

if isempty(refFile)
  error('MTEX:exportEBSD_h5:noReference',...
    ['Writing HDF5 needs a reference file to copy, and this data was not '...
    'imported from one.\n\nName it explicitly\n\n'...
    '  export(ebsd,''%s'',''reference'',''myfile.h5'')\n\n'...
    'or, to carry the map between MTEX sessions, use save/load on a .mat '...
    'file - it keeps the reference frames, the imported header and '...
    'everything else an HDF5 export would drop.'],fName);
end

exportByReference(ebsd,fName,refFile,varargin{:});

end

% ------------------------------------------------------------------------
function exportByReference(ebsd,fName,refFile,varargin)

if ~exist(refFile,'file')
  error('MTEX:exportEBSD_h5:noReference',...
    ['The reference file\n\n  %s\n\nwas not found. Name an existing one\n\n'...
    '  export(ebsd,''%s'',''reference'',''myfile.h5'')'],...
    refFile,fName);
end

if ~isfield(ebsd.opt,'h5')
  error('MTEX:exportEBSD_h5:noProvenance',...
    ['This data was not imported from an HDF5 file, so there is no record '...
    'of which data set holds what and the reference file can not be '...
    'written into. Import the map with EBSD.load first, or use save/load '...
    'on a .mat file to carry it between MTEX sessions.']);
end

prov = ebsd.opt.h5;

if isSameFile(refFile,fName)
  error('MTEX:exportEBSD_h5:overwriteReference',...
    ['Output and reference are the same file (%s). Writing would destroy '...
    'the reference - choose a different output file.'],fName);
end

scrPrnt('SegmentStart','Exporting HDF5 file');
scrPrnt('Step',sprintf('Copying reference file %s',refFile));

[ok,msg] = copyfile(refFile,fName);
if ~ok
  error('MTEX:exportEBSD_h5:copyFailed','Could not copy %s to %s: %s',...
    refFile,fName,msg);
end
% a reference straight from a read only medium would otherwise be copied
% read only as well and every write below would fail
fileattrib(fName,'+w');

% which row of the file every measurement belongs to. gridify pads a map to
% a full rectangle and reorders it (see EBSD/gridify), so the grid position
% alone says nothing - oldId is the translation back, and the padded cells
% carry NaN.
if isfield(ebsd.prop,'oldId')
  idx = ebsd.prop.oldId(:);
else
  idx = ebsd.id(:);
end

nFile = fileLength(fName,prov);

keep = ~isnan(idx) & idx >= 1 & idx <= nFile;
idx = idx(keep);

if numel(unique(idx)) < numel(idx)
  error('MTEX:exportEBSD_h5:ambiguousIds',...
    ['Several measurements claim the same row of the reference file. This '...
    'happens when maps from different files are concatenated - export '...
    'those separately, each against its own reference.']);
end

scrPrnt('Step',sprintf('Writing %d of %d measurements',numel(idx),nFile));

% the file states the Euler angles in its own reference frame - undoing the
% correction the import applied is what makes the round trip give the very
% same numbers back
raw = ebsd;
raw.EulerCorrection = rotation.id;

written = {};

% orientations -----------------------------------------------------------
if isfield(prov,'rotation')
  written = [written, writeRotations(fName,prov.rotation,raw,keep,idx,nFile)];
end

% phases -----------------------------------------------------------------
if isfield(prov,'phase')
  written = [written, writePhases(fName,prov.phase,ebsd,keep,idx,nFile)];
end

% the phase list ---------------------------------------------------------
if isfield(prov,'cs')
  written = [written, writePhaseHeader(fName,prov.cs,ebsd)];
end

% properties -------------------------------------------------------------
if ~check_option(varargin,'noProp')
  written = [written, writeProps(fName,prov,ebsd,keep,idx,nFile)];
end

for i = 1:numel(written), scrPrnt('SubStep',written{i}); end

scrPrnt('Step',sprintf('All done, wrote %s',fName));

end

% ------------------------------------------------------------------------
function written = writeRotations(fName,rot,raw,keep,idx,nFile)
% write the orientations back the way the file parameterizes them

written = {};
if isempty(rot.item), return; end

switch rot.type

  case {'euler','euler_stack'}

    [phi1,Phi,phi2] = Euler(raw.rotations,'Bunge');
    phi = [phi1(:),Phi(:),phi2(:)];
    phi = phi(keep,:) ./ rot.format;

    % a pixel MTEX holds as not indexed has no Euler angles to state - the
    % file keeps whatever it said about it (EMSphInx marks those in the
    % phase column, others by a fit metric)
    ok = all(~isnan(phi),2);

    if isscalar(rot.item)
      written = writeItem(fName,rot.item,idx(ok),phi(ok,:),nFile);
    else
      for i = 1:min(numel(rot.item),3)
        written = [written, writeItem(fName,rot.item(i),idx(ok),phi(ok,i),nFile)]; %#ok<AGROW>
      end
    end

  case 'byMatrix'

    M = matrix(reshape(raw.rotations,[],1)); % 3 x 3 x N, one pixel per page
    M = reshape(M,9,[]).';
    M = M(keep,:);
    ok = all(~isnan(M),2);

    written = writeItem(fName,rot.item,idx(ok),M(ok,:),nFile);

  otherwise

    warning('MTEX:exportEBSD_h5:rotationType',...
      ['Orientations of type ''%s'' are read but not written - they are '...
      'left as the reference file states them.'],rot.type);

end

end

% ------------------------------------------------------------------------
function written = writePhases(fName,ph,ebsd,keep,idx,nFile)
% write the phase column back in the numbering the file uses

phase = ebsd.phase(:);
phase = phase(keep);

if strcmpi(ph.type,'zeroBased')
  % the phases are numbered from 0 and a pattern that could not be indexed
  % carries the largest value the column can hold - phaseMap states the
  % former, the storage type of the data set the latter
  notIndexed = double(ebsd.phaseMap(1));
  raw = readItem(fName,ph);
  if isinteger(raw)
    phase(phase == notIndexed) = double(intmax(class(raw)));
  else
    phase(phase == notIndexed) = 255;
  end
end

written = writeItem(fName,ph,idx,phase,nFile);

end

% ------------------------------------------------------------------------
function written = writePhaseHeader(fName,items,ebsd)
% write the phase list back into the header of the file
%
% A renamed mineral or a corrected lattice parameter is a change to the map
% like any other, and the reference file states both. What is not written is
% the symmetry itself: every vendor codes it differently - a TSL number, a
% space group id, a decorated name - and MTEX distinguishes more groups than
% those codes do, so the file keeps the symmetry it came with.

written = {};

ids = ebsd.indexedPhasesId;

for i = 1:numel(items)

  it = items(i);

  for k = 1:min(numel(ids),numel(it.path))

    cs = csOf(ebsd,ids(k));
    if ~isa(cs,'crystalSymmetry'), continue; end

    switch it.what
      case 'name',     val = cs.mineral;
      case 'a',        val = cs.aAxis.abs;
      case 'b',        val = cs.bAxis.abs;
      case 'c',        val = cs.cAxis.abs;
      case 'alpha',    val = cs.alpha / degree;
      case 'beta',     val = cs.beta / degree;
      case 'gamma',    val = cs.gamma / degree;
      case 'dim',      val = [cs.aAxis.abs, cs.bAxis.abs, cs.cAxis.abs];
      case 'angle',    val = [cs.alpha, cs.beta, cs.gamma] / degree;
      case 'lattice6', val = [cs.aAxis.abs, cs.bAxis.abs, cs.cAxis.abs, ...
                              [cs.alpha, cs.beta, cs.gamma] / degree];
      otherwise,       continue
    end

    p = char(string(it.path{k}));
    if isempty(p), continue; end

    if writeHeaderValue(fName,p,val)
      written = [written, {sprintf('%s = %s',p,valueStr(val))}]; %#ok<AGROW>
    end

  end

end

end

% ------------------------------------------------------------------------
function ok = writeHeaderValue(fName,path,val)
% overwrite a single header value, keeping the shape and type of the file
%
% A header data set is small and of the vendor's own type - a variable
% length string for a mineral name, a scalar float for a lattice constant.
% Whatever does not fit is left alone with a warning rather than written in
% a shape the vendor's software would not read.

ok = false;

try
  raw = h5read(fName,path);
catch
  return
end

try

  if ischar(val) || isstring(val)

    try
      if iscell(raw)
        h5write(fName,path,{char(val)});
      else
        h5write(fName,path,string(val));
      end
    catch
      % h5write writes a string only into a data set whose type it happens
      % to match. A vendor storing the name as a fixed length field - 21
      % characters for an EDAX MaterialName, 17 for a Bruker one - is not
      % one of those, and only the low level interface can fill it.
      writeFixedString(fName,path,char(val));
    end

  else

    if numel(raw) ~= numel(val)
      warning('MTEX:exportEBSD_h5:headerShape',...
        'The data set %s holds %d values, not %d - left untouched.',...
        path,numel(raw),numel(val));
      return
    end

    raw(:) = val(:);
    h5write(fName,path,raw);

  end

catch ME

  warning('MTEX:exportEBSD_h5:headerWrite',...
    'Could not write %s: %s',path,ME.message);
  return

end

ok = true;

end

% ------------------------------------------------------------------------
function writeFixedString(fName,path,val)
% write a string into a data set of the vendor's own string type
%
% A fixed length field is padded to its size and truncated when the new
% value does not fit - the file has no room for more, and saying so beats
% writing something the vendor's software cannot read.

fid = []; did = []; tid = [];

try

  fid = H5F.open(fName,'H5F_ACC_RDWR','H5P_DEFAULT');
  did = H5D.open(fid,path);
  tid = H5D.get_type(did);

  if H5T.is_variable_str(tid)
    data = {val};
  else
    n = H5T.get_size(tid);
    if numel(val) > n
      warning('MTEX:exportEBSD_h5:stringTruncated',...
        '%s holds %d characters, so ''%s'' was cut short.',path,n,val);
    end
    data = [val repmat(char(0),1,max(0,n-numel(val)))];
    data = data(1:n);
  end

  H5D.write(did,tid,'H5S_ALL','H5S_ALL','H5P_DEFAULT',data);

catch ME

  closeAll([],tid,did,fid);
  error('MTEX:exportEBSD_h5:stringWrite',...
    'Could not write %s: %s',path,ME.message);

end

closeAll([],tid,did,fid);

end

% ------------------------------------------------------------------------
function s = valueStr(val)

if ischar(val) || isstring(val)
  s = char(val);
else
  s = num2str(val(:).',' %g');
end

end

% ------------------------------------------------------------------------
function written = writeProps(fName,prov,ebsd,keep,idx,nFile)
% write back the properties that came from the file, and add the ones MTEX
% computed since as new data sets next to them

written = {};
skipped = {};

known = struct();
if isfield(prov,'prop'), known = prov.prop; end

% bookkeeping of the gridded layout, not data of the map
internal = {'oldId','x','y','z'};

newGroup = propGroup(prov,known);

for fn = fieldnames(ebsd.prop)'

  name = fn{1};
  if ismember(name,internal), continue; end

  v = ebsd.prop.(name);
  if islogical(v), v = double(v); end
  if ~isnumeric(v) || numel(v) ~= numel(keep), continue; end

  v = double(v(:));
  v = v(keep);

  if isfield(known,name)

    written = [written, writeItem(fName,struct('path',known.(name),'field',''),...
      idx,v,nFile)]; %#ok<AGROW>

  elseif ~isempty(newGroup)

    % a property MTEX added - grainId, KAM, ... - goes next to the ones the
    % file brought along, filled with NaN where the map no longer has a
    % measurement
    path = [newGroup '/' name];
    if ~dataSetExists(fName,path)
      h5create(fName,path,[1 nFile],'Datatype','double','FillValue',NaN);
    end
    full = nan(1,nFile);
    full(idx) = v;
    h5write(fName,path,full);
    written = [written, {sprintf('%s -> %s (new)',name,path)}]; %#ok<AGROW>

  else

    skipped = [skipped, {name}]; %#ok<AGROW>

  end

end

% a file that packs its whole map into one compound data set - an .edaxh5
% does - has no group to put another column in, and saying so beats
% silently dropping the property
if ~isempty(skipped)
  warning('MTEX:exportEBSD_h5:newProperties',...
    ['The properties %s could not be added to the file: it stores its map '...
    'as one record per measurement, which has no room for a column that '...
    'was not in it.'],strjoin(skipped,', '));
end

end

% ------------------------------------------------------------------------
function g = propGroup(prov,known)
% the group new properties are written into: the one the file's own
% properties live in, otherwise the one holding the phases

g = '';

fn = fieldnames(known);
if ~isempty(fn)
  g = fileparts(known.(fn{1}));
  return
end

if isfield(prov,'phase') && ~isempty(prov.phase.path) && isempty(prov.phase.field)
  g = fileparts(prov.phase.path);
end

end

% ------------------------------------------------------------------------
function n = fileLength(fName,prov)
% how many measurements the reference file holds

n = [];

if isfield(prov,'phase')
  n = numel(readItem(fName,prov.phase));
elseif isfield(prov,'rotation') && ~isempty(prov.rotation.item)
  raw = readItem(fName,prov.rotation.item(1));
  n = numel(raw);
  if isscalar(prov.rotation.item) && ~isvector(raw)
    % a stacked data set holds three angles or nine matrix entries per pixel
    sz = size(raw);
    n = prod(sz(2:end));
  end
end

if isempty(n) || n == 0
  error('MTEX:exportEBSD_h5:emptyReference',...
    'Could not determine how many measurements the reference file holds.');
end

end

% ------------------------------------------------------------------------
function raw = readItem(fName,item)
% the data set an entry was read from, in the shape and type of the file

raw = h5read(fName,item.path);
if ~isempty(item.field), raw = raw.(item.field); end

end

% ------------------------------------------------------------------------
function written = writeItem(fName,item,idx,vals,nFile)
% write values into the rows idx of one data set, leaving the rest of it -
% and its shape and storage type - as it is

written = {};
if isempty(item.path) || isempty(idx), return; end

raw = readItem(fName,item);

k = size(vals,2);
sz = size(raw);

if k == 1 && numel(raw) == nFile

  raw(idx) = vals;

elseif ismatrix(raw) && sz(1) == k && sz(2) == nFile

  raw(:,idx) = vals.';

elseif ismatrix(raw) && sz(1) == nFile && sz(2) == k

  raw(idx,:) = vals;

elseif numel(raw) == k*nFile && sz(1) == k

  % 3 x nx x ny, or 3 x 3 x n - the components come first either way
  tmp = reshape(raw,k,[]);
  tmp(:,idx) = vals.';
  raw = reshape(tmp,sz);

else

  warning('MTEX:exportEBSD_h5:shape',...
    ['Data set %s has size [%s] which does not match %d measurements with '...
    '%d values each - left untouched.'],item.path,num2str(sz),nFile,k);
  return

end

if isempty(item.field)
  h5write(fName,item.path,raw);
else
  % a compound data set is written as a whole, so everything else it packs
  % has to be read back and handed over unchanged
  s = h5read(fName,item.path);
  s.(item.field) = raw;
  h5writeCompound(fName,item.path,s);
end

written = {sprintf('%s%s',item.path,fieldSuffix(item))};

end

% ------------------------------------------------------------------------
function s = fieldSuffix(item)
if isempty(item.field), s = ''; else, s = [' (' item.field ')']; end
end

% ------------------------------------------------------------------------
function h5writeCompound(fName,path,s)
% write a compound data set - several values packed into one record, which
% is how an .edaxh5 stores its whole map. h5write only writes plain numeric
% data sets, so this goes through the low level interface, and the record
% has to be handed over whole (the caller read it back for that reason).

fid = []; did = []; tid = []; mtid = [];

try
  fid  = H5F.open(fName,'H5F_ACC_RDWR','H5P_DEFAULT');
  did  = H5D.open(fid,path);
  tid  = H5D.get_type(did);
  mtid = H5T.get_native_type(tid,'H5T_DIR_DEFAULT');
  H5D.write(did,mtid,'H5S_ALL','H5S_ALL','H5P_DEFAULT',s);
catch ME
  closeAll(mtid,tid,did,fid);
  error('MTEX:exportEBSD_h5:compoundWrite',...
    'Could not write the compound data set %s: %s',path,ME.message);
end

closeAll(mtid,tid,did,fid);

end

% ------------------------------------------------------------------------
function closeAll(mtid,tid,did,fid)

if ~isempty(mtid), try H5T.close(mtid); catch, end, end %#ok<*CTCH>
if ~isempty(tid),  try H5T.close(tid);  catch, end, end
if ~isempty(did),  try H5D.close(did);  catch, end, end
if ~isempty(fid),  try H5F.close(fid);  catch, end, end

end

% ------------------------------------------------------------------------
function tf = dataSetExists(fName,path)

tf = true;
try
  h5info(fName,path);
catch
  tf = false;
end

end

% ------------------------------------------------------------------------
function tf = isSameFile(a,b)

tf = strcmp(absPath(a),absPath(b));

end

% ------------------------------------------------------------------------
function p = absPath(f)

[d,n,e] = fileparts(char(f));
if isempty(d), d = pwd; end

w = what(d);
if ~isempty(w), d = w(1).path; end

p = fullfile(d,[n e]);

end
% ------------------------------------------------------------------------
function scrPrnt(mode,varargin)

switch mode
  case 'SegmentStart'
    fprintf('\n------------------------------------------------------');
    fprintf(['\n     ',varargin{1},' \n']);
    fprintf('------------------------------------------------------\n');
  case 'Step'
    fprintf([' -> ',varargin{1},'\n']);
  case 'SubStep'
    fprintf(['    - ',varargin{1},'\n']);
end

end
