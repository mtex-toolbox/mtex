function display(component,varargin)
% called by standard output

disp('  strain component:');
disp(['    slip system: ',char(component.sS.n),char(component.sS.b)]);

end
