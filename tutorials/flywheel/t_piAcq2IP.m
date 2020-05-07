%% Convert rendered data to an ISETCam image processing (IP) struct
%
% Description
%   Find a Flywheel acquisition with data that were rendered using PBRT. 
%   Download the rendered data and assemble them into an ISETCam IP,
%   including the metadata.
%
%   We can save these locally for zipping and handing out to students.
%   For example we created AlignmentData.zip file on the Canvas site.
%
% See also
%   t_piFlywheelRender, s_piAlignmentRender, s_piStereoImage
%
% Wandell, 12/2019

%% Channel to Flywheel
st = scitran('stanfordlabs');

%% Specify the acquisition with the rendered data

inGroup   = 'wandell';
inProject = st.lookup('wandell/Graphics test');
inSubject = 'renderings';
inSession = 'suburb';
inAcquisition = 'city3_11:16_v12.0_f47.50front_o270.00_2019626181423_pos_163_000_000';

lu = sprintf('wandell/%s/%s/%s/%s',inProject.label,inSubject,inSession,inAcquisition);
thisAcquisition = st.lookup(lu);
if isempty(thisAcquisition), error('Acquisition not found.'); end

%% Download and read the spectral radiance and metadata files 

% Note:  Remove dat files when done.
oi = piAcquisition2ISET(thisAcquisition,st);  

% The returned oi can have some rendering artifacts.  We clean them
% here.
oi = piFireFliesRemove(oi);

% Show the rendered optical image
oiWindow(oi); oiSet(oi,'gamma',0.7); truesize;

%% Convert the oi into an IP

pixelSize = 3;           % Microns
[ip, sensor] = piOI2IP(oi,'pixel size',pixelSize);
ipWindow(ip); ipSet(ip,'gamma',0.7); truesize;  

%% Show the metadata

ieNewGraphWin; imagesc(ip.metadata.depthMap); axis image; colorbar;
ieNewGraphWin; imagesc(ip.metadata.meshImage); axis image; colorbar;

%% END