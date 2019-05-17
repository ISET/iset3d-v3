function piValidateFullAll
% Full run of iset3d validations.
%
% Syntax:
%     piValidateFullAll
%
% Description:
%    This function is a full execution of all ISET3d validations that
%    currently exist.
%
% Inputs:
%    None.
%
% Outputs:
%    None.
%
% Optional key/value pairs:
%    None.
%
% History:
%    XX/XX/XX  XXX  Created
%    03/18/19  JNM  Documentation pass

%% Close all figures so that we start with a clean slate
close all;

%% Validation scripts
try
    v_iset3d;
catch
    error('At least one validation script failed in v_iset3d');
end

%% Tutorials
try
    piRunTutorialsAll;
catch
    error('Run all tutorials script failed.')
end

%% Examples
try
    status = piRunExamplesAll;
catch
    error('Run all examples script failed.')
end
if (~status)
    error('At least one example script failed.');
end

%% If we're here, it's alive
fprintf('\n*** All ISET3D validations/tutorials/examples OK!***\n');

end