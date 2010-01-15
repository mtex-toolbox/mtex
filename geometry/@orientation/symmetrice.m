function o = symmetrice(o)	
% all crystallographically equivalent orientations


o.quaternion = reshape(reshape(o.ss * o.quaternion,[],1) * o.cs.',...
  [length(o.ss) numel(o.i) length(o.cs)]);
o.quaternion = permute(o.quaternion,[3 1 2]); % -> CS x SS x g1
o.i = repmat(o.i,length(o.ss) * length(o.cs),1);
