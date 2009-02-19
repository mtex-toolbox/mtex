function T = qq(q,varargin)
% returns w * q' * q
% 
%% Input
%  q - list of quaternions
%  w - list of weights

q = reshape(q,1,[]);

% weigths
w = get_option(varargin,'weights',ones(1,numel(q)));
w = reshape(w,1,[]);
w = w./sum(w);
w = repmat(w,4,1);

ql = [q(:).a; q(:).b; q(:).c; q(:).d];
qr = transpose(ql);

T = w(:,1:numel(q)).*ql*qr;
