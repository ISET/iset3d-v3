function iset = piCamBio()
% Returns a string that indicates ISETCam or ISETBio on the path
%
% Syntax:
%    iset = piCamBio;
%
% Description:
%    Returns a string indicating whether ISETBio or ISETCam is installed.
%
% Inputs:
%    None.
%
% Outputs:
%    iset - String. One of the following strings will be returned:
%       'isetbio': ISETBio is installed.
%       'isetcam': ISETCam is installed.
%       '':        Neither ISETBio or ISETCam is installed.
%
% Optional key/value pairs:
%   None.
%

% History:
%    XX/XX/18  BW   ISET Team, 2018
%    04/01/19  JNM  Documentation pass

% Examples:
%{
    piCamBio
%}

rPath = which('isetRootPath');

% Figure it out
if piContains(rPath,'isetbio'), iset = 'isetbio';
elseif piContains(rPath,'isetcam'), iset = 'isetcam';
else, iset = '';
end

end
