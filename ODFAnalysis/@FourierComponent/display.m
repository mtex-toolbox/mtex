function display(component,varargin)
% called by standard output

disp('  Portion specified by Fourier coefficients:');
disp(['    degree: ',int2str(dim2deg(length(component.f_hat)))]);

end
