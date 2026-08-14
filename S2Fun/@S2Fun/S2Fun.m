classdef S2Fun
% an abstract class representing functions on the sphere
%
% A spherical function carries the referenceFrame it is expressed in -
% empty means frame-free, resolved against the session default at render
% time. Symmetry is deliberately not part of this class: only
% @S2FunHarmonicSym represents a symmetrised function and holds a
% symmetry, whose frame it exposes here.
%
% See also
% S2FunHarmonic S2FunBingham S2FunTri

properties (Abstract = true)
  isReal
end

properties (Hidden = true)
  % the referenceFrame this function is expressed in; empty = frame-free.
  % The public view is the dependent property frame, which resolves
  % through getFrame/setFrame so that S2FunHarmonicSym can couple its
  % frame to the one of its symmetry. Only frames carry plotting
  % conventions - there is no per object convention slot.
  framePrivate = []
end

properties (Dependent = true)
  frame    % the referenceFrame this function is expressed in
  how2plot % plotting convention
end


methods (Abstract = true)
  f = eval(sF,v,varargin)
end

methods

  function pC = get.how2plot(sF)
    % the convention of the frame, or the session default - only frames
    % carry conventions
    pC = [];
    if ~isempty(sF.frame), pC = sF.frame.how2plot; end
    if isempty(pC), pC = plottingConvention.default; end
  end

  function sF = set.how2plot(sF,pC)
    % accept a string like 'y↑→x' as a shortcut, as symmetry does
    if ischar(pC) || isstring(pC), pC = plottingConvention(pC); end

    if isempty(pC)
      % no convention claim - back to frame-free
      sF = setFrame(sF,[]);
    else
      % only frames carry conventions: the session frame when pC is the
      % convention it carries, an unregistered fork otherwise. On a
      % class whose frame is fixed (S2FunHarmonicSym) this errors -
      % assign the symmetry sF.s instead.
      sF = setFrame(sF,specimenSymmetry.frameFor(pC));
    end
  end

  function fr = get.frame(sF)
    fr = getFrame(sF);
  end

  function sF = set.frame(sF,fr)
    sF = setFrame(sF,fr);
  end

  function fr = getFrame(sF)
    % overloaded by S2FunHarmonicSym, whose frame is the one of its
    % symmetry
    fr = sF.framePrivate;
  end

  function sF = setFrame(sF,fr)
    % overloaded by S2FunHarmonicSym, where assigning a frame is an error
    assert(isempty(fr) || isa(fr,'referenceFrame'), ...
      'The frame of an S2Fun has to be a referenceFrame or empty.');
    sF.framePrivate = fr;
  end

  function s = getSym(sF) %#ok<MANU>
    % the symmetry of a symmetrised function, empty for everything else -
    % overloaded by S2FunHarmonicSym
    s = [];
  end

  function n = numel(sF)
    n = prod(size(sF)); %#ok<PSIZE>
  end

  function sF = power(sF1,sF2)
    %
    % Syntax
    %   sF = sF1.^a
    %

    if isnumeric(sF1)

      sF = S2FunHandle(@(v) sF1 .^ eval(sF2, v), sF2.frame);

    elseif isnumeric(sF2)

      sF = S2FunHandle(@(v) eval(sF1, v) .^ sF2, sF1.frame);

    else

      sF = S2FunHandle(@(v) eval(sF1, v) .^ eval(sF2, v), sF2.frame);

    end

  end

 end


 methods (Static = true)

   s2F = smiley(varargin)
   s2F = unimodal(v,varargin)

   function fr = extractFrame(varargin)
     % the frame named by the arguments: a referenceFrame wins, a
     % symmetry contributes its frame, otherwise empty (frame-free)
     fr = getClass(varargin,'referenceFrame');
     if isempty(fr)
       sym = getClass(varargin,'symmetry');
       if ~isempty(sym), fr = sym.frame; end
     end
   end

 end

end
