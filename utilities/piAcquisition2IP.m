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
 group = 'wandell';
 project = 'Graphics camera array';
 subject = 'image alignment render';
 % session = 'city3_13:00_v4.5_f7.00rear_o270.00_2019626181215';
 session = 'city3_11:16_v12.0_f47.50front_o270.00_2019626181423';

 acquisition = 'pos_000_000_000';
 acquisition = 'pos_200_000_000';
 acquisition = 'pos_453_000_000';
 acquisition = 'pos_132_000_000';

 str = sprintf('%s/%s/%s/%s/%s',group,project,subject,session,acquisition);
 acq = st.lookup(str);
 oi = piAcquisition2ISET(acq,st);
 oiWindow(oi); oiSet(oi,'displaymode','hdr');
 % rgb = oiGet(oi,'rgb'); ieNewGraphWin; imagescRGB(rgb);
 % title(oiGet(oi,'name'));
 
 % ip = piAcquisition2IP(acq,st);
 % ipWindow(ip);
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
