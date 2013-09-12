function doDisplay(odf,varargin)
% called by standard output

disp('  FEM portion:');
disp(['    center: ',int2str(length(odf.center))]);
disp(['    tetrahegons: ',int2str(length(odf.center.A_tetra))]);

end
