classdef ipfColorKey < orientationColorKey
  % defines an orientation mapping based on a certain inverse pole figure
  %   Detailed explanation goes here
  
  properties
    inversePoleFigureDirection
    dirMap 
  end
    
  methods
    
    function oM = ipfColorKey(varargin)
      oM = oM@orientationColorKey(varargin{:});
      
      oM.dirMap = getClass(varargin,'directionColorKey',[]);
      if isempty(oM.dirMap), oM.dirMap = HSVDirectionKey(oM.CS1); end
      
      if isa(oM.CS2,'crystalSymmetry')
        try
          oM.inversePoleFigureDirection = Miller(oM.dirMap.whiteCenter,oM.CS2);
        catch
          oM.inversePoleFigureDirection = Miller(0,0,1,oM.CS2);
        end
      else
        oM.inversePoleFigureDirection = zvector;
      end
      
    end
    
    function plot(oM,varargin)
      
    
      [~,caxes] = plot(oM.dirMap,'doNotDraw',varargin{:});
      mtexFig = gcm;
      
      %mtexTitle(caxes(1),char(oM.inversePoleFigureDirection,'LaTeX'),varargin{:});
      mtexTitle(caxes(1),char(oM.CS1,'latex'),varargin{:});
      
      name = oM.CS1.pointGroup;
      if ~isempty(oM.CS1.mineral), name = [oM.CS1.mineral ' (' name ')']; end
      
      try
        set(mtexFig.parent,'name',['IPF key for ' name])
      end
      set(caxes,'tag','ipdf')
      setAllAppdata(caxes,'CS',oM.CS1,...
        'inversePoleFigureDirection',oM.inversePoleFigureDirection);
            
      try
        mtexFig.drawNow('figSize','small',varargin{:});
      end

    end

    function precompute(oM,varargin)
      % discretizes the direction -> color map on a grid so that subsequent
      % color lookups (one per orientation to be colored) are cheap
      %
      % Coloring a direction exactly expands it over all symmetry elements
      % in project2FundamentalRegion, which costs about 0.9 s and 0.2 GB per
      % million orientations. Looking it up on the grid costs about 0.06 s
      % per million and no significant memory, at the price of discretizing
      % the map once (about 90 ms). The grid therefore pays for itself from
      % roughly 100000 orientations on - and EBSD/plot builds a fresh key on
      % every call, so it is kept in memory for the rest of the session.

      if ~isempty(oM.dirMap.dir2color), return; end % already precomputed

      fun = cachedColorGrid(oM);
      oM.dirMap.dir2color = @(v) fun.eval(v);

    end

    function rgb = orientation2color(oM,ori)
    
      if ~(ori.CS.properSubGroup <= oM.CS1)
        warning('The symmetry of the ipf key and the orientations does not fit.')
      end
      
      % compute crystal directions
      ori.CS = oM.CS1;
      h = inv(ori) .* normalize(oM.inversePoleFigureDirection);
      
      % colorize fundamental region
      rgb = oM.Miller2Color(h);
      
    end
    
    
    function rgb = Miller2Color(oM,h)
      
      rgb = oM.dirMap.direction2color(h);
      
    end
    
    function S2F = S2Fun(oM)      
      S2F = S2FunHandle(@(h) direction2color(oM.dirMap,h));
      
      %S2F = S2FunHarmonicSym.quadrature(@(h) oM.dirMap.direction2color(h),oM.CS1);
      
    end    
  end
end

function fun = cachedColorGrid(oM)
% the discretized direction -> color map, reused within a MATLAB session
%
% The cache is held in memory only. Writing it to disk was measured to save
% just 78 ms per key - 13 ms to load against 91 ms to rebuild - which is not
% worth an on disk format that has to be kept in step with the color key
% code, and which is a loss outright when the preference directory lives on
% a network share.

persistent cache

removeObsoleteCacheFiles

if ~isCacheableColorKey(oM)
  fun = S2FunGrid(@(v) oM.dirMap.direction2color(v));
  return
end

if isempty(cache), cache = containers.Map; end

id = colorGridKey(oM);
if cache.isKey(id), fun = cache(id); return; end

fun = S2FunGrid(@(v) oM.dirMap.direction2color(v));

% a grid takes about 1.5 MB - a map has a handful of phases at most, so
% simply start over rather than bookkeeping which entry to evict
if cache.Count >= 8, remove(cache,cache.keys); end
cache(id) = fun;

end

function tf = isCacheableColorKey(oM)
% the precomputed color grid is determined by the fundamental sector - not
% by the inverse pole figure direction or the specimen symmetry - PROVIDED
% the direction key is an unmodified HSVDirectionKey. Three point groups
% (-1, -3, -4 / ids 2, 18, 26) do not have a topologically correct
% colormap (HSVDirectionKey itself warns about this), so they are excluded
% from the cache.

tf = strcmp(class(oM.dirMap),'HSVDirectionKey') && ...
  ~ismember(oM.CS1.id,[2,18,26]) && ...
  isequal(oM.dirMap.colorStretching,1) && ...
  isequal(oM.dirMap.grayValue,[0.2 0.5]) && ...
  isequal(oM.dirMap.grayGradient,0.5) && ...
  isequal(oM.dirMap.maxAngle,inf);

if tf
  ref = HSVDirectionKey(oM.CS1);
  tf = norm(oM.dirMap.whiteCenter - ref.whiteCenter) < 1e-10;
end

end

function id = colorGridKey(oM)
% identifies a color grid by everything it depends on, so that a cached one
% can never be handed out for a key it was not computed for
%
% The point group alone would not be enough: for trigonal and hexagonal
% lattices the map additionally depends on whether x is aligned with a or
% with a*, and for monoclinic and triclinic lattices on the lattice metric.

sR = oM.dirMap.sR;
N = sR.N;
wc = oM.dirMap.whiteCenter;

id = ['id' num2str(oM.CS1.id) '_' ...
  digest([N.x(:); N.y(:); N.z(:); sR.alpha(:); wc.x(:); wc.y(:); wc.z(:)])];

end

function removeObsoleteCacheFiles()
% MTEX used to keep the color grids in the preference directory - remove
% what earlier versions left behind there
%
% TODO: this can go once no one upgrades from a version that wrote them

persistent done
if ~isempty(done), return; end
done = true;

cacheDir = fullfile(prefdir,'mtex_cache','colorKeys');
old = dir(fullfile(cacheDir,'ipfColorKey_id*.mat'));
for k = 1:numel(old)
  try delete(fullfile(cacheDir,old(k).name)); end %#ok<TRYNC>
end
try rmdir(cacheDir); end %#ok<TRYNC>

end

function h = digest(v)
% short hex digest of a vector of doubles
%
% Rounding first keeps numerical noise from spawning new cache entries.
% Note the asymmetry: two distinct keys hashing apart merely costs a second
% entry, while two distinct keys hashing together would hand out the wrong
% colors - hence rounding is deliberately mild.

v = round(v(:).',10);
v(v==0) = 0; % so that -0 and 0 agree
b = double(typecast(v,'uint8'));

% two independent Bernstein hashes, intermediates stay below 2^53
h1 = 5381; h2 = 52711;
for k = 1:numel(b)
  h1 = mod(33*h1 + b(k),2^32);
  h2 = mod(31*h2 + b(k),2^32);
end

h = lower([dec2hex(h1,8) dec2hex(h2,8)]);

end
