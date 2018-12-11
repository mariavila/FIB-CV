% CLASSIFICADOR DE ULLS, NO ULLS
%-----------------------------------
% Per cada imatge preprocesem i extraiem les caracteristiques HOG:
% Genarem també 20 caract de imatges no ulls per cada imatge (x y random)
% Jugar amb la finestra de l'ull a tractar


dir_eyes = dir('./Samples/*.eye');
dir_images = dir('./Samples/*.pgm');
number_files = size(dir_eyes);
% Declarem les matrius a zeros per omplirles
matrix_caract_eyes = zeros(number_files*2);             % ????
matrix_caract_NO_eyes = zeros(number_files*20);         % ????
% Obrim imatges i posicions de eyes i generem les caracteristiques
for i = 1:number_files 
    filename = horzcat(dir_eyes(i).folder,'/',dir_eyes(i).name);
    fid = fopen(filename);
    s = textscan(fid, '%s', 1, 'delimiter', '\n');
    c = textscan(fid, '%d', 4, 'delimiter', ' ');
    lx = c{1}(1); ly = c{1}(2); rx = c{1}(3); ry = c{1}(4);
    fclose(fid);
    % Llegim la image
    I = imread(horzcat(dir_images(i).folder,'/',dir_images(i).name));
    imshow(I);
    % Fem preprocesat
    % Fem crop de ull esquerre i obtenim carac
    % Fem crop de ull dret i obtenim carac
    
    % Fem crop de 20 random x y i obtenim carac
end
%-----------------------------------
% Amb la matriu de característiques alimentem el predictor

%-----------------------------------
% Evaluem el predictor amb cross-validation 1x10
