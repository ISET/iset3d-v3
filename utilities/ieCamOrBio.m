function r = ieCamOrBio
% Determine whether user has ISETCam or ISETBio on the path
%
% Syntax
%   r = ieCamOrBio
%
% Returns 'isetbio' or 'isetcam'
% Returns empty string ('') if neither isetbio nor isetcam is found. 
%
%
% Wandell, ISET Team 2018

s = which('ieInit');
s = lower(s);

if     contains(s,'isetbio'), r = 'isetbio';
elseif contains(s,'isetcam'), r = 'isetcam';
else,   r = '';
end

end
