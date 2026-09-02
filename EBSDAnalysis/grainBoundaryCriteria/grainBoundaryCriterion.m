classdef (Abstract) grainBoundaryCriterion
% grainBoundaryCriterion Abstract base class for EBSD grain boundary criteria
%
% A grainBoundaryCriterion decides, for pairs of neighboring EBSD pixels,
% whether the edge between them is a grain boundary.
%
% The public API is
%
%   out = criterion.evaluate(ebsd,i,j)
%
% where i and j are equally sized arrays of neighboring pixel indices.
%
% The output out must have the same size as i and j. The convention is:
%
%   out = 1    no grain boundary
%   out = 0.5  low-angle grain boundary
%   out = 0    high-angle grain boundary
%
% Subclasses implement the protected method doEvaluate.
%
% Syntax
%   grains = calcGrains(ebsd,gbcAngle(10*degree))
%   out = criterion.eval(ebsd,i,j)
%   gbc = grainBoundaryCriterion.byOptions(varargin{:})
%   [A_Db,I_DG] = gbc.segment(ebsd,Dl,Dr)
%
% Input
%  ebsd - @EBSD
%  i, j - equally sized arrays of neighbouring pixel indices
%
% Output
%  out - one value per pair, between 0 and 1
%
% Derived Classes
%  @gbcAngle    - threshold on the misorientation angle
%  @gbcSoft     - a smooth transition instead of a threshold
%  @gbcFMC      - fast multiscale clustering
%  @gbcVariants - boundaries between variants of a parent grain
%  @gbcCustom   - criterion given by a function handle
%
% See also
% EBSD/calcGrains gbcAngle gbcFMC
%

methods

  function obj = prepare(obj,ebsd) %#ok<INUSD>
    % Optional preprocessing hook.
    %
    % Subclasses may overload this method if they want to cache data
    % derived from the EBSD object before evaluate is called repeatedly.
  end

  function out = eval(obj,ebsd,i,j)
    % Evaluate criterion on neighboring pixel pairs.
    %
    % Gridded data pads the lattice sites that hold no measurement with
    % phaseId = NaN (see EBSD/private/squarify), and every criterion picks
    % its pixels with a test of the form phaseId(i) == p. NaN compares
    % false against every phase, so pad cells matched no phase at all,
    % scored 0, and came out separated from each of their neighbours by a
    % boundary: a solid 5841 cell hole segmented into 5842 single-pixel
    % notIndexed grains instead of one. Marking the hole notIndexed by
    % hand, i.e. phaseId = 1 with the positions present, gave 6 grains on
    % the same map - so the two representations of "nothing was measured
    % here" disagreed, although spatialDecompositionGrid's help already
    % states they are treated identically.
    %
    % Normalising here rather than in calcGrains covers every caller
    % (doSegmentation, gridComponents for the minPixel pass, the quadruple
    % point merge, calcGrainsOld) and every subclass at once, and because
    % ebsd is passed by value it cannot leak back out - in particular the
    % NaN padding survives on whatever calcGrains returns, so EBSD(ebsd)
    % still strips it.
    %
    % Phase 1 as "notIndexed" is the same assumption calcGrains already
    % makes when the minPixel pass writes ebsd.phaseId(removed) = 1.
    isPad = isnan(ebsd.phaseId);
    if any(isPad), ebsd.phaseId(isPad) = 1; end

    out = obj.doEvaluate(ebsd,i,j);
  end

  function tf = handlesMinPixel(obj) %#ok<MANU>
    % Does this criterion enforce minPixel itself?
    %
    % calcGrains normally enforces minPixel with a whole extra
    % segmentation pass, which finds the undersized grains and marks their
    % pixels notIndexed. A criterion that already deals with undersized
    % regions internally answers true, and that pass - a second complete
    % evaluation of the criterion - is skipped.
    tf = false;
  end

  function obj = setMinPixel(obj,minPixel) %#ok<INUSD>
    % Hand minPixel to a criterion that answers true above.
    %
    % Does nothing by default, so a criterion only has to override this
    % together with handlesMinPixel.
  end

end

methods

  function [A_Db,I_DG] = segment(gbc,ebsd,Dl,Dr,varargin)
    % segment pairs of neighbouring cells into grains
    %
    % Input
    %  ebsd   - @EBSD
    %  Dl, Dr - index lists of neighbouring cells
    %
    % Output
    %  A_Db - adjacency matrix of cells with a grain boundary in between
    %  I_DG - incidence matrix cells -> grains
    %
    % Options
    %  mcl - [p maxIt] Markovian clustering of the connection weights

    connect = gbc.eval(ebsd,Dl,Dr);

    % adjacency of cells that have no common boundary
    ind = connect>0;
    A_Do = sparse(double(Dl(ind)),double(Dr(ind)),connect(ind),length(ebsd),length(ebsd));
    if check_option(varargin,'mcl')

      param = get_option(varargin,'mcl');
      if isempty(param), param = 1.4; end
      if isscalar(param), param = [param,4]; end

      A_Do = mclComponents(A_Do,param(1),param(2));
      A_Db = sparse(double(Dl),double(Dr),true,length(ebsd),length(ebsd));
      A_Db(A_Do~=0) = false;

    else

      % a boundary is drawn where the criterion says 0.5 or less - connect < 1 also
      % works for a criterion answering 0, 0.5 and 1, but not for a continuous one
      isBnd = connect <= 0.5;
      A_Db = sparse(double(Dl(isBnd)),double(Dr(isBnd)),true,...
        length(ebsd),length(ebsd));

    end
    A_Do = A_Do | A_Do.';
    A_Db = A_Db | A_Db.';

    I_DG = sparse(1:length(ebsd),double(connectedComponents(A_Do)),1);

  end

end

methods (Static)

  function gbc = byOptions(varargin)
    % the criterion selected by the calcGrains options - a criterion object
    % passed in always wins
    if check_option(varargin,{'fmc','FMC'})
      gbc = getClass(varargin,'grainBoundaryCriterion',gbcFMC(varargin{:}));
    elseif check_option(varargin,'soft')
      gbc = getClass(varargin,'grainBoundaryCriterion',gbcSoft(varargin{:}));
    elseif check_option(varargin,'variants')
      gbc = getClass(varargin,'grainBoundaryCriterion',gbcVariants(varargin{:}));
    elseif check_option(varargin,'grainId')
      gbc = getClass(varargin,'grainBoundaryCriterion',gbcCustom('grainId',0.5));
    else
      gbc = getClass(varargin,'grainBoundaryCriterion',gbcAngle(varargin{:}));
    end
  end

end

methods (Access = protected, Abstract)
  out = doEvaluate(obj,ebsd,i,j)
end

end