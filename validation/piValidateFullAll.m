function piValidateFullAll
% Full run of iset3d validations. 
%
% Syntax:
%     piValidateFullAll

%% Close all figures so that we start with a clean slate
close all;

%% Validation scripts
try
    v_iset3d;
catch
    error('At least one validation script failed');
end

%% Tutorials
try
    status = piRunTutorialsAll;
catch
    error('Run all tutorials script failed.')
end
if (~status)
    error('At least on tutorial script failed.');
end

%% Examples
try
    status = piRunExamplesAll;
catch
    error('Run all examples script failed.')
end
if (~status)
    error('At least on examplel script failed.');
end

%% If we're here, it's a live
fprintf('\n*** All ISET3D validations/tutorials/examples OK!***\n');

end