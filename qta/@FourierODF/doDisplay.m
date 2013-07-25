function doDisplay(odf,varargin)
% called by standard output

disp('  Portion specified by Fourier coefficients:');
disp(['    degree: ',int2str(dim2deg(length(odf.f_hat)))]);

end
