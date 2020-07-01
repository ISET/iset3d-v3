function [tf, iset] = piCamBio()
% Returns a string that indicates ISETCam or ISETBio on the path
%
% Synopsis
%    [tf,str]= piCamBio;
%
% Inputs
%   N/A
%
% Optional Key/value pairs
%   N/A
%
% Returns
%   tf:  True if isetcam, false if isetbio, false if neither
%   String - isetcam, isetbio, or an empty string if neither
%
% BW ISET Team, 2018
%
% See also
%

%{
   piCamBio
%}
rPath = which('isetRootPath');

% Figure it out
if piContains(rPath,'isetbio'),     iset = 'isetbio'; tf = false;
elseif piContains(rPath,'isetcam'), iset = 'isetcam'; tf = true;
else,                               warning('Neither'); iset = ''; tf = false;
end

end
