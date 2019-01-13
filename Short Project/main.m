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
number_files = 5
size_rect_x = 1.5;
size_rect_y = 0.60;
mida_imatge_crop_x = 64;
mida_imatge_crop_y = fix(mida_imatge_crop_x *size_rect_x/size_rect_y);
% Declarem les matrius a zeros per omplirles
CellSize = [8, 8]; %el profe fa de 8
BlockSize = [2, 2];
NumBins = 9;
BlockOverlap = ceil(BlockSize/2);
%comprovar que sigui aixi i no al reves (mida_imatge_crop_x i mida_imatge_crop_y) 
BlocksPerImage = floor(([mida_imatge_crop_x, mida_imatge_crop_y]./CellSize - BlockSize)./(BlockSize - BlockOverlap) + 1);
N_hog = prod([BlocksPerImage, BlockSize, NumBins]);

N_hist = 255;
N_lbp = 59;
N = N_hog + N_hist + N_lbp;
matrix_caract_eye = zeros(number_files(1)*20, N);
vector_labels_eye = zeros(number_files(1)*20, 1);


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
    rect = [(lx+rx)/2 - fix(size_rect_x_aux/2), (ly+ry)/2 - fix(size_rect_y_aux/2)-0.1*distancia_entre_ulls, size_rect_x_aux, size_rect_y_aux];
    I_crop = imcrop(I, rect);
    I_crop = imresize(I_crop, [mida_imatge_crop_x, mida_imatge_crop_y]); 
    
    % Obtenim les caracteristiques HOG i les afegim a la matriu de
    % caracteristiques
    %IMPORTANT: totes les imatges han de tenir la mateixa mida, sino donara
    %un HOG lenght diferent
    
    %CARACTERISTICA 1: HOG
    feature_vector_hog = extractHOGFeatures(I_crop,'CellSize', CellSize);
    matrix_caract_eye(i,1:N_hog) = feature_vector_hog;
    
    %CARACTERISTICA 2: Histograma normalitzat
    feature_vector_hist = my_imhist(I_crop, N_hist);
    matrix_caract_eye(i,(N_hog+1):(N_hog+N_hist)) = feature_vector_hist;

    
    %CARACTERISTICA 3:  local binary pattern
    feature_vector_LBP = extractLBPFeatures(I_crop);
    matrix_caract_eye(i,(N_hog+N_hist+1):(N_hog+N_hist+N_lbp)) = feature_vector_LBP;
    
    %Posem etiqueta de ULL
    vector_labels_eye((i-1)*20 + 1) = 1;
       

    % Fem crop de 19 random x y i obtenim carac:
    [I_size_y, I_size_x] = size(I);

    for j = 1:19
        % Generem x random entre size_rect_x/2+1 i size_x - size_rect_x/2 -1
        x_rand = randi([mida_imatge_crop_x/2, I_size_x - fix(mida_imatge_crop_x/2)]);
        % Generem y random entre size_rect_y/2+1 i size_y - size_rect_y/2 -1
        y_rand = randi([mida_imatge_crop_y/2, I_size_y - fix(mida_imatge_crop_y/2)]);
        rect = [x_rand - fix(size_rect_x_aux/2), y_rand - fix(size_rect_y_aux/2)-0.1*distancia_entre_ulls, size_rect_x_aux, size_rect_y_aux];
        I_rand = imcrop(I, rect);
        I_rand = imresize(I_rand, [mida_imatge_crop_x, mida_imatge_crop_y]); 
        % Obtenim les caracteristiques HOG i les afegim a la matriu de
        % caracteristiques
        
        %CARACTERISTICA 1: HOG
        feature_vector_hog_random = extractHOGFeatures(I_rand,'CellSize', CellSize);
        matrix_caract_eye((i-1)*20 + j + 1, 1:N_hog) = feature_vector_hog_random;
        
        %CARACTERISTICA 2: Histograma normalitzat
        feature_vector_hist = my_imhist(I_crop, N_hist);
        matrix_caract_eye((i-1)*20 + j + 1,(N_hog+1):(N_hog+N_hist)) = feature_vector_hist;

        %CARACTERISTICA 3:  local binary pattern
        feature_vector_LBP = extractLBPFeatures(I_crop);
        matrix_caract_eye((i-1)*20 + j + 1,(N_hog+N_hist+1):(N_hog+N_hist+N_lbp)) = feature_vector_LBP;
    
        %Posem etiqueta de NO ULL
        vector_labels_eye((i-1)*20 + j + 1) = 0;
        
    end
    

    
end
%-----------------------------------
% Amb la matriu de característiques alimentem el predictor
% predictor = fitcsvm(matrix_caract_eye,vector_labels_eye);


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
    error = error + sum(errors)/sum(test);
    i
    sum(errors)/sum(test)
end
error = error / N_cv;
percentate_acert = 100 - (error)*100

