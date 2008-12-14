function T = qq(q,varargin)
% returns w * q' * q
% 
%% Input
% q - list of quaternions
% varargin - list of weights

q = reshape(q,1,[]);

if ~isempty(varargin)
    w = reshape(varargin{1},1,[]);
    w = w./sum(w);
    w = repmat(w,4,1);
else
    w = ones(4,numel(q))./numel(q);
end

ql = [q(:).a; q(:).b; q(:).c; q(:).d];
qr = transpose(ql);

T = w(:,1:numel(q)).*ql*qr;
