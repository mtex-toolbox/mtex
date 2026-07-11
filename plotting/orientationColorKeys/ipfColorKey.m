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
      % discretizes the direction -> color map on a grid so that
      % subsequent color lookups (one per orientation to be colored) are
      % cheap. This discretization step itself is expensive, but for the
      % common case - an unmodified HSVDirectionKey - it depends only on
      % the point group (there are only a few dozen of them), so it is
      % cached to disk and reused across MATLAB sessions.

      useCache = isCacheableColorKey(oM);

      if useCache
        cacheFile = colorKeyCacheFile(oM.CS1.id);
        if exist(cacheFile,'file')
          try
            s = load(cacheFile,'fun');
            oM.dirMap.dir2color = @(v) s.fun.eval(v);
            return
          catch
            % cache file unreadable/corrupt - fall through and recompute
          end
        end
      end

      fun = S2FunGrid(@(v) oM.dirMap.direction2color(v));
      oM.dirMap.dir2color = @(v) fun.eval(v);

      if useCache
        try
          if ~exist(fileparts(cacheFile),'dir'), mkdir(fileparts(cacheFile)); end
          save(cacheFile,'fun');
        catch
          % e.g. read-only filesystem - caching is a pure optimization
        end
      end

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

function tf = isCacheableColorKey(oM)
% the precomputed color grid only depends on the point group id - not on
% lattice parameters, the inverse pole figure direction, or specimen
% symmetry - PROVIDED the direction key is an unmodified HSVDirectionKey.
% Three point groups (-1, -3, -4 / ids 2, 18, 26) do not have a
% topologically correct, metric-independent colormap (HSVDirectionKey
% itself warns about this), so they are excluded from the cache.

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

function file = colorKeyCacheFile(id)
% cache lives under MATLAB's per-user preference directory, which is
% guaranteed writable and persists across MATLAB sessions on the same
% machine (unlike tempdir, which may be cleared on reboot)

cacheDir = fullfile(prefdir,'mtex_cache','colorKeys');
file = fullfile(cacheDir,['ipfColorKey_id' num2str(id) '_v1.mat']);

end
