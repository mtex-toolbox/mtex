classdef plottingConvention
% class describing the alignment of a reference frame on the screen
%
% plottingConvention is a value class: assigning one always copies, so a
% convention can never be changed behind the back of the data holding it.
% What couples data to the session default is the shared referenceFrame -
% see <specimenFrame.default.html specimenFrame.default> - not a shared
% convention handle.
%
% Syntax
%   % specify a custom plotting convention
%   pC = plottingConvention(outOfScreen,east)
%   plot(ebsd,pC)
%
%   % specify a custom plotting convention by a string - each axis is
%   % followed or preceded by the direction it points to on screen
%   pC = plottingConvention('y↑→x')  % y points up, x points to the right
%   pC = plottingConvention('x←↑y')  % x points to the left, y points up
%   pC = plottingConvention('z⊙→x')  % z points out of screen, x right
%   pC = plottingConvention('y^->x') % same as 'y↑→x', ASCII arrows
%   pC = plottingConvention('z(.)->x') % same as 'z⊙→x', (x) is ⊗
%
%   % changing the default plotting convention - modify a copy and make
%   % it the default (this is what plotx2east and friends do)
%   pC = plottingConvention.default; pC.east = yvector; pC.makeDefault
%
%   % a convention belongs to a reference frame, never to a data object, so
%   % how2plot is read only everywhere but @referenceFrame - align data by
%   % moving it into a frame that carries the convention
%   ebsd.frame = specimenFrame.rolling
%
% Input
%  outOfScreen - @vector3d
%  east        - @vector3d
%  str         - char, e.g. 'y↑→x', see <plottingConvention.plottingConvention.html the syntax above>
%
% Output
%  pC - @plottingConvention
%
  
  properties
    rot = rotation.id % screen coordinates to reference coordinates
  end

  properties (Dependent=true)
    east   % axis that point east (default = x)
    west   % axis that point west (default = -x)
    north  % axis that point north (default = y)
    south  % axis that point south (default = -y)
    outOfScreen % axis that point out of screen (default = z)
    intoScreen  % axis that point into screen (default = -z)
    viewOpt  % translates screen orientation in MATLAB options
  end

  properties (Hidden=true)
    lastSet = []
  end

  methods

    function pC = plottingConvention(outOfScreen,east)

      if nargin == 1 && (ischar(outOfScreen) || isstring(outOfScreen))
        pC.rot = str2rot(outOfScreen);
      elseif nargin == 1
        pC.rot = rotation.map(zvector,outOfScreen);
      elseif nargin == 2
        pC.rot = rotation.map(zvector,outOfScreen,xvector,east);
      end

      %if nargin >= 1, pC.outOfScreen = outOfScreen; end
      %if nargin >= 2, pC.east = east; end      
    end
        
    function display(pC,varargin)

      [c,isPictogram] = char(pC);
      displayClass(pC,inputname(1),'moreInfo',c,varargin{:});

      % an axis aligned convention is completely described by the pictogram above
      if isPictogram, return; end

      if ~check_option(varargin,'skipHeader'), disp(' '); end

      props{1} = 'outOfScreen';
      propV{1} = ['(' char(round(pC.outOfScreen)) ')'];

      props{2} = 'north';
      propV{2} = ['(' char(round(pC.north)) ')'];

      props{3} = 'east';
      propV{3} = ['(' char(round(pC.east)) ')'];
      
      % display all properties
      cprintf(propV(:),'-L','  ','-ic','L','-la','L','-Lr',props,'-d',': ');

      disp(' ')

    end

    function [c,isPictogram] = char(pC)
      % pictogram of the convention, e.g. 'y↑→x'
      %
      % The symbols follow the UTF8Output preference - with it switched
      % off the ASCII form 'y^->x' is printed, which is exactly what the
      % constructor parses back
      %
      % Output
      %  c           - char, the pictogram, or 'xyz' if there is none
      %  isPictogram - is the convention axis aligned, i.e. is c a pictogram?

      a = plottingConvention.arrows; xyz = 'xyz';

      % which axis points north, which one east - ud and lr say whether it
      % is the axis itself or its negative
      [ud,iN] = find(pC.north == [1;-1] .* [xvector,yvector,zvector]);
      [lr,iE] = find(pC.east == [1;-1] .* [xvector,yvector,zvector]);

      isPictogram = ~isempty(ud) && ~isempty(lr);

      if ~isPictogram
        c = 'xyz';
      elseif lr == 1
        c = [xyz(iN),a{ud+2},a{2},xyz(iE)];
      else
        c = [xyz(iE),a{1},a{ud+2},xyz(iN)];
      end

    end

    function setView(pC,ax)

      if nargin == 1, ax = gca; end

      if isgraphics(ax,'axes') && isappdata(ax,'sphericalPlot')

        sP = getappdata(ax,'sphericalPlot');
       
        sP.updateBounds;

        warning('Can not change plotting convention in spherical projections after plotting!');

      elseif isa(ax,'matlab.graphics.axis.PolarAxes')
        
        % ThetaZeroLocation is where theta = 0 is drawn, i.e. the screen angle
        % of xvector, from east towards north, rounded to the quadrant
        onScreen = atan2(dot(xvector,pC.north,'noAntipodal'), ...
          dot(xvector,pC.east,'noAntipodal'));
        switch mod(round(onScreen/(90*degree)),4)
          case 0
            ax.ThetaZeroLocation='right';
          case 1
            ax.ThetaZeroLocation='top';
          case 2
            ax.ThetaZeroLocation='left';
          case 3
            ax.ThetaZeroLocation='bottom';
        end
        if pC.outOfScreen.z<0
          ax.ThetaDir='clockwise';
        else
          ax.ThetaDir='counterclockwise';
        end

      elseif ax.PlotBoxAspectRatioMode == "manual" && ...
          ax.CameraPositionMode == "manual" % 3d plot with a placed camera

        % only for a camera placed by hand, where the distance encodes the zoom

        %cameraDist = norm(ax.CameraPosition - ax.CameraTarget);
        %ax.CameraPosition = ax.CameraTarget + cameraDist*pC.outOfScreen.xyz;
        %ax.CameraUpVector = pC.north.xyz;

        target = mean([ax.XLim; ax.YLim; ax.ZLim],2).';   % or your own target
        d = norm(ax.CameraPosition - ax.CameraTarget);    % preserve current distance

        guard = plottingConvention.beginCameraUpdate(ax); %#ok<NASGU>

        ax.CameraTarget = target;
        ax.CameraPosition = target + d * pC.outOfScreen.xyz;
        ax.CameraUpVector = pC.north.xyz;
        ax.CameraViewAngleMode = 'auto';   % usually faster and visually stable


        %ax.CameraUpVector = pC.north.xyz;
        %view(ax,pC.outOfScreen.xyz);
        %ax.CameraUpVector = pC.north.xyz;
        %ax.CameraViewAngleMode = 'auto';
      
      else % map plot

        % nothing to do if the camera already matches, do not fire the listeners
        try
          if angle(plottingConvention.getView(ax).rot, pC.rot) < 1e-6
            return
          end
        catch
        end

        %ax.CameraPosition = ax.CameraTarget + 1000*pC.outOfScreen.xyz;

        guard = plottingConvention.beginCameraUpdate(ax); %#ok<NASGU>

        % view() reads the plot box, so undo a reversed axis direction here
        n = pC.outOfScreen.xyz .* [1-2*strcmp(ax.XDir,'reverse'),...
          1-2*strcmp(ax.YDir,'reverse'), 1-2*strcmp(ax.ZDir,'reverse')];

        ax.CameraUpVector = pC.north.xyz;
        view(ax,n);
        ax.CameraUpVector = pC.north.xyz;
        ax.CameraViewAngleMode = 'auto';
      end
      
    end

    function opt = get.viewOpt(pC)
      opt = {'CameraPosition',1000*pC.outOfScreen.xyz,...
        "CameraUpVector",pC.north.xyz};
    end


    % the direction getters return a bare vector3d, it belongs to no frame
    function v = get.outOfScreen(pC)
      v = pC.rot * vector3d.Z; 
    end

    function pC = set.outOfScreen(pC,n)
      if angle(pC.rot * vector3d.Z,n) > 0.1*degree
        try
          pC.rot = rotation.map(pC.outOfScreen,n,pC.lastSet,pC.lastSet) * pC.rot;
        catch
          pC.rot = rotation.map(pC.outOfScreen,n) * pC.rot;
        end
      end
      pC.lastSet = n;
    end

    function v = get.intoScreen(pC)
      v = -pC.rot * vector3d.Z;
    end
    function pC = set.intoScreen(pC,n)
      try
        pC.rot = rotation.map(pC.outOfScreen,-n,pC.lastSet,pC.lastSet) * pC.rot;
      catch
        pC.rot = rotation.map(pC.outOfScreen,-n) * pC.rot;
      end
      pC.lastSet = n;
    end


    function v = get.east(pC) 
      v = pC.rot * vector3d.X;
    end
    function pC = set.east(pC,e)
      if angle(pC.rot * vector3d.X,e) > 0.1*degree
        try
          pC.rot = rotation.map(pC.east,e,pC.lastSet,pC.lastSet) * pC.rot;
        catch ME
          pC.rot = rotation.map(pC.east,e) * pC.rot;
        end
      end
      pC.lastSet = e;
    end

    function v = get.west(pC)
      v = -pC.rot * vector3d.X; 
    end
    function pC = set.west(pC,w)
      try
        pC.rot = rotation.map(pC.east,-w,pC.lastSet,pC.lastSet) * pC.rot;
      catch
        pC.rot = rotation.map(pC.east,-w) * pC.rot;
      end
      pC.lastSet = w;
    end

    function v = get.north(pC)
      v = pC.rot * vector3d.Y(pC); 
      %v.how2plot = pC;
    end
    function pC = set.north(pC,v)
      try
        pC.rot = rotation.map(pC.north,v,pC.lastSet,pC.lastSet) * pC.rot;
      catch
        pC.rot = rotation.map(pC.north,v) * pC.rot;
      end
      pC.lastSet = v;
    end
    
    function v = get.south(pC), v = -pC.rot * vector3d.Y; end

    function pC = set.south(pC,v)
      try
        pC.rot = rotation.map(pC.north,-v,pC.lastSet,pC.lastSet) * pC.rot;
      catch ME
        pC.rot = rotation.map(pC.north,-v) * pC.rot;
      end
      pC.lastSet = v;
    end

    function makeDefault(pC)
      plottingConvention.default(pC);
    end

    function out = isapprox(pC,pC2,tol)
      % do two conventions describe the same alignment?

      if nargin < 3, tol = 1e-6; end

      out = isa(pC2,'plottingConvention') && ...
        all(angle(pC.rot,pC2.rot) < tol);

    end

    function out = eq(pC,pC2)
      % as a value class equality means equal alignment on screen -
      % there is no handle identity to compare
      out = isa(pC,'plottingConvention') && isapprox(pC,pC2);
    end

    function out = ne(pC,pC2)
      out = ~eq(pC,pC2);
    end

    function pC = matchDefault(pC)
      % normalize to the default convention if it describes the same
      % alignment
      %
      % Historically this re-aliased to the default handle; since
      % plottingConvention is a value class it merely returns an equal
      % value, and what makes data follow the default is membership in
      % the default frame - see vector3d/set.how2plot. Kept for
      % compatibility.

      pCd = plottingConvention.default;
      if isapprox(pC,pCd), pC = pCd; end

    end

  end

  methods (Static=true)

    function a = arrows
      % the screen direction symbols, in the order
      % {west, east, north, south, intoScreen, outOfScreen}
      %
      % Everything that prints a convention - <plottingConvention.char>,
      % <referenceFrame.conventionChar>, <crystalFrame.conventionChar> -
      % takes its symbols from here, so the UTF8Output preference reaches
      % all of them. The ASCII forms are the ones str2rot parses back, so
      % a printed convention can always be pasted into the constructor.
      %
      % See also
      % plottingConvention/char

      if getMTEXpref('UTF8Output',true)
        a = {'←','→','↑','↓','⊗','⊙'};
      else
        a = {'<-','->','^','v','(x)','(.)'};
      end

    end

    function [pC,isExplicit] = fromOption(list,default)
      % the plotting convention among a list of plot options, if any
      %
      % Accepts a @plottingConvention passed as an argument, and the name
      % value form for a one off plot
      %
      %   plot(v,'how2plot','y↑→x')
      %
      % The name value form is what functionSignatures.json can advertise,
      % so the conventions show up in tab completion. It also removes the
      % need to guess whether a bare string was meant as a convention.
      %
      % A plot method that wants its data to set the convention unless the
      % caller says otherwise appends it as |'how2plotFallback',pC| rather
      % than as a bare object. That is what |isExplicit| reports on: it is
      % false for such a fallback and for |default|, true only when the
      % caller put a convention in the list themselves. A plot that would
      % rather pick its own camera than follow a fallback - @vector3d/plot3d
      % does, a sphere seen down its polar axis being a poor picture - can
      % then tell the two apart instead of guessing from the value.
      %
      % Syntax
      %   pC = plottingConvention.fromOption(varargin)
      %   pC = plottingConvention.fromOption(varargin,default)
      %   [pC,isExplicit] = plottingConvention.fromOption(varargin,default)
      %
      % Input
      %  list    - the option list
      %  default - returned when the list carries no convention
      %
      % Output
      %  pC         - the @plottingConvention to use
      %  isExplicit - whether the caller asked for it
      %
      % See also
      % plottingConvention/default

      if nargin < 2, default = []; end

      % take the appended fallback out first, the bare object search would find it
      fallback = get_option(list,'how2plotFallback');
      list = delete_option(list,'how2plotFallback',1);

      isExplicit = true;

      % the name value form wins over a bare object, which the plot methods append
      pC = get_option(list,'how2plot');

      if isempty(pC), pC = getClass(list,'plottingConvention'); end

      if isempty(pC)
        isExplicit = false;
        pC = fallback;
        if isempty(pC), pC = default; return; end
      end

      if ischar(pC) || isstring(pC), pC = plottingConvention(pC); end

    end

    function test
      grainsR = rotate(grains,rotation.rand);
      plot(grainsR,grainsR.meanOrientation,'micronbar','off');
      pC.outOfScreen = grainsR.N; pC.setView(gca)
    end
    
    function pC = default(pC)
      % get or set the default plotting convention
      %
      % Syntax
      %   pC = plottingConvention.default      % the current default
      %   plottingConvention.default(pC)       % make pC the default
      %   plottingConvention.default('y↑→x')   % same by a string
      %
      % The default is carried by the registered default specimen frame -
      % see <specimenFrame.default.html specimenFrame.default>. Setting a
      % new default replaces the convention of that frame; symmetries and
      % data holding the frame follow, data holding the old convention
      % handle keeps it (as before). The point group of
      % specimenSymmetry.default is untouched.

      if nargin == 1 % new default
        if ischar(pC) || isstring(pC), pC = plottingConvention(pC); end
        fr = specimenFrame.default;
        fr.how2plot = pC;
      else
        pC = specimenFrame.default.how2plot;
      end
    end
    
    function pC = default3D
      pC = plottingConvention(vector3d(-10,-5,2),vector3d(1,-2,0));
    end
   

    function guard = beginCameraUpdate(ax)
      % suppress camera notifications until the camera is consistent again
      %
      % The orientation of an axes is spread over several camera properties,
      % but they can only be assigned one at a time and each assignment fires
      % its own PostSet event. Listeners that read the orientation back (e.g.
      % the scale bar, via <plottingConvention.getView>) would therefore first
      % see an intermediate state - typically the new viewing direction still
      % paired with the previous up vector - lay themselves out for it, and
      % then immediately do it all again for the final state.
      %
      % Bracketing the assignments with this guard marks the axes as
      % mid-update, which those listeners check and skip. Releasing the guard
      % - by clearing the returned object, i.e. at the latest when the calling
      % function returns, also on error - unmarks the axes and fires exactly
      % one notification, on the finished camera.
      %
      % Syntax
      %   guard = plottingConvention.beginCameraUpdate(ax);
      %   ax.CameraPosition = ...; ax.CameraUpVector = ...;
      %
      % Input
      %  ax - axes handle
      %
      % Output
      %  guard - onCleanup object, keep alive for the duration of the update
      %
      % See also
      % plottingConvention/setView scaleBar/update

      setappdata(ax,'MTEXcameraUpdate',true);
      guard = onCleanup(@() plottingConvention.endCameraUpdate(ax));
    end

    function endCameraUpdate(ax)
      % counterpart of beginCameraUpdate - see there

      if ~isgraphics(ax), return; end
      if isappdata(ax,'MTEXcameraUpdate'), rmappdata(ax,'MTEXcameraUpdate'); end

      % re-assign to fire the single PostSet the listeners were kept from
      up = ax.CameraUpVector;
      ax.CameraUpVector = up;
    end

    function pC = getView(ax)
      % reconstruct the plottingConvention from the current camera state
      %
      % This is the inverse operation to <plottingConvention.setView>: it
      % reads back the orientation that is currently applied to an axis.
      % Together they allow other graphics objects (e.g. the scale bar) to
      % stay in sync with the axis no matter whether the same convention was
      % modified in place or a different one was applied via setView.
      %
      % Syntax
      %   pC = plottingConvention.getView(ax)
      %   pC = plottingConvention.getView      % uses gca
      %
      % Input
      %  ax - axes handle (default: gca)
      %
      % Output
      %  pC - @plottingConvention
      %
      % See also
      % plottingConvention/setView

      if nargin == 0, ax = gca; end

      % setView leaves CameraPosition - CameraTarget parallel to outOfScreen and
      % CameraUpVector equal to north, so read those two directions back
      camDir = ax.CameraPosition - ax.CameraTarget;   % points towards viewer
      up     = ax.CameraUpVector;

      outOfScreen = normalize(vector3d(camDir(1),camDir(2),camDir(3)));
      up          = vector3d(up(1),up(2),up(3));

      % north is only the component of the up vector orthogonal to outOfScreen
      north = up - dot(up,outOfScreen) * outOfScreen;

      % rebuild the rotation consistent with the getters
      %   outOfScreen = rot * Z,  north = rot * Y
      pC = plottingConvention;
      if norm(north) <= 1e-10 * norm(up) % up is along the viewing direction
        pC.rot = rotation.map(vector3d.Z,outOfScreen); % no roll defined
      else
        pC.rot = rotation.map(vector3d.Z,outOfScreen,vector3d.Y,normalize(north));
      end
    end



    function pC = ij
      % Map plotting conventions to match SEM image display and MATLAB
      % 'axis ij' reference frames.
      % Use with import flag "convertEuler2SpatialReferenceFrame" for
      % most modern SEM systems.
      % Useful for producing comparable map plots in MTEX,
      % MATLAB and SEM/EBSD software.
      %
      % pC = plottingConvention.ij;
      %
      % The rotation - 180 degree about x, i.e. z -> -z and y -> -y - is
      % set directly instead of by plottingConvention(-vector3d.Z,
      % vector3d.X). Since this is the default convention, @vector3d can
      % not be used here: its class default how2plot asks for exactly this
      % convention, which MATLAB rejects as a circular initialisation.
      pC = plottingConvention;
      pC.rot = rotation(quaternion(0,1,0,0));
    end
    
    function pC = edax(setting)
      % Map plotting conventions to match EDAX Euler reference frame
      % A1/A2/A3.
      % Use with import flag "convertSpatial2EulerReferenceFrame" on
      % EDAX systems.
      % Useful for producing comparable orientation plots in MTEX and EDAX software.
      %
      % Input:
      %  setting = edax setting number (numeric) (default = 2)
      
      if nargin<1
        setting = 2;
        warning("No EDAX reference frame setting specified. Defaulting to setting 2.")
      end
      switch setting
        case 1
          outOfScreen = vector3d.Z;
          east = vector3d.Y;
        case 2
          outOfScreen = vector3d.Z;
          east = -vector3d.Y;
        case 3
          outOfScreen = vector3d.Z;
          east = vector3d.X;
        case 4
          outOfScreen = vector3d.Z;
          east = -vector3d.X;
      end
      pC = plottingConvention(outOfScreen,east);
    end

  end

