function display(odf,varargin)
% called by standard output

disp('  Fibre symmetric portion:');
disp(['    kernel: ',char(odf.psi)]);
disp(['    fibre: ',char(odf.h),' - ' char(odf.r)]);

end
