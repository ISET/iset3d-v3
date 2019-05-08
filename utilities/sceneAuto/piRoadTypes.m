function roadTypes = piRoadTypes
% Return a list of known road types
%
% Syntax:
%   piRoadTypes
%
% Description:
%    List the available road types stored on Flywheel.
%
% Inputs:
%    None.
%
% Outputs:
%    roadTypes - Cell. A cell array of the supported road types.
%
% Optional key/value pairs:
%    None.
%

% History:
%    XX/XX/19  ZL/BW  Created
%    05/01/19  JNM    Documentation pass

% Examples:
%{
% You can update the list this way

st = scitran('stanfordlabs');
project = st.lookup('wandell/Graphics assets');
session = project.sessions.find('label=road');
acq = session{1}.acquisitions();
stPrint(acq, 'label')

% We are not using the bridge or the highway, yet.

%}

roadTypes = {'curve_6lanes_001', 'straight_2lanes_parking', ...
    'city_cross_6lanes_001', 'city_cross_6lanes_001_construct', ...
    'city_cross_4lanes_002'};

end
