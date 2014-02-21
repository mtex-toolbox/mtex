function display(odf,varargin)
% called by standard output

disp('  FEM portion:');
disp(['    center: ',int2str(length(odf.center))]);
disp(['    tetrahegons: ',int2str(size(odf.center.tetra,1))]);

end
