function ip = piAcquisition2IP(acquisition,st)
% Render an IP from a PBRT acquisition rendering
%
% Syntax
%   ip = piAcquisition2IP(acquisition,st);
%
% Inputs
%  acquisition - Flywheel acquisition with all the relevant PBRT files
%  st - empty or a scitran object (will default to stanfordlabs)
%
% Key/val options
%  N/A
%
% Outputs
%  ip
%
% Wandell
%
% See also
%   piAcquisition2ISET (should be renamed), piFireFliesRemove, piOI2IP
%

% Examples:
%{
 st = scitran('stanfordlabs');
 acq = st.lookup('wandell/Graphics camera array/image alignment render/city3/pos_000_000_000');
 ip = piAcquisition2IP(acq,st);
 ipWindow(ip);
%}

%%
if notDefined('st'), st = scitran('stanfordlabs'); end
chdir(fullfile(piRootPath,'local'));

%% Set a session and acquisition
oi = piAcquisition2ISET(acquisition,st);

oi = piFireFliesRemove(oi);
% oiWindow(oi);

%% Convert the oi into an IP

ip = piOI2IP(oi);
% ipWindow(ip);

end
