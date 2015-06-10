function Vo = camview(varargin)
%CAMVIEW  Records or sets the viewpoint of the current axes
%
%   Vo = camview([hAx], [Vi])
%
% Records or sets the viewpoint of the current axes, including projection
% type. This is useful for giving multiple axes (with the same coordinate
% frame) the same viewpoint, or resetting the viewpoint to a known point.
% A data aspect ratio of [1 1 1] is assumed.
%
% The view is recorded and set using a 4x4 matrix. The upper 3x4 quadrant
% of this matrix is a projection matrix from the axes coordinate frame to
% the camera coordinate frame (the view frustrum coordinates range from -1
% to 1 in x and y directions). Padding the last row with [0 0 0 1] makes it
% possible to use projection matrices computed externally.
%
% IN:
%    hAx - Handle to the axes in question. Default: gca.
%    Vi - 4x4 matrix defining the viewpoint to set the current axes to. The
%         matrix should defined by calling camview on previous axes.
%
% OUT:
%    Vo - 4x4 matrix specifying the viewpoint of the current axes just
%         prior to the function being called.

% Set default inputs
hAx = gca;
Vi = [];
% Parse the inputs
for a = 1:nargin
    if ishandle(varargin{a})
        hAx = varargin{a};
    else
        Vi = varargin{a};
    end
end

if nargout > 0
    % Get the current viewpoint       
    t = get(hAx, 'CameraPosition');
    d = get(hAx, 'CameraTarget') - t;
    K = eye(3);
    K([1 5]) = 1 / tan(get(hAx, 'CameraViewAngle') * pi / 360);
    R(:,3) = d / norm(d);
    R(:,2) = get(hAx, 'CameraUpVector');
    R(:,1) = cross(R(:,3), R(:,2));
    Vo = K * R' * [eye(3) -t'];
    Vo(4,:) = [norm(d) 0 0 strcmp(get(hAx, 'Projection'), 'perspective')];
end
if ~isempty(Vi)
    % Decompose the projection matrix
    st = @(M) M(end:-1:1,end:-1:1)';
    [R, K] = qr(st(Vi(1:3,1:3)));
    K = st(K);
    I = diag(K) < 0;
    K(:,I) = -K(:,I);
    R = st(R);
    R(I,:) = -R(I,:);
    t = (K * R) \ -Vi(1:3,4);
    K = K / K(3,3);
        
    % Set the current viewpoint
    projection = {'perspective', 'orthographic'};
    set(hAx, 'CameraTarget', t'+R(3,:)*(Vi(4)+(Vi(4)==0)), ...
             'CameraPosition', t, ...
             'CameraUpVector', R(2,:), ...
             'CameraViewAngle', atan(1/K(5))*360/pi, ...
             'Projection', projection{(Vi(16)==0)+1});
end
return