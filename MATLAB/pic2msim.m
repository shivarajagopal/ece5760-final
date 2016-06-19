function pic2msim(inpic, outfile)

img_in = imread(inpic);
% Prepare results file for writing
fid= fopen(outfile, 'w');

r = img_in(:,:,1);
g = img_in(:,:,2);
b = img_in(:,:,3);

for i=1:480
    for j=1:640
        fprintf(fid, 'R= 8''d%d;\n', r(i,j));
        fprintf(fid, 'G= 8''d%d;\n', g(i,j));
        fprintf(fid, 'B= 8''d%d;\n', b(i,j));
        fprintf(fid, '#20;\n', r(i,j));
    end
end

fclose(fid);