% CLASSIFICADOR DE MIRADA
%-----------------------------------
clear;
close all

% select features to use:
USE_HOG = 0;
USE_HIST = 0;
USE_LBP = 0;
USE_SURF = 0;
USE_HAAR = 0;
USE_EXC = 1;


dir_eyes = dir('./Samples/*.eye');
dir_images = dir('./Samples/*.pgm');
number_files = size(dir_eyes);
% Declarem les matrius a zeros per omplirles
%number_files = 100


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

N_hog = N_hog * USE_HOG;
N_haar = 432 * USE_HAAR;
N_hist = 255 * USE_HIST;
N_lbp = 59 * USE_LBP;
N_surf = 128 * USE_SURF;
N = N_hog + N_hist + N_lbp + N_surf + N_haar + USE_EXC;
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
    if USE_HOG
        feature_vector_hog = extractHOGFeatures(I_crop,'CellSize', CellSize);
        matrix_caract_eye(i+1,1:N_hog) = feature_vector_hog;
    end
    
    %CARACTERISTICA 2: Histograma normalitzat
    if USE_HIST
        feature_vector_hist = my_imhist(I_crop, N_hist);
        matrix_caract_eye(i + 1,(N_hog+1):(N_hog+N_hist)) = feature_vector_hist;
    end
    
    %CARACTERISTICA 3:  local binary pattern
    if USE_LBP
        feature_vector_LBP = extractLBPFeatures(I_crop);
        matrix_caract_eye(i + 1,(N_hog+N_hist+1):(N_hog+N_hist+N_lbp)) = feature_vector_LBP;
    end
    
    %CARACTERISTICA 4: SURFpoints
    if USE_SURF
        points = detectSURFFeatures(I_crop);
        if points.Count < 2
                points = detectSURFFeatures(I_crop, 'MetricThreshold', 1);
        end
        if points.Count >= 2
            [feature_vector_SURF, ~]= extractFeatures(I_crop, points.selectStrongest(2));
            feature_vector_SURF = reshape(feature_vector_SURF.', 1, []);
            matrix_caract_eye(i + 1,(N_hog+N_hist+N_lbp+1):(N_hog+N_hist+N_lbp+N_surf)) = feature_vector_SURF;
        end
    end
    
    %CARACTERISTICA 5: HAAR WAVELET
    if USE_HAAR
        level = 4; % level of the MRA
        [C, S] = wavedec2(I_crop, level, 'haar');
        Aproximation_coefs = appcoef2(C,S,'haar');
        Detail_coefs = detcoef2('compact',C,S,level); 
        feature_vector_haar = [reshape(Aproximation_coefs.', 1, []), Detail_coefs];
        matrix_caract_eye(i + 1,(N_hog+N_hist+N_lbp+N_surf+1):(N_hog+N_hist+N_lbp+N_surf+N_haar)) = feature_vector_haar;
    end
    
    %CARACTERISTICA 6: excentricitat
    if USE_EXC
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
        matrix_caract_eye(i + 1,(N_hog+N_hist+N_lbp+N_surf+2):(N_hog+N_hist+N_lbp+N_surf+N_haar+1)) = ecc_max_area;
    end
    
    
    
    %Omplim el vector d'etiquetes
    vector_labels_eye(i) = matrix_mira(i, 5);

    
end


%-----------------------------------
% Evaluem el predictor amb cross-validation 1x5
N_cv = 5; %Nombre de Cross Validation
indices = crossvalind('Kfold',vector_labels_eye,N_cv);
error = 0;

conf_matrix = zeros(2);

for i = 1:N_cv
    % agafem indexs de test i training
    test = (indices == i); 
    train = ~test;
    % alimentem el model SVM
    predictor = fitcsvm(matrix_caract_eye(train,:),vector_labels_eye(train,:));
    % predim el model
    labels_predicted = predict(predictor,matrix_caract_eye(test,:));
    conf_matrix = conf_matrix + confusionmat(vector_labels_eye(test,:), labels_predicted);
    errors = abs(vector_labels_eye(test,:) - labels_predicted);
    error = error + sum(errors)/sum(test);
    i
    sum(errors)/sum(test)
end
conf_matrix
error = error / N_cv;
percentate_acert = 100 - (error)*100