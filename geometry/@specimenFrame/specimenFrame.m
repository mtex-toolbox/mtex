classdef specimenFrame < referenceFrame
% the reference frame a sample is expressed in
%
% Named instances make moving between specimen frames an explicit
% operation: the measurement frame of the instrument (X, Y, Z), the
% rolling frame (RD, TD, ND), the geological frame. The named factories
% return the one session instance from the register
% (<referenceFrame.referenceFrame.html |referenceFrame.byName|>); naming a
% frame here makes a fresh, unregistered one. The axes names are identity
% and display only for now - nothing else consumes them yet.
%
% The frame also carries the sample symmetry (ADR 0008), which is what a
% point group asks for: that is a lookup rather than a construction, since
% the frame it names is the session's, in the group asked for.
%
% Syntax
%
%   sF = specimenFrame.specimen             % the generic frame X, Y, Z
%   sF = specimenFrame.measurement          % the instrument frame X1, Y1, Z1
%   sF = specimenFrame.rolling
%   sF = specimenFrame.geological
%   sF = specimenFrame.default              % supplies the default convention
%   specimenFrame.rolling.makeDefault       % the session plots RD north
%
%   % the session frame in the sample symmetry asked for
%   sF = specimenFrame('mmm')
%   sF = specimenFrame('orthorhombic')
%   sF = specimenFrame(pC)                  % ... drawn that way
%   sF = specimenFrame(otherFrame)          % ... that frame, claiming nothing
%
%   % a fresh frame, name first, optionally with axes names and convention
%   sF = specimenFrame('rolling','axesNames',{'RD','TD','ND'},how2plot)
%
% Input
%  name     - Schoenflies or International notation of the point group, or
%             the name of a frame - a point group symbol is read as the group
%  how2plot - @plottingConvention
%
% Options
%  noIntern - do not unify with the session instance of this frame
%
% Class Properties
%  axesNames - names of the three axes, default {'X','Y','Z'}
%
% See also
% referenceFrame crystalFrame specimenSymmetry

  methods

    function sF = specimenFrame(varargin)

      % this is for compatibility with using "strings" as input
      try varargin = controllib.internal.util.hString2Char(varargin); catch, end

      % every way of naming a frame resolves to the arguments the frame
      % itself takes, so the superclass constructor is called once and
      % unconditionally - MATLAB does not allow it inside a branch
      [args,post] = readSyntax(varargin);

      sF = sF@referenceFrame(args{:});

      sF = applySyntax(sF,post);

    end

    function makeDefault(sF)
      % make this frame the session default
      %
      % plottingConvention.default, specimenFrame.default and every
      % frame-free or default-framed object follow it from now on
      %
      % Syntax
      %   specimenFrame.rolling.makeDefault

      specimenFrame.default(sF);
    end

  end

  methods (Static = true)

    function sF = specimen
      % the generic specimen frame with the canonical axes X, Y, Z - where
      % an import lands, since no vendor gives the map a reference system
      % of its own, and the session default until the user declares a more
      % specific frame such as specimenFrame.rolling for a rolled sheet
      sF = specimenFrame.named('specimen',{'X','Y','Z'});
    end

    function sF = measurement
      % the sample surface CS1 of an Oxford instrument, axes X1, Y1, Z1 -
      % the frame its Euler angles are stated in, not the one its map
      % lives in. An import does not attach it: MTEX rotates the Euler
      % angles into the map frame, and the map has no vendor frame at all
      sF = specimenFrame.named('measurement',{'X1','Y1','Z1'});
      % seeded with the convention of the vendor software - x east, y
      % south, the way an SEM image is displayed
      if isempty(sF.how2plot), sF.how2plot = plottingConvention.ij; end
    end

    function sF = rolling
      % rolling direction, transverse direction, normal direction,
      % seeded with the typical rolling convention - RD to the north,
      % TD to the west and hence ND out of the page
      sF = specimenFrame.named('rolling',{'RD','TD','ND'});
      if isempty(sF.how2plot), sF.how2plot = plottingConvention('y←↑x'); end
    end

    function sF = geological
      % north, east, down - the lower hemisphere convention of structural
      % geology; the names are display only and may still change
      sF = specimenFrame.named('geological',{'N','E','D'});
    end

    function sF = default(sF)
      % get or set the frame that supplies the session default
      %
      % plottingConvention.default reads and writes through this frame,
      % and specimenFrame.default's singleton holds it. Initially it
      % is the generic specimen frame X, Y, Z, seeded with
      % plottingConvention.ij - x to east, y to south, z into the
      % screen, the convention of SEM images and of most EBSD imports.
      % Any specimen frame can take over via
      % <specimenFrame.makeDefault.html |makeDefault|>, e.g.
      %
      %   specimenFrame.rolling.makeDefault
      %
      % Syntax
      %   sF = specimenFrame.default     % the current default frame
      %   specimenFrame.default(sF)      % make sF the default frame

      persistent def

      if nargin == 1
        if isempty(sF)
          def = []; return  % referenceFrame.reset - re-seeded on next get
        end
        assert(isa(sF,'specimenFrame'), ...
          'Only a specimenFrame can supply the session default.');
        def = sF;
      else
        if isempty(def), def = specimenFrame.specimen; end
        % the default frame always carries a convention
        if isempty(def.how2plot), def.how2plot = plottingConvention.ij; end
        sF = def;
      end
    end

    function fr = frameFor(pC)
      % the session frame carrying pC - the registered one when it already
      % carries that convention, an unregistered fork otherwise, keeping the
      % name and the axes names of the session frame
      %
      % Accepts a string like 'y↑→x', and reports no frame for no convention,
      % so that every set.how2plot is one line through here instead of
      % repeating the normalisation

      if ischar(pC) || isstring(pC), pC = plottingConvention(pC); end
      if isempty(pC), fr = []; return; end

      fr = specimenFrame.default;
      if pC ~= fr.how2plot
        fr = clone(fr);
        fr.how2plot = pC;
        fr = referenceFrame.intern(fr);
      end
    end

  end

  methods (Static = true, Hidden = true)

    function sF = named(name,axesNames)
      % the interned session instance, constructed on first use
      %
      % It goes into both registers: the name map answers the factories,
      % and the entity register is what a loaded frame is matched against,
      % so a saved 'rolling' comes back as this handle rather than a twin
      sF = referenceFrame.byName(name);
      if isempty(sF)
        sF = referenceFrame.intern(specimenFrame(name,'axesNames',axesNames));
        referenceFrame.byName(name,sF);
      end
    end

  end

end
