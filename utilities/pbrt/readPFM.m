% read_pfm
%
% read_pfm( filename )
% Reads a Portable Float Map (PFM) from file located in filename
% A greyscale PFM (header: 'Pf') is returned as a ( height x width )
% matrix
% An RGB color PFM (header: 'PF') is returned as a ( height x width x 3 )
% matrix
function image = readPFM( filename )

fid = fopen( filename );
% read header
id = fgetl( fid );
imgsize = fgetl( fid );
% scale = fgetl( fid );
imgsize = strsplit(imgsize,' ');
width = imgsize{1};
height = imgsize{2};
% TODO: deal with the stupid whitespace issue
dim( 1 ) = sscanf( width, '%d' );
dim( 2 ) = sscanf( height, '%d' );
scale = fgetl( fid );
scale = sscanf( scale, '%f' ); % TODO: deal with endianness
scale = abs( scale );

data = fread( fid, inf, 'float32' );
fclose( fid );

if strcmp( id, 'PF' ),
    % RGB
    
    % check size
    if size( data, 1 ) == 3 * prod( dim ),
        
        redIndices = 1 : 3 : size( data, 1 );
        red = data( redIndices );
        green = data( redIndices + 1 );
        blue = data( redIndices + 2 );
        
        % transpose image
        image = zeros( dim(2), dim(1), 3 );
        image( :, :, 1 ) = reshape( red, dim(1), dim(2) )';
        image( :, :, 2 ) = reshape( green, dim(1), dim(2) )';
        image( :, :, 3 ) = reshape( blue, dim(1), dim(2) )';
    else
        error( 'File size and image dimensions mismatched!' );
    end
elseif strcmp( id, 'Pf' ),
    % grey
    
    % check size
    if size( data, 1 ) == prod( dim )   
        image( :, : ) = reshape( data, dim(1), dim(2) )';
    else
        error( 'File size and image dimensions mismatched!' );
    end
else
    error( 'Invalid file header!' );
end