end

function rot = str2rot(str)
% translate a string like 'y↑→x' into the corresponding rotation
%
% The string consists of axis names x,y,z and arrows describing where these
% axes point to on screen - this is exactly the format printed by
% <plottingConvention.char>. Each arrow belongs to the axis next to it, no
% matter whether it comes before or after it, i.e. 'y↑→x', 'y↑x→' and
% '↑y→x' all describe the same convention. Two axes are needed to fix the
% alignment, a single one leaves the remaining rotation about it undefined
% and is completed by the smallest possible rotation.

str = char(str);

% ASCII replacements for the arrows - (x) before its x is read as an axis name
str = strrep(str,'(x)','⊗');
str = strrep(str,'(.)','⊙');
str = strrep(str,'->','→');
str = strrep(str,'<-','←');
str = strrep(str,'^','↑');
str = strrep(str,'v','↓');
str = strrep(str,'V','↓');
str(isspace(str)) = [];

xyz = 'xyz';
refDir = [vector3d.X, vector3d.Y, vector3d.Z];

arrows = '←→↑↓⊗⊙';
screenDir = [-vector3d.X, vector3d.X, vector3d.Y, -vector3d.Y, ...
  -vector3d.Z, vector3d.Z];

% split the string into axis and screen direction tokens
isAxis = false(size(str)); vec = vector3d.nan(size(str)); s = 1; n = 0;
for k = 1:length(str)

  if str(k) == '-', s = -s; continue; end

  ind = find(str(k) == xyz);
  if ~isempty(ind)
    n = n+1; isAxis(n) = true; vec(n) = s * refDir(ind); s = 1;
    continue
  end

  ind = find(str(k) == arrows);
  if isempty(ind)
    error('MTEX:plottingConvention',['Can not interpret ''%s'' as a plotting ' ...
      'convention - unknown symbol ''%s''. Use axis names x,y,z and the ' ...
      'arrows ←→↑↓⊗⊙ (or <- -> ^ v (x) (.)), e.g. ''y↑→x''.'],str,str(k));
  end
  n = n+1; isAxis(n) = false; vec(n) = screenDir(ind);

