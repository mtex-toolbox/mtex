function display(o)
% standart output

disp(' ');
s = [inputname(1) ' = '];
if ~isa(o.SS,'symmetry') || ~isa(o.CS,'symmetry')
  s = [s 'invalid misorientation'];
  disp(s);
  disp([' size: ' size2str(o)]);
  return
elseif isMisorientation(o)
  s = [s doclink('orientation_index','misorientation')];
elseif isa(o.SS,'crystalSymmetry')
  s = [s doclink('orientation_index','inverse orientation')];  
else
  s = [s doclink('orientation_index','orientation')];
end
  
disp([s ' ' docmethods(inputname(1))]);

disp(['  size: ' size2str(o)]);
disp(char(o.CS,'verbose','symmetryType'));
disp(char(o.SS,'verbose','symmetryType'));

if o.antipodal
  disp('  antipodal:         true');
end
  

if length(o) < 20 && ~isempty(o)
  Euler(o);
else
  %disp('  <a href="matlab:Euler(o)">show Euler angles</a>')
  disp(' ')
end


