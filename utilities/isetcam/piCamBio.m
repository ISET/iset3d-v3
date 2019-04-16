function iset = piCamBio()
% Returns a string that indicates ISETCam or ISETBio on the path
%
% Synopsis
%    str= piCamBio;
%
% Inputs
%   N/A
%
% Optional Key/value pairs
%   N/A
%
% Returns
%   String - isetcam, isetbio, or an empty string if neither
%
%
% BW ISET Team, 2018

%{
   piCamBio
%}
rPath = which('isetRootPath');

% Figure it out
if piContains(rPath,'isetbio'),     iset = 'isetbio';
elseif piContains(rPath,'isetcam'), iset = 'isetcam';
else,                               iset = '';
end

end
