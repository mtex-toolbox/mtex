classdef specimenFrame < referenceFrame
% the reference frame a sample is expressed in
%
% Named instances make moving between specimen frames an explicit
% operation: the measurement frame of the instrument (X, Y, Z), the
% rolling frame (RD, TD, ND), the geological frame. The named factories
% return the one session instance from the register
% (<referenceFrame.byName.html |referenceFrame.byName|>); calling the
% constructor directly always makes a fresh, unregistered frame. The axes
% names are identity and display only for now - nothing else consumes
% them yet.
%
% Syntax
%
%   sF = specimenFrame.measurement          % the session instance
%   sF = specimenFrame.rolling
%   sF = specimenFrame.geological
%   sF = specimenFrame.default              % supplies the default convention
%
%   % a fresh frame, name first, optionally with axes names and convention
%   sF = specimenFrame('rolling','axesNames',{'RD','TD','ND'},how2plot)
%
% Input
%  how2plot - @plottingConvention
%
% Class Properties
%  axesNames - names of the three axes, default {'X','Y','Z'}
%
% See also
% referenceFrame crystalFrame specimenSymmetry

  properties
    axesNames = {'X','Y','Z'}  % names of the three axes
  end

  methods

    function sF = specimenFrame(varargin)
      % the name may be given as the first argument
      if ~isempty(varargin) && (ischar(varargin{1}) || isstring(varargin{1}))
        varargin = [varargin(2:end),{'name',char(varargin{1})}];
      end
      sF = sF@referenceFrame(varargin{:});
      sF.axesNames = get_option(varargin,'axesNames',sF.axesNames);
    end

  end

  methods (Static = true)

    function sF = measurement
      % the frame of the instrument the data was measured in
      sF = specimenFrame.named('measurement',{'X','Y','Z'});
    end

    function sF = rolling
      % rolling direction, transverse direction, normal direction
      sF = specimenFrame.named('rolling',{'RD','TD','ND'});
    end

    function sF = geological
      % north, east, down - the lower hemisphere convention of structural
      % geology; the names are display only and may still change
      sF = specimenFrame.named('geological',{'N','E','D'});
    end

    function sF = default
      % the frame that supplies the session default plotting convention
      %
      % plottingConvention.default reads and writes through this frame,
      % and specimenSymmetry.default's singleton holds it. Seeded with
      % plottingConvention.ij - x to east, y to south, z into the screen,
      % the convention of SEM images and of most EBSD imports.
      sF = specimenFrame.measurement;
      if isempty(sF.how2plot), sF.how2plot = plottingConvention.ij; end
    end

  end

  methods (Static = true, Hidden = true)

    function sF = named(name,axesNames)
      % the interned session instance, constructed on first use
      sF = referenceFrame.byName(name);
      if isempty(sF)
        sF = specimenFrame(name,'axesNames',axesNames);
        referenceFrame.byName(name,sF);
      end
    end

  end

end
