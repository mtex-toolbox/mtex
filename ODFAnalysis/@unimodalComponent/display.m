function display(component,varargin)
% called by standard output

disp('  Radially symmetric portion:');
disp(['    kernel: ',char(component.psi)]);
disp(['    center: ',char(component.center)]);

end
