% CLASSIFICADOR DE ULLS, NO ULLS
%-----------------------------------
% Per cada imatge preprocesem i extraiem les caracteristiques HOG:
% Genarem també 20 caract de imatges no ulls per cada imatge (x y random)
% Jugar amb la finestra de l'ull a tractar
clear;
close all

dir_eyes = dir('./Samples/*.eye');
dir_images = dir('./Samples/*.pgm');
number_files = size(dir_eyes);
% Declarem les matrius a zeros per omplirles
mida_imatge_crop = 64;
CellSize = [8, 8]; %el profe fa de 8
BlockSize = [2, 2];
NumBins = 9;
BlockOverlap = ceil(BlockSize/2);
BlocksPerImage = floor(([mida_imatge_crop, mida_imatge_crop]./CellSize - BlockSize)./(BlockSize - BlockOverlap) + 1);
N = prod([BlocksPerImage, BlockSize, NumBins]);
matrix_caract_eye = zeros(number_files(1)*22, N);
vector_labels_eye = zeros(number_files(1)*22, 1);

%number_files = 10
% Obrim imatges i posicions de eyes i generem les caracteristiques
for i = 1:number_files 
    filename = horzcat(dir_eyes(i).folder,'/',dir_eyes(i).name);
    fid = fopen(filename);
    s = textscan(fid, '%s', 1, 'delimiter', '\n');
    c = textscan(fid, '%d', 4, 'delimiter', ' ');
    lx = c{1}(1); ly = c{1}(2); rx = c{1}(3); ry = c{1}(4);
    fclose(fid);
    % Llegim la imatge
    I = imread(horzcat(dir_images(i).folder,'/',dir_images(i).name));
    
    % Preprocesat de la imatge
    I = imtophat(I, strel('disk', 50));
    % Mida del rectangle de crop
    distancia_entre_ulls = lx - rx;
    size_rect_x = 0.50;
    size_rect_y = 0.50;
    size_rect_x = fix(distancia_entre_ulls)*size_rect_x;
    size_rect_y = fix(distancia_entre_ulls)*size_rect_y;
    
    % Fem crop de ull esquerre i obtenim carac
    rect = [lx - fix(size_rect_x/2), ly - fix(size_rect_y/2), size_rect_x, size_rect_y];
    I_left = imcrop(I, rect);
    I_left = imresize(I_left, [mida_imatge_crop, mida_imatge_crop]); 
    % Fem crop de ull dret i obtenim carac
    rect = [rx - fix(size_rect_x/2), ry - fix(size_rect_y/2), size_rect_x, size_rect_y];
    I_right = imcrop(I, rect);
    I_right = imresize(I_right, [mida_imatge_crop, mida_imatge_crop]); 

    
    % Obtenim les caracteristiques HOG i les afegim a la matriu de
    % caracteristiques
    %IMPORTANT: totes les imatges han de tenir la mateixa mida, sino donara
    %un HOG lenght diferent
    feature_vector_right = extractHOGFeatures(I_right,'CellSize', CellSize);
    matrix_caract_eye((i-1)*22 + 2, :) = feature_vector_right;
    vector_labels_eye((i-1)*22 + 1) = 1;
    
    feature_vector_left = extractHOGFeatures(I_left,'CellSize', CellSize);
    matrix_caract_eye((i-1)*22 + 2, :) = feature_vector_left;
    vector_labels_eye((i-1)*22 + 2) = 1;    

    % Fem crop de 20 random x y i obtenim carac:
    [I_size_y, I_size_x] = size(I);
    for j = 1:20
        % Generem x random entre size_rect_x/2+1 i size_x - size_rect_x/2 -1
        x_rand = randi([fix(size_rect_x/2), I_size_x - fix(size_rect_x/2)]);
        % Generem y random entre size_rect_y/2+1 i size_y - size_rect_y/2 -1
        y_rand = randi([fix(size_rect_y/2), I_size_y - fix(size_rect_y/2)]);
        rect = [x_rand - size_rect_x/2, y_rand - size_rect_y/2, size_rect_x, size_rect_y];
        I_rand = imcrop(I, rect);
        I_rand = imresize(I_rand, [mida_imatge_crop, mida_imatge_crop]); 
        
        % Obtenim les caracteristiques HOG i les afegim a la matriu de
        % caracteristiques
        feature_vector_random = extractHOGFeatures(I_rand,'CellSize', CellSize);
        matrix_caract_eye((i-1)*22 + 2, :) = feature_vector_random;
        vector_labels_eye((i-1)*22 + j + 2) = 0;
        
    end

    
end
%-----------------------------------
% Amb la matriu de característiques alimentem el predictor
predictor = fitcsvm(matrix_caract_eye,vector_labels_eye);


%-----------------------------------
% Predim la posicio dels ulls en una imatge test
%Open dialog box and select and image from it
[filename,filepath]=uigetfile({'*'},'Select and image');
%Set the value of the text field edit1 to the route of the selected image.
I_test = rgb2gray(imread(strcat(filepath, filename)));

% Fem una finestra lliscant sobre la imatge
[width, height] = size(I_test);
J = zeros(size(I_test));
for i = 1 : (width - mida_imatge_crop)
    for j = 1 : (height - mida_imatge_crop)
        rect = [i, j, mida_imatge_crop, mida_imatge_crop];
        I_window = imcrop(I_test, rect);
        %I_window = imresize(I_window, [mida_imatge_crop, mida_imatge_crop]);
        vector_caract_test = zeros(1, N);
        %Extract HOG feature
        feature_vector_test = extractHOGFeatures(I_window,'CellSize', CellSize);
        vector_caract_test(1, :) = feature_vector_test;
        if predict(predictor,feature_vector_test)
            J(i-1+(64/2):i+(64/2), j-1+(64/2):j+(64/2)) = ones(2);

        end
    end
    i
end

%Obtenim els punts centrals de cada conjunt
CC = bwconncomp(J);
S = regionprops(CC, 'centroid');
cent = cat(1, S.Centroid);
% afegim un marker vermell al centroide de l'objecte
If = insertMarker(uint8(I_test), cent, 'x', 'color', 'green', 'size', 10);
%visualitzar la imatge
imshow(If, []);


