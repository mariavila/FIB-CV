% CLASSIFICADOR DE MIRADA
%-----------------------------------
clear;
close all

dir_eyes = dir('./Samples/*.eye');
dir_images = dir('./Samples/*.pgm');
number_files = size(dir_eyes);
% Declarem les matrius a zeros per omplirles
number_files = 10


size_rect_x = 1.35;
size_rect_y = 0.20;
mida_imatge_crop_x = 64;
mida_imatge_crop_y = fix(mida_imatge_crop_x *size_rect_x/size_rect_y);
% Declarem les matrius a zeros per omplirles
CellSize = [4, 4]; %el profe fa de 8
BlockSize = [2, 2];
NumBins = 9;
BlockOverlap = ceil(BlockSize/2);
%comprovar que sigui aixi i no al reves (mida_imatge_crop_x i mida_imatge_crop_y) 
BlocksPerImage = floor(([mida_imatge_crop_x, mida_imatge_crop_y]./CellSize - BlockSize)./(BlockSize - BlockOverlap) + 1);
N_hog = prod([BlocksPerImage, BlockSize, NumBins]);

N_hist = 255;
N_lbp = 59;
N = N_hog + N_lbp;%+ N_hist; % Number of features
matrix_caract_eye = zeros(number_files(1), N); % els dos ulls estan en la mateixa fila
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

    size_rect_x_aux = fix(distancia_entre_ulls)*size_rect_x;
    size_rect_y_aux = fix(distancia_entre_ulls)*size_rect_y;
    
    % Fem crop dels ulls
    rect = [(lx+rx)/2 - fix(size_rect_x_aux/2), (ly+ry)/2 - fix(size_rect_y_aux/2), size_rect_x_aux, size_rect_y_aux];
    I_crop = imcrop(I, rect);
    I_crop = imresize(I_crop, [mida_imatge_crop_x, mida_imatge_crop_y]); 
    %imshow(I_crop)
    
    % Obtenim les caracteristiques XXXXXXX i les afegim a la matriu de
    % caracteristiques
    
    %CARACTERISTICA 1: excentricitat
    %{
    i_feat = 1;
    I_crop_bin = imbinarize(I_crop);
    I_crop_bin = not(I_crop_bin);
    I_crop_bin = imfill(I_crop_bin, 'holes');
    props_left = regionprops(I_crop_bin, 'Eccentricity', 'Area');
    [num_areas, ~] = size(props_left);
    area_max = 0;
    ecc_max_area = 0;
    for j = 1: num_areas 
       if props_left(j).Area > area_max 
           area_max = props_left(j).Area; 
           ecc_max_area =  props_left(j).Eccentricity;
       end
    end
    matrix_caract_eye(i, (i_feat-1) * 2 + 1) = ecc_max_area;  
    %}
    
    %CARACTERISTICA 1: HOG

    feature_vector_hog = extractHOGFeatures(I_crop,'CellSize', CellSize);
    matrix_caract_eye(i,1:N_hog) = feature_vector_hog;
    
    %CARACTERISTICA 2: Histograma normalitzat
    %{
    feature_vector_hist = my_imhist(I_crop, N_hist);
    matrix_caract_eye(i,(N_hog+1):(N_hog+N_hist)) = feature_vector_hist;
    %}
    
    %CARACTERISTICA 3:  local binary pattern
    feature_vector_LBP = extractLBPFeatures(I_crop);
    matrix_caract_eye(i,(N_hog+1):(N_hog+N_lbp)) = feature_vector_LBP;
    
    %CARACTERISTICA X
    %Omplim el vector d'etiquetes
    vector_labels_eye(i) = matrix_mira(i, 5);

    
end

%-----------------------------------
% Evaluem el predictor amb cross-validation 1x10
N_cv = 5;
indices = crossvalind('Kfold',vector_labels_eye,N_cv);
cp = classperf(vector_labels_eye);
error = 0;
for i = 1:N_cv
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
error = error / N_cv
percentate_acert = 100 - error *100