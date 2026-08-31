classdef S2Fun
% an abstract class representing functions on the sphere
%
% A spherical function carries the referenceFrame it is expressed in -
% empty means frame-free, resolved against the session default at render
% time. A frame that carries a point group says the function is symmetric
% under it, which is what hasSymmetry and getSym read.
%
% Deriving classes only have to implement the method eval, everything else
% - arithmetics, plotting, integration, extrema - is inherited from here.
%
% Class Properties
%  isReal   - the function takes only real values
%  frame    - @referenceFrame the function is expressed in
%  how2plot - @plottingConvention, read only
%
% Derived Classes
%  @S2FunHarmonic    - spherical harmonic series
%  @S2FunTri         - piecewise linear on a spherical triangulation
%  @S2FunHandle      - function given by a function handle
%  @S2FunBingham     - spherical Bingham distribution
%  @S2FunMLS         - moving least squares approximation
%
% See also
% S2FunHarmonic S2FunBingham S2FunTri

properties (Abstract = true)
  isReal
end

properties (Hidden = true)
  % the referenceFrame this function is expressed in, empty = frame-free
  framePrivate = []
end

properties (Dependent = true)
  frame    % the referenceFrame this function is expressed in
  how2plot % plotting convention - read only
  % a convention belongs to a reference frame, see plottingConvention.default
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


  function fr = get.frame(sF)
    fr = getFrame(sF);
  end

  function sF = set.frame(sF,fr)
    sF = setFrame(sF,fr);
  end

  function fr = getFrame(sF)
    % overloaded by S2FunMLS, whose frame is the one of its symmetry
    fr = sF.framePrivate;
  end

  function sF = setFrame(sF,fr)
    % overloaded by S2FunMLS, where assigning a frame is an error
    assert(isempty(fr) || isa(fr,'referenceFrame'), ...
      'The frame of an S2Fun has to be a referenceFrame or empty.');
    sF.framePrivate = fr;
  end

  function s = getSym(sF)
    % the group a symmetric function is invariant under - the group its
    % frame carries, empty for a function written in a group free frame
    s = [];
    if hasSymmetry(sF), s = sF.frame; end
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
     % the frame the arguments name: a frame, or the frame of a convention
     fr = getClass(varargin,{'referenceFrame','plottingConvention'});
     if isa(fr,'plottingConvention'), fr = specimenFrame.frameFor(fr); end
   end

   function fr = jointFrame(sF1,sF2,fr)
     % the frame a binary operation writes its result in: the given frame,
     % carrying a group only where both operands are invariant under one

     sym = S2Fun.jointSym(sF1,sF2);
     if ~isempty(sym)
       fr = sym;
     elseif ~isempty(fr)
       fr = stripSym(fr);
     end
   end

   function s = jointSym(sF1,sF2)
     % the symmetry a binary operation may keep: the largest group both
     % operands are invariant under, empty as soon as one of them is not
     % symmetrised

     s = [];
     if isnumeric(sF1) && isa(sF2,'S2Fun')
       s = getSym(sF2);
     elseif isa(sF1,'S2Fun') && isnumeric(sF2)
       s = getSym(sF1);
     elseif isa(sF1,'S2Fun') && isa(sF2,'S2Fun')
       s1 = getSym(sF1); s2 = getSym(sF2);
       if ~isempty(s1) && ~isempty(s2), s = disjoint(s1,s2); end
     end
   end

 end

end
