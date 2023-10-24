function varargout = mode(q,varargin)
% mode of a list of quaternions, principle axes and moments of inertia
%
% Syntax
%
%   [m, lambda, V] = mode(q)
%   [m, lambda, V] = mode(q,'robust')
%   [m, lambda, V] = mode(q,'weights',weights)
%
% Input
%  q        - list of @quaternion
%  weights  - list of weights
%
% Output
%  m      - mode orientation
%  lambda - principle moments of inertia
%  V      - principle axes of inertia (@quaternion)
%
% See also
% orientation/mode


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
    %     qMode = mode([q.subSet(':').a q.subSet(':').b q.subSet(':').c q.subSet(':').d])

    %% calculate mode (not relying on MATLAB's in-built mode function)
    inArray = [q.subSet(':').a q.subSet(':').b q.subSet(':').c q.subSet(':').d];
    [uniqueRows,~,ic] = unique(inArray,'rows','stable');
    counts = accumarray(ic, 1);
    [~, maxIdx] = max(counts);
    qMode = uniqueRows(maxIdx, :);
    %%

    qm = quaternion(qMode(1,1),qMode(1,2),qMode(1,3),qMode(1,4));
    if nargout == 3
        %             [qm,lambda, V] = mode(q.subSet(id),varargin{:});
        varargout{1} = qm; varargout{2} = lambda; varargout{3} = V;
    else
        %             [qm,lambda] = mode(q.subSet(id),varargin{:});
        varargout{1} = qm; varargout{2} = lambda;
    end
end


