close all;
Imostra = rgb2gray(imread('Joc_de_caracters.jpg'));
Itest = rgb2gray(imread('Joc_de_caracters_deformats.jpg'));
% Itest = Imostra;
Itest2 = rgb2gray(imread('Joc_de_caracters_deformats II.png'));

%Creem les llistes de caracteristiques
clauSample = ['0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; 'B'; 'C'; 'D'; 'F'; 'G'; 'H'; 'J'; 'K'; 'L'; 'M'; 'N'; 'P'; 'R'; 'S'; 'T'; 'V'; 'W'; 'X'; 'Y'; 'Z'];
%Obtenim normalized characteristics of sample image
caracteristiquesSample = obtain_text_characteristics(Imostra);

%Obtenim normalized characteristics of sample image
caracteristiquesTest = obtain_text_characteristics(Itest);
%Veí més proper (Distancia euclideana)
clauTest = nearest_neighbour_of_text(clauSample, caracteristiquesSample, caracteristiquesTest);

%Testing (amb el joc de caracteristiques deformat)

%Crear la matriu de confusio (idealment uns a tota la diagonal) i obtenim
%error (com la suma de tot el que no esta a la diagonal)
[matriu_confusio, error] = obtain_confusion_matrix(clauSample, clauTest);
error

%Calcular la caracteristica mes debil (la que al treurela els resultats
%varien menys)-> IMP!!!!!!!