end
isAxis = isAxis(1:n); vec = vec(1:n);

% pair each axis with the arrow next to it
pair = zeros(0,2); open = 0;
for k = 1:n
  if open == 0
    open = k;
  elseif isAxis(open) ~= isAxis(k)
    pair(end+1,:) = [open,k]; open = 0; %#ok<AGROW>
  else % two axes or two arrows in a row - nothing to pair them with
    open = -1; break
  end
end

if open ~= 0 || isempty(pair)
  error('MTEX:plottingConvention',['Can not interpret ''%s'' as a plotting ' ...
    'convention - every axis needs an arrow next to it, e.g. ''y↑→x''.'],str);
end
if size(pair,1) > 2
  error('MTEX:plottingConvention',['Can not interpret ''%s'' as a plotting ' ...
    'convention - at most two axes may be specified.'],str);
end

% sort each pair into (screen direction, reference direction)
sD = vector3d.nan(1,size(pair,1)); rD = sD;
for k = 1:size(pair,1)
  ind = pair(k,:);
  if isAxis(ind(1)), ind = fliplr(ind); end
  sD(k) = vec(ind(1)); rD(k) = vec(ind(2));
end

if length(sD) == 1
  rot = rotation.map(sD,rD);
else
  if abs(dot(sD(1),sD(2))) > 1e-6 || abs(dot(rD(1),rD(2))) > 1e-6
    error('MTEX:plottingConvention',['Can not interpret ''%s'' as a plotting ' ...
      'convention - the two axes as well as the two screen directions have ' ...
      'to be perpendicular to each other.'],str);
  end
  rot = rotation.map(sD(1),rD(1),sD(2),rD(2));
end

end

