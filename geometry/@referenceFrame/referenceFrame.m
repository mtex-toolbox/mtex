classdef referenceFrame < handle
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
    % basis vectors in canonical coordinates, empty = identity, resolved in get.basis
    basis = []
    axesNames = {'X','Y','Z'}  % names of the three basis axes
    how2plot = []  % default plottingConvention (a value)
    sym = symmetry % the point group this frame carries
    opt = struct   % free-form extras, e.g. the density of a phase
  end

  properties (Dependent = true)
    % the default pole figure annotation of this frame, e.g. RD, TD, ND
    pfAnnotations

    % the group this frame carries, read through the frame - the reads that
    % used to go to a symmetry land here unchanged
    id          % point group id
    rot         % the symmetry elements
    pointGroup  % international symbol of the group
    lattice     % the lattice type the group implies
    multiplicityZ     % order of the symmetry axis along Z
    multiplicityPerpZ % highest order of an axis perpendicular to it
  end

  properties (Access = protected, Transient = true)
    % the siblings minted from this frame, as a struct array of id and
    % frame - one entry per group, so asking twice returns one handle.
    % Never saved: a sibling is reachable from the group it carries, and
    % storing the web would drag every relative of a frame into the file
    siblingRef = struct('id',{},'fr',{})
  end

  properties (Hidden = true)
    % a registered frame is sealed: what its identity is keyed on can no
    % longer be written, since an in place change would reach every dataset
    % sharing it. Name, colour and plotting convention stay open - nothing
    % numeric depends on them, and the session convention is meant to reach
    % the data that follows it
    sealed = false
  end

  properties (Hidden = true, Transient = true)
    % memo for WignerD: the coefficients follow from the group, and a group
    % is a value with nowhere to keep them. Never saved
    fhatRef = []
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
      rf.assertOpen('basis');
      assert(isa(v,'vector3d') && length(v) == 3,...
        'The basis of a reference frame has to be three vector3d.');
      rf.basis = reshape(v,1,3);
    end

    function set.sym(rf,s)
      rf.assertOpen('point group');
      rf.sym = s;
    end

    function set.axesNames(rf,n)
      rf.assertOpen('axes names');
      rf.axesNames = n;
    end

    function set.how2plot(rf,pC)
      % accept a string like 'y↑→x' as a shortcut, as symmetry does
      if ischar(pC) || isstring(pC), pC = plottingConvention(pC); end
      rf.how2plot = pC;
    end

    function v = get.id(rf), v = rf.sym.id; end
    function v = get.rot(rf), v = rf.sym.rot; end
    function v = get.pointGroup(rf), v = rf.sym.pointGroup; end
    function v = get.lattice(rf), v = rf.sym.lattice; end
    function v = get.multiplicityZ(rf), v = rf.sym.multiplicityZ; end
    function v = get.multiplicityPerpZ(rf), v = rf.sym.multiplicityPerpZ; end

    function fr = stripSym(rf)
      % the same frame with no symmetry claim in it
      %
      % Where the data lives is not dropped, only what is claimed about it -
      % the sibling of rule 7 that carries the trivial group.

      fr = sibling(rf,symmetry);
    end

    function f = get.pfAnnotations(rf)
      % a frame may name fewer axes than it has - annotate only the named ones
      names = rf.axesNames;
      b = normalize(rf.basis);
      b = b(1:numel(names));
      f = @(varargin) text(b,names,...
        'BackgroundColor','w','tag','axesLabels',varargin{:});
    end

    function assertOpen(rf,what)
      % a registered frame may not have its identity rewritten
      if rf.sealed
        error('MTEX:referenceFrame:sealed',...
          ['The %s of a registered reference frame cannot be changed - ' ...
          'every dataset holding it would change with it. Construct the ' ...
          'frame you want and let the register answer.'],what);
      end
    end

    function fr = clone(rf)
      % an unsealed frame with the same content, for the register to judge
      %
      % Not a public copy: a handle-distinct twin with identical numbers is
      % the fragmentation the register exists to prevent, so this is only
      % ever a step on the way to referenceFrame.intern.

      fr = feval(class(rf));
      fr.basis = rf.basis;
      fr.axesNames = rf.axesNames;
      fr.name = rf.name;
      fr.how2plot = rf.how2plot;
      fr.sym = rf.sym;
      fr.opt = rf.opt;
      if isprop(rf,'color'), fr.color = rf.color; end

    end

    function fr = sibling(rf,s)
      % this frame with s in it instead of its own group
      %
      % The basis and the identity are the same, so the two are the pair
      % rule 7 calls siblings. Minted once and cached on the frame it came
      % from, so asking twice gives one handle and the two stay comparable
      % - which is what the register takes over once its key carries the
      % group.

      if s.id == rf.sym.id, fr = rf; return; end

      hit = find([rf.siblingRef.id] == s.id,1);
      if ~isempty(hit), fr = rf.siblingRef(hit).fr; return; end

      fr = clone(rf);
      fr.sym = s;
      fr = referenceFrame.intern(fr);

      rf.siblingRef(end+1) = struct('id',s.id,'fr',fr);

    end

    function c = char(rf)
      if isempty(rf.name)
        c = class(rf);
      else
        c = rf.name;
      end
    end

    function display(rf,varargin)
      % the identity and the convention go in the header - together they
      % are what tells one frame from another, the way a symmetry shows
      % its point group there. The basis is the detail below

      info = {};
      if ~isempty(rf.name), info{end+1} = rf.name; end %#ok<AGROW>
      if isa(rf.how2plot,'plottingConvention')
        info{end+1} = conventionChar(rf); %#ok<AGROW>
      end

      displayClass(rf,inputname(1),'moreInfo',strjoin(info,', '),varargin{:});

      % a basis that is the canonical one says nothing the header does not -
      % only a frame that sits somewhere else is worth spelling out
      b = rf.basis;
      if max(norm(b - [xvector,yvector,zvector])) > 1e-10
        for k = 1:numel(rf.axesNames)
          disp(['  ' rf.axesNames{k} ': ' char(b(k))]);
        end
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
      % specimenFrame/measurement specimenFrame.specimenFrame

      persistent store
      if isempty(store), store = containers.Map; end

      name = char(name);
      if nargin == 1 && strcmp(name,'-reset-')
        % internal, used by referenceFrame.reset only
        store = containers.Map; rf = [];
      elseif nargin == 2
        store(name) = rf;
      elseif store.isKey(name)
        rf = store(name);
      else
        rf = [];
      end

    end

    function rf = intern(rf)
      % the session instance of this frame, which is this one when it is new
      %
      % Frame identity is provenance (ADR 0008 rule 2): two constructions
      % unify only when cell shape, alignment, group, name and convention all
      % agree. Anything else is a different frame, because a false merge of
      % two phases is invisible in the phase map while a false split surfaces
      % at the first attempt to combine them.
      %
      % Syntax
      %   rf = referenceFrame.intern(rf)
      %
      % See also
      % referenceFrame/byName referenceFrame/reintern

      % a cell array, not a frame array: assigning a crystalFrame into an
      % array typed referenceFrame slices it down to the base class, which
      % is the same constraint that makes the phase list heterogeneous
      persistent store

      if isempty(store), store = {}; end

      if ischar(rf) && strcmp(rf,'-reset-')
        store = {}; rf = []; return
      end

      for k = 1:numel(store)
        if sameEntity(store{k},rf), rf = store{k}; return; end
      end

      rf.sealed = true;
      store{end+1} = rf;

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
        % an unnamed crystal frame has no identity, so name the coordinate system
        if isempty(fr.name), c = 'crystal'; end
      else
        if ~isa(fr,'referenceFrame')
          % frame-free data resolves against the session default frame at
          % render time, so its labels apply here too
          fr = specimenFrame.default;
        end

        c = conventionChar(fr,pC);
        if isempty(c), c = char(pC); end
      end

      % clicking the header displays the frame itself - same pattern as
      % the crystal symmetry link in crystalSymmetry/char
      if ~getMTEXpref('generatingHelpMode')
        id = pushTemp(fr);
        c = ['<a href="matlab: display(pullTemp(' int2str(id) ...
          '),''variableName'',''frame'')">' c '</a>'];
      end

    end

    function reset
      % restore the pristine session frame state
      %
      % Forgets every registered frame and lets the session default fall
      % back to a fresh generic specimen frame with the ij convention - the
      % state a newly started MTEX session is in. Data objects keep the
      % frame handles they hold; only the register and the default are
      % affected. Meant for scripted environments that run independent
      % jobs in one session, e.g. the documentation build between pages.
      %
      % Syntax
      %   referenceFrame.reset
      %
      % See also
      % referenceFrame.referenceFrame specimenFrame.specimenFrame

      referenceFrame.byName('-reset-');
      referenceFrame.intern('-reset-');
      specimenFrame.default([]);

    end

    function rf = loadobj(rf)
      % a deserialized frame joins the session register when it agrees by
      % value, so separately saved datasets share one frame handle again
      rf = referenceFrame.reintern(rf);
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
      % referenceFrame.referenceFrame specimenSymmetry/loadobj vector3d/loadobj

      reg = referenceFrame.byName(rf.name);
      if ~isempty(reg) && strcmp(class(reg),class(rf)) && ...
          isAligned(rf,reg) && ~isempty(rf.how2plot) && ...
          ~isempty(reg.how2plot) && isapprox(rf.how2plot,reg.how2plot)
        % the registered instance in the group that was loaded - itself when
        % the groups agree, its sibling otherwise
        rf = sibling(reg,rf.sym);
      end

    end

  end

end
