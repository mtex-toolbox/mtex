function nobj = subsref(obj, S)

if length(S)>1
  error('Bad EBSD reference operation.');
end
  
if strcmp( S(1).type, '()')
  n = S(1).subs;
  nobj = obj;
  nobj.comment = obj.comment;
  nobj.orientations = obj.orientations(n{1});
  if ~isempty(obj.xy), nobj.xy = obj.xy(n{1});end
  nobj.phase = obj.phase(n{1});
  if ~isempty(obj.grainid), nobj.grainid = obj.grainid(n{1});end

  vname = fields(obj.options);
  for k=1:length(vname)
    nobj.options(1).(vname{k}) = obj.options(1).(vname{k})(n{1});
  end
  
  if length(n) > 1    
    if isa(n{2},'logical'), 
      id = find(n{2});
    elseif isa(n{2},'char'), 
      id = 1:size(nobj,2);
    else
      id = n{2};
    end
    
    cs = cumsum([0,length(nobj)]);
    for i= 1:numel(nobj)

      idi = id((id > cs(i)) & (id<=cs(i+1)));

      if ~isempty(nobj.xy), nobj.xy{i} = nobj.xy{i}(idi-cs(i),:) ;end
      if ~isempty(nobj.grainid), nobj.grainid{i} = nobj.grainid{i}(idi-cs(i));end
      %if ~isempty(ebsd(i).phase), ebsd(i).phase(idi-cs(i)) = [];end
      nobj.orientations(i) = subGrid(nobj.orientations(i),idi-cs(i));

      vname = fields(nobj.options);
      for k=1:length(vname)
        nobj.options(1).(vname{k}){i} = nobj.options(1).(vname{k}){i}(idi-cs(i),:);
      end
    end    
  end 
  
  else 
    error('wrong indexing')
  end
end
