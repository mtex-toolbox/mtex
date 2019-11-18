function [odf,alpha] = calcODF(solver,varargin)

% apply zero range method
if ~isempty(solver.zrm)
  solver.S3G = subGrid(solver.S3G,~solver.zrm.checkZeroRange(solver.S3G));
end

% initalize solver
solver.init;

% get max iterations and min iterations 
solver.iterMax = get_option(varargin,'iterMax',10);
solver.iterMin = get_option(varargin,'iterMin',5);
if solver.iterMax < solver.iterMin
    solver.iterMax=solver.iterMin;
end
% display
format = [' %s |' repmat('  %1.2f',1,solver.pf.numPF) '\n'];

do_iterate;

% extract result
odf = solver.odf;
alpha = solver.alpha;

% ---------------- ghost correction ----------------------------

% determine phon
phon = min(cellfun(@(x) quantile(max(0,x(:)),0.01), solver.pf.allI) ./ solver.alpha);

if phon > 0.99
  odf = uniformODF(solver.CS,solver.SS);
  return
elseif phon > 0.1 && ~check_option(varargin,'noGhostCorrection')
  vdisp(['  I''m going to apply ghost correction. Uniform portion fixed to ',xnum2str(phon)],varargin{:});
else
  return
end

% subtract uniform portion from intensities
solver.pf = max(0,solver.pf - alpha .* phon);

% reset solution
solver.c = [];

do_iterate;

% return ODF
odf = phon * uniformODF(solver.CS,solver.SS) + (1-phon) * solver.odf;

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