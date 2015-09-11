function m = s2v(s,m)
  %'[uvw]'
  %'(hkl)'
  %'[u1v1w1]\[u2v2w2]->'(hkl)'  a.k. zonen gleichung
  %'(h1k1l1)\(h1k1l1)->'[uvw]'
  %'[hkl](uww) ?
   
try
  i = @(str)  str2double(  regexp((char(str)),'-?\d','match'));
  token = '([,\\-\d]*)';
  braces  = regexp(s,token,'split');
  indices = regexp(s,token,'match');
    
  isuvw = false;
  if ~mod(numel(braces),2)
    s1 = strcmp('[',braces);
    s2 = strcmp(']',braces);
    isuvw = all(s1(1:2:end) == 1 & s2(2:2:end) == 1);
  end
      
  if  numel(indices)>2
    d = cross(i(indices{1}),i(indices{3}));
    isuvw = ~isuvw;
  else
    d = i(indices{1});
  end
  
  assert(numel(d) == 3 || numel(d) == 4);
  
  if isuvw
    if numel(d) == 3
      m.uvw = d;
    else
      m.UVTW = d;
    end
  else
    m.hkl = d;    
  end
  
catch e
  error('wrong syntax')
end

