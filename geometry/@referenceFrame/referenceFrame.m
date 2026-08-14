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
    how2plot = []  % default plottingConvention (handle)
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
      disp(['  basis: ' char(rf.basis(1)) ', ' char(rf.basis(2)) ', ' char(rf.basis(3))]);
      if isa(rf.how2plot,'plottingConvention')
        disp(['  how2plot: ' char(rf.how2plot,'compact')]);
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

    function rf = reintern(rf)
      % swap a deserialized frame for the registered instance of its name
      % when the two agree by value - so separately saved datasets share
      % one frame handle again after loading; a frame that differs (e.g.
      % saved under another default convention) is kept as it is
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
