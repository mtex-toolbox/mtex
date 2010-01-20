function o = symmetrice(o)	
% all crystallographically equivalent orientations


o.quaternion = reshape(reshape(o.SS * o.quaternion,[],1) * o.CS.',...
  [length(o.SS) numel(o.i) length(o.CS)]);
o.quaternion = permute(o.quaternion,[3 1 2]); % -> CS x SS x g1
o.i = repmat(o.i,length(o.SS) * length(o.CS),1);
