function [odf,alpha] = calcODF(solver,varargin)

% apply zero range method
if ~isempty(solver.zrm)
  solver.S3G = subGrid(solver.S3G,~solver.zrm.checkZeroRange(solver.S3G));
end

% initialize solver
solver.init;

% get max iterations and min iterations 
solver.iterMax = get_option(varargin,'iterMax',solver.iterMax);
solver.iterMin = get_option(varargin,'iterMin',solver.iterMin);
if solver.iterMax < solver.iterMin
    solver.iterMax=solver.iterMin;
end

% display
format = [' %s |' repmat('  %1.2f',1,solver.pf.numPF) '\n'];

do_iterate;

% extract alpha - this might change during ghost correct - this is the
% correct one
alpha = solver.alpha;

% ---------------- ghost correction ----------------------------

% determine background (phon)
c0 = min(cellfun(@(x) quantile(max(0,x(:)),0.01), solver.pf.allI) ./ alpha(1:length(solver.pf.allI)));

if c0 > 0.1 && c0 < 0.99 && ~check_option(varargin,'noGhostCorrection')
  vdisp("  I''m going to apply ghost correction." + newline + "  Uniform portion fixed to c0 = " + xnum2str(c0),varargin{:});

  % subtract uniform portion from intensities
  solver.pf = max(0,solver.pf - alpha .* c0);
  solver.c0 = c0;

  % reset solution
  solver.c = [];

  do_iterate;

end

% extract result
odf = solver.odf;

% ---------------------- the main loop --------------------------
  function do_iterate

    solver.initIter;
    % compute residual error
    
    iter = 0;
    lasterr = showError;
    for iter = 1:solver.iterMax
  
      % one step
      solver.doIter;
  
      % compute residual error
      err = showError;
      if (lasterr-err)/err < 0.05 && iter > solver.iterMin, break; end
      lasterr = err;
    end
    
    function e = showError
      for i = 1:solver.pf.numPF
        e(i) = norm(solver.u{i}) ./ norm(solver.pf.allI{i}(:) .*solver.weights{i} );
      end
      if ~check_option(varargin,'silent') && ~getMTEXpref('generatingHelpMode')
        fprintf(format,xnum2str(iter,'fixedWidth',2),e);
      end
      e = sqrt(sum(e.^2));
    end
    
  end
% -------------------------------------------------------------------
end