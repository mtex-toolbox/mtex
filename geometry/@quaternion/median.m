function varargout = median(q,varargin)
% median of a list of quaternions, principle axes and moments of inertia
%
% Syntax
%
%   [m, lambda, V] = median(q)
%   [m, lambda, V] = median(q,'robust')
%   [m, lambda, V] = median(q,'weights',weights)
%
% Input
%  q        - list of @quaternion
%  weights  - list of weights
%
% Output
%  m      - median orientation
%  lambda - principle moments of inertia
%  V      - principle axes of inertia (@quaternion)
%
% See also
% orientation/median


qm = q;

if isempty(q) || all(isnan(q.a(:)))

    [qm.a,qm.b,qm.c,qm.d] = deal(nan,nan,nan,nan);
    lambda = [0 0 0 1];
    if nargout == 3, V = nan(4); end
    return
elseif length(q) == 1
    lambda = [0 0 0 1];
    if nargout == 3
        T = qq(q,varargin{:});
        [V, lambda] = eig(T);
        lambda = diag(lambda).';
    end
    return
end

% shall we apply the robust algorithm?
isRobust = check_option(varargin,'robust');
if isRobust, varargin = delete_option(varargin,'robust'); end

T = qq(q,varargin{:});
[V, lambda] = eig(T);
lambda = diag(lambda).';
[~,pos] = max(lambda);

VV = V(:,pos);
qm.a = VV(1); qm.b = VV(2); qm.c = VV(3); qm.d = VV(4);
if isa(qm,'rotation'), qm.i = false; end

if ~isRobust && length(q)>=4
    %     omega = angle(qm,q,'noSymmetry');
    %     id = omega <= quantile(omega,0.8)*2.5;
    %     if all(id), return; end
        qMedian = median([q.subSet(':').a q.subSet(':').b q.subSet(':').c q.subSet(':').d]);

%     %% calculate median (not relying on MATLAB's in-built median function)
%     inArray = [q.subSet(':').a q.subSet(':').b q.subSet(':').c q.subSet(':').d];
%     [~,idx] = sortrows(inArray);
%     num = length(inArray);
%     if rem(num,2) == 0 % even numbered array
%         idx = idx(floor(num/2):floor(num/2)+1);
%         qMedian = mean(inArray(idx,:));
%     else
%         % odd numbered array
%         idx = idx(floor(num/2)+1);
%         qMedian = inArray(idx,:);
%     end
    %%

    qm = quaternion(qMedian(1,1),qMedian(1,2),qMedian(1,3),qMedian(1,4));
    if nargout == 3
        %     [qm,lambda, V] = median(q.subSet(id),varargin{:});
        varargout{1} = qm; varargout{2} = lambda; varargout{3} = V;
    else
        %     [qm,lambda] = median(q.subSet(id),varargin{:});
        varargout{1} = qm; varargout{2} = lambda;
    end
end


