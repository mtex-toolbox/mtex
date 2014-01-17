function doDisplay(odf,varargin)
% called by standard output

disp('  Radially symmetric portion:');
disp(['    kernel: ',char(odf.psi)]);
disp(['    center: ',char(odf.center)]);

end
