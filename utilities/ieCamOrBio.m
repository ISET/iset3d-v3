function r = ieCamOrBio
% Determine whether user has ISETCam or ISETBio on the path
%
% Syntax:
%   r = ieCamOrBio
%
% Inputs:
%    None.
%
% Outputs:
%    r - String. Returns 'isetbio' or 'isetcam' depending on which of the
%        options is on the path, or '' if none are.
%

% History:
%    XX/XX/18  BW   Wandell, ISET Team 2018
%    04/02/19  JNM  Documentation pass.

s = which('ieInit');
s = lower(s);

if contains(s,'isetbio'), r = 'isetbio';
elseif contains(s,'isetcam'), r = 'isetcam';
else, r = '';
end

end
