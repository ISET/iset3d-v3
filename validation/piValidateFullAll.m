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

try
    status = piRunTutorialsAll;
    if (~status)
        error('At least on tutorial script failed.');
    end
catch
    error('Run all tutorials script failed.')
end

end