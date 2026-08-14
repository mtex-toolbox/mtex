classdef referenceFrame < matlab.mixin.Copyable
% a reference frame - an identity, a basis and a default plotting convention
%
% A reference frame answers "what coordinate system is this data expressed
% in". It carries an identity (a name like 'measurement' or 'rolling' or a
% mineral), the basis vectors of the frame in canonical Euclidean
% coordinates, and the default plotting convention used to draw data of
% this frame on screen. The transition between two frames is computed by
% <referenceFrame.transformationMatrix.html |transformationMatrix|>.
%
% See docs/adr/0003-reference-frame-vs-symmetry.md for the model:
% @crystalSymmetry and @specimenSymmetry keep their public API and delegate
% their frame data (|axes|, |how2plot|) to a frame they hold.
%
% Syntax
%
%   rf = referenceFrame(basis)
%   rf = referenceFrame(basis,'name','measurement')
%
% Input
%  basis - 1x3 @vector3d, the basis vectors, not necessarily normalized
%
% Class Properties
%  name     - identity of the frame: 'measurement', 'rolling', a mineral, ...
%  basis    - 1x3 @vector3d in canonical coordinates, lengths are meaningful
%  how2plot - the default @plottingConvention of this frame
%
% See also
% crystalFrame specimenFrame crystalSymmetry specimenSymmetry plottingConvention

  properties
    name = ''      % identity of the frame
    % basis vectors in canonical coordinates; stored empty for the
    % canonical identity basis and resolved lazily in get.basis - a
    % vector3d default here would recurse through vector3d's own class
    % default how2plot -> plottingConvention.default -> specimenSymmetry
    % -> specimenFrame while the vector3d class is still initializing
    basis = []
    axesNames = {'X','Y','Z'}  % names of the three basis axes
    how2plot = []  % default plottingConvention (a value)
  end

  properties (Constant, Hidden)
    % the tolerances currently scattered over the tree - named here so the
    % comparisons can be rerouted onto one definition step by step
    tolAligned    = 5e-2   % same frame: phaseItem/eqTolPair, crystalSymmetry/eqLazy
    tolCompatible = 1e-1   % transformable frame: symmetry/ensureCS
  end

  methods

    function rf = referenceFrame(varargin)

      if nargin == 0, return; end

      if isa(varargin{1},'vector3d')
        rf.basis = varargin{1};
        varargin(1) = [];
      end

      rf.name = get_option(varargin,'name','');
      rf.axesNames = get_option(varargin,'axesNames',rf.axesNames);

      pC = getClass(varargin,'plottingConvention');
      if ~isempty(pC), rf.how2plot = pC; end

    end

    function v = get.basis(rf)
      v = rf.basis;
      if isempty(v), v = [xvector,yvector,zvector]; end
    end

    function set.basis(rf,v)
      assert(isa(v,'vector3d') && length(v) == 3,...
        'The basis of a reference frame has to be three vector3d.');
      rf.basis = reshape(v,1,3);
    end

    function set.how2plot(rf,pC)
      % accept a string like 'y↑→x' as a shortcut, as symmetry does
      if ischar(pC) || isstring(pC), pC = plottingConvention(pC); end
      rf.how2plot = pC;
    end

    function c = char(rf)
      if isempty(rf.name)
        c = class(rf);
      else
        c = rf.name;
      end
    end

    function display(rf,varargin)
      displayClass(rf,inputname(1),varargin{:});
      if ~isempty(rf.name), disp(['  name: ' rf.name]); end
      b = rf.basis;
      for k = 1:3
        disp(['  ' rf.axesNames{k} ': ' char(b(k))]);
      end
      if isa(rf.how2plot,'plottingConvention')
        disp(['  how2plot: ' conventionChar(rf)]);
      end
      disp(' ');
    end

  end

  methods (Static = true)

    function rf = byName(name,rf)
      % the register: look up or store the session instance of a named frame
      %
      % The register holds one canonical instance per name; the named
      % factories (specimenFrame.measurement, .rolling, ...) construct on
      % first use and store here, so every later call returns the same
      % handle. Forks made by data-level setters are deliberately not
      % registered - the register owns the entity, the forks are private.
      %
      % Syntax
      %   rf = referenceFrame.byName('rolling')  % lookup, [] when unknown
      %   referenceFrame.byName('rolling',rf)    % store rf under the name
      %
      % Input
      %  name - char
      %  rf   - @referenceFrame
      %
      % See also
      % specimenFrame/measurement specimenFrame/default

      persistent store
      if isempty(store), store = containers.Map; end

      name = char(name);
      if nargin == 2
        store(name) = rf;
      elseif store.isKey(name)
        rf = store(name);
      else
        rf = [];
      end

    end

    function c = headerChar(fr,pC)
      % the string data class displays show: the frame together with the
      % plotting convention the data is drawn in
      %
      % For a crystal frame only the frame identity is shown - the
      % convention of a crystal frame is derived from its axes and adds
      % nothing. For a specimen frame the convention appears in the
      % frame's axes names ('TD←RD↑'); frame-free data shows the plain
      % convention.
      %
      % Input
      %  fr - @referenceFrame or []
      %  pC - @plottingConvention, the resolved convention of the data

      if isa(fr,'crystalFrame')
        c = char(fr);
        return
      elseif ~isa(fr,'referenceFrame')
        % frame-free data resolves against the session default frame at
        % render time, so its labels apply here too
        fr = specimenFrame.default;
      end

      c = conventionChar(fr,pC);
      if isempty(c), c = char(pC,'compact'); end

    end

    function rf = reintern(rf)
      % swap a deserialized frame for the registered instance of its name
      % when the two agree by value - so separately saved datasets share
      % one frame handle again after loading. A frame with a different
      % convention keeps its own fork: applying a loaded convention to
      % the whole session is the business of the CONTAINER (EBSD,
      % PoleFigure) whose positions state the intent - the individual
      % vectors of a file carry incidental conventions of the saving
      % session, and letting each of them repoint the register would make
      % the outcome depend on the load order within the file.
      %
      % See also
      % referenceFrame/byName specimenSymmetry/loadobj vector3d/loadobj

      reg = referenceFrame.byName(rf.name);
      if ~isempty(reg) && strcmp(class(reg),class(rf)) && ...
          isAligned(rf,reg) && ~isempty(rf.how2plot) && ...
          ~isempty(reg.how2plot) && isapprox(rf.how2plot,reg.how2plot)
        rf = reg;
      end

    end

  end

end
