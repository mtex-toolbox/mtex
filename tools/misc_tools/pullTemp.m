function obj = pullTemp(id)

tmp = getappdata(0,'tmpData');

obj = tmp.data{id};

end