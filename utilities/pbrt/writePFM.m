% writePFM write an a matrix to a Portable Float Map Image.
%
% [] = writePFM( image, filename, scale )
%
% When image is height x width x 3, the image is considered RGB.
% When image is height x width, the image is considered grayscale.
% scale must be a positive value indicating the overall intensity scale.

function [] = writePFM( image, filename, scale )

if exist( 'scale', 'var' ),
    if scale <= 0,
        error( 'scale must be positive' );
    end
else
    scale = 1;
end

if size( image, 3 ) == 3
    
    % RGB
    fid = fopen( filename, 'wb' );
    fprintf( fid, 'PF\n' );
    fprintf( fid, '%d %d\n', size( image,2 ), size( image, 1 ) );
    fprintf( fid, '%f\n', -scale );
    
    tmp( :, :, 1 ) = image( :, :, 1 )';
    tmp( :, :, 2 ) = image( :, :, 2 )';
    tmp( :, :, 3 ) = image( :, :, 3 )';
%     fwrite( fid, tmp, 'float32' );
    fwrite( fid, shiftdim( tmp, 2 ), 'float32' );
    fclose( fid );

elseif size( image, 3 ) == 1
    
    % Greyscale
    fid = fopen( filename, 'wb' );
    fprintf( fid, 'Pf\n' );
    fprintf( fid, '%d %d\n', size( image,2 ), size( image, 1 ) );
    fprintf( fid, '%f\n', -scale );
    
    fwrite( fid, image', 'float32' );
    fclose( fid );
    
else
    
    error( 'Image must be RGB ( height x width x 3 ) or Grayscale (height x width)' );
    
end
