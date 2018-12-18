% CLASSIFICADOR DE MIRADA
%-----------------------------------
clear;
close all

dir_eyes = dir('./Samples/*.eye');
dir_images = dir('./Samples/*.pgm');
number_files = size(dir_eyes);
%number_files = 1000
% Declarem les matrius a zeros per omplirles
mida_imatge_crop = 64;
N = 1; % Number of features
matrix_caract_eye = zeros(number_files(1), N * 2); % els dos ulls estan en la mateixa fila
vector_labels_eye = zeros(number_files(1), 1);

%Obrim l'excel que ens indica si la persona mira a la camera
matrix_mira = xlsread('Samples/Miram.xlsx');

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
    size_rect_x = 0.20;
    size_rect_y = 0.20;
    size_rect_x = fix(distancia_entre_ulls)*size_rect_x;
    size_rect_y = fix(distancia_entre_ulls)*size_rect_y;
    
    % Fem crop de ull esquerre
    rect = [lx - fix(size_rect_x/2), ly - fix(size_rect_y/2), size_rect_x, size_rect_y];
    I_left = imcrop(I, rect);
    I_left = imresize(I_left, [fix(mida_imatge_crop*size_rect_y/size_rect_x), mida_imatge_crop]); 
    
    % Fem crop de ull dret 
    rect = [rx - fix(size_rect_x/2), ry - fix(size_rect_y/2), size_rect_x, size_rect_y];
    I_right = imcrop(I, rect);
    I_right = imresize(I_right, [fix(mida_imatge_crop*size_rect_y/size_rect_x), mida_imatge_crop]); 
    
    % Obtenim les caracteristiques XXXXXXX i les afegim a la matriu de
    % caracteristiques
    
    %CARACTERISTICA 1: excentricitat
    i_feat = 1;
    I_left_bin = imbinarize(I_left);
    I_left_bin = not(I_left_bin);
    I_left_bin = imfill(I_left_bin, 'holes');
    props_left = regionprops(I_left_bin, 'Eccentricity', 'Area');
    [num_areas ~] = size(props_left);
    area_max = 0;
    ecc_max_area = 0;
    for j = 1: num_areas 
       if props_left(j).Area > area_max
           area_max = props_left(j).Area; 
           ecc_max_area =  props_left(j).Eccentricity;
       end
    end
    matrix_caract_eye(i, (i_feat-1) * 2 + 1) = ecc_max_area;  
    
    I_right_bin = imbinarize(I_right);
    I_right_bin = not(I_right_bin);
    I_right_bin = imfill(I_right_bin, 'holes');
    props_right = regionprops(I_right_bin, 'Eccentricity', 'Area');
    [num_areas ~] = size(props_right);
    area_max = 0;
    ecc_max_area = 0;
    for j = 1: num_areas 
       if props_right(j).Area > area_max
           area_max = props_right(j).Area; 
           ecc_max_area =  props_right(j).Eccentricity;
       end
    end
    matrix_caract_eye(i, (i_feat-1) * 2 + 1) = ecc_max_area; 

    %CARACTERISTICA X
    %HOG??? -> te molta mes prioritat
    %Omplim el vector d'etiquetes
    vector_labels_eye(i) = matrix_mira(i, 5);
    
end

%-----------------------------------
% Evaluem el predictor amb cross-validation 1x10
indices = crossvalind('Kfold',vector_labels_eye,10);
cp = classperf(vector_labels_eye);
error = 0;
for i = 1:10
    test = (indices == i); 
    train = ~test;
    % class = classify(matrix_caract_eye(test,:),matrix_caract_eye(train,:),vector_labels_eye(train,:), 'diaglinear');
    predictor = fitcsvm(matrix_caract_eye(train,:),vector_labels_eye(train,:));
    labels_predicted = predict(predictor,matrix_caract_eye(test,:));
    errors = abs(vector_labels_eye(test,:) - labels_predicted);
    test_size = sum(test);
    error = error + sum(errors)/test_size;
    i
    sum(errors)/test_size
end
error = error / 10;
