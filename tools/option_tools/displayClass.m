function displayClass(obj,input)

disp(' ');

cl = class(obj);
disp([input ' = ' doclink([cl '_index'],cl) ' ' docmethods(input)]);
           
end

