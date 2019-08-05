function roadTypes = piRoadTypes(varargin)
% Return a list of known road types
%
% Syntax:
%   piRoadTypes([varargin])
%
% Description:
%    List the available road types stored on Flywheel.
%
%    This function contains examples of usage inline. To access these, type
%    'edit piRoadTypes.m' into the Command Window.
%
% Inputs:
%    None.
%
% Outputs:
%    roadTypes - Cell. A cell array of the supported road types.
%
% Optional key/value pairs:
%    'print'   - Boolean. Whether or not to print out road types in a list.
%                Default true.
%

% History:
%    XX/XX/19  ZL/BW  Created
%    05/01/19  JNM    Documentation pass

% Examples:
%{
    % You can update the list this way

    st = scitran('stanfordlabs');
    project = st.lookup('wandell/Graphics auto');
    session = project.sessions.find('label=road');
    acq = session{1}.acquisitions();
    stPrint(acq, 'label')

    % We are not using the bridge or the highway, yet.

%}

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('print', true, @islogical);
p.parse(varargin{:});

print = p.Results.print;

roadTypes = {'curve_6lanes_001', 'straight_2lanes_parking', ...
    'city_cross_6lanes_001', 'city_cross_6lanes_001_construct', ...
    'city_cross_4lanes_002'};

if print
    fprintf('\nRoad types\n---------------\n');
    for ii=1:numel(roadTypes)
        fprintf('%d\t%s\n',ii,roadTypes{ii});
    end
    fprintf('\n\n');
end

end
