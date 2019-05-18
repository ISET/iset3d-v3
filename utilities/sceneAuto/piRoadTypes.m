function roadTypes = piRoadTypes(varargin)
% Return a list of known road types
%
% Syntax:
%   piRoadTypes
%
% Key val pairs
%   'print' - Prints out in a list default is trye
%
% List the available road types stored on Flywheel.
%
% ZL/BW 

%{
% You can update the list this way

st = scitran('stanfordlabs');
project = st.lookup('wandell/Graphics auto');
session = project.sessions.find('label=road');
acq = session{1}.acquisitions();
stPrint(acq,'label')

% We are not using the bridge or the highway, yet.

%}

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('print',true,@islogical);
p.parse(varargin{:});

print = p.Results.print;

roadTypes = {'curve_6lanes_001','straight_2lanes_parking',...
    'city_cross_6lanes_001','city_cross_6lanes_001_construct',...
    'city_cross_4lanes_002'};

if print
    fprintf('\nRoad types\n---------------\n');
    for ii=1:numel(roadTypes)
        fprintf('%d\t%s\n',ii,roadTypes{ii});
    end
    fprintf('\n\n');
end
 
end
