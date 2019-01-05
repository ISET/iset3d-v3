%% Retinal sampling example

%% Initialize
ieInit

%%

figure(1); clf; grid on;
hold on;
axis image;

retinaSemiDiam = 6;
retinaRadius = 12;
retinaDistance = 16.32;

% Calculate the distance of a disc that fits inside the curvature of the retina.
zDiscDistance = -1*sqrt(retinaRadius*retinaRadius-retinaSemiDiam*retinaSemiDiam);

for x = -retinaSemiDiam:retinaSemiDiam
    for y = -retinaSemiDiam:retinaSemiDiam
        
        % Limit sample points to a circle within the retina semi-diameter
        if((x^2 + y^2) > (retinaSemiDiam*retinaSemiDiam))
            continue;
        end
        
        % Plot the planar point
        scatter3(x,y,zDiscDistance-1*retinaDistance + retinaRadius,'rx')
        
        % Spherical coordinates
        el = atan(x/zDiscDistance);
        az = atan(y/zDiscDistance);
        
        % Spherical to cartesian
        xc = -1*retinaRadius*sin(el); % TODO: Confirm this flip?
        rcoselev = retinaRadius*cos(el);
        zc = -1*(rcoselev*cos(az)); % The -1 is to account for the curvature described above in the diagram
        yc = -1*rcoselev*sin(az); % TODO: Confirm this flip?
            
        zc = zc + -1*retinaDistance + retinaRadius; % Move the z coordinate out to correct retina distance
        
        scatter3(xc,yc,zc,'b*');
            

    end
end
