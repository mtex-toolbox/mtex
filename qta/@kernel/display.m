function display(k)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('kernel_index','kernel')]);
disp(['  type: ',char(k(1))]);
for i = 2:length(k)
    disp(['  type: ',char(k(i))]);
end

if get_mtex_option('mtexMethodsAdvise',true)
  disp(' ')
  disp(['    <a href="matlab:docmethods(' inputname(1) ')">Methods</a>'])
end
disp(' ');
