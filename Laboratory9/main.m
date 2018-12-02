% Llegim la imatge de Mostra i la imatge de Test
Imostra = rgb2gray(imread('Joc_de_caracters.jpg'));
Itest = rgb2gray(imread('Joc_de_caracters_deformats.jpg'));
% Creem les llistes de caracteristiques
clauSample = ['0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; 'B'; 'C'; 'D'; 'F'; 'G'; 'H'; 'J'; 'K'; 'L'; 'M'; 'N'; 'P'; 'R'; 'S'; 'T'; 'V'; 'W'; 'X'; 'Y'; 'Z'];
% Obtenim normalized characteristics of sample image
caracteristiquesSample = obtain_text_characteristics(Imostra);
% Obtenim normalized characteristics of test image
caracteristiquesTest = obtain_text_characteristics(Itest);
% Veí més proper (Distancia euclideana)
clauTest = nearest_neighbour_of_text(clauSample, caracteristiquesSample, caracteristiquesTest);
% Creem la matriu de confusio, obtenim l'error de test i les confusions
[matriu_confusio, error] = obtain_confusion_matrix(clauSample, clauTest);
error % printem l'error