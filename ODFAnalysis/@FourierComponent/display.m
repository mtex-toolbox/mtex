function display(component,varargin)
% called by standard output

disp('  Harmonic portion:');
disp(['    degree: ',int2str(dim2deg(length(component.f_hat))-1)]);

end
