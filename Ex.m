Imostra = rgb2gray(imread('Joc_de_caracters.jpg'));
Itest = rgb2gray(imread('Joc_de_caracters_deformats.jpg'));
Itest2 = rgb2gray(imread('Joc_de_caracters_deformats II.png'));

%binaritzem imatge
Imostrab = Imostra<180;
%Obtenim les BB de les lletres
LlistaLletres = regionprops(Imostrab);

%Creem les llistes de caracteristiques
clau = ['0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; 'B'; 'C'; 'D'; 'F'; 'G'; 'H'; 'J'; 'K'; 'L'; 'M'; 'N'; 'P'; 'R'; 'S'; 'T'; 'V'; 'W'; 'X'; 'Y'; 'Z'];
caracteristiques = [];

%obtenim les caracteristiques de cada lletra
for i = 1:30
    %obtenim la BB de la lletra
    BoundingBoxLletra = LlistaLletres(i).BoundingBox;
    %augmentem els marcs
    BoundingBoxLletra = BoundingBoxLletra + [-1 -1 1 1];
    %obtenim la imatge de la lletra
    %imcrop(Imatge, [xmin ymin width height]);
    Illetra = imcrop(Imostrab, BoundingBoxLletra);
    %calcular 8 caracteristiques de forma o area del joc de caracteristiques
    carac = obtaincharacteristics(Illetra, LlistaLletres(i).Area);
    %afegim el valor a la variable global
    caracteristiques = [caracteristiques; carac];
end

%Normalitzar les caracteristiques perque totes tinguin un rang similar (entre 0 i 1)
[f c] = size(caracteristiques);
for i =  0:c
    %carac = 
end
%Implementar un predictor f(x) -> Simbol (vector de caracteristiques)
%Veí més proper


%Distancia euclideana -> 

%Testing (amb el joc de caracteristiques deformat)

%Crear la matriu de confusio (idealment uns a tota la diagonal)
%Definirem l'error com la suma de tot el que no esta a la diagonal

%Calcular la caracteristica mes debil (la que al treurela els resultats
%varien menys)-> IMP!!!!!!!

%Poligon mes llarg en relacio al perimetre
