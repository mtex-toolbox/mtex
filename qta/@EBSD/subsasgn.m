function nobj = subsasgn(obj, S, B)

if length(S)>1
  error('Bad EBSD reference operation.');
end
%   
if strcmp( S(1).type, '()')
   n = S(1).subs;
   if ~isempty(B) 
     nobj = obj;
     nobj.comment = B.comment;
     nobj.orientations(n{1}) = B.orientations;
     nobj.xy(n{1}) = B.xy;
     nobj.phase(n{1}) = B.phase;
     nobj.grainid(n{1}) = B.grainid;

     vname = fields(obj.options);
     for k=1:length(vname)
       nobj.options(1).(vname{k})(n{1}) = B.options(1).(vname{k});
     end
   else
     id =  true(numel(obj),1);
     id(n{1}) = false; 
     nobj = subsref(obj,substruct('()',{id}));
   end
end
