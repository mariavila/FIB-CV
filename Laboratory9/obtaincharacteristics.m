function [ carac ] = obtaincharacteristics( I, Properties )
    %obtaincharacteristics obtains the characteristics of an image
    Perimetre = Properties.Perimeter;
    BoundingBoxLletra = Properties.BoundingBox; 
    Width = BoundingBoxLletra(3);
    Heigth = BoundingBoxLletra(4);
    Area = Properties.Area;
    %Numero de forats de la lletra:
    CC = bwconncomp(not(I), 8);
    % Treiem el fons com a forat
    car_num_forats = CC.NumObjects -1; 
    %Rectangularitat
    car_rectangularitat = Area/(Width*Heigth);
    %Poligon mes llarg en relacio al perimetre
    %Angle del poligon mes llarg
    % simplified polygonal boundary of a BW image
    CC = bwconncomp(I);
    idxlists = CC.PixelIdxList;
    pixels = idxlists{1};
    [F,C] = ind2sub(size(I), pixels);
    % exterior boundary
    k = boundary([F,C],0.90); % loose factor = 0.15 
    % reduce polygonal
    [RF,RC] = reducem(F(k),C(k),5); % tolerance = 5 degrees
    [quantitat_poligons, aux] = size(RF);
    poligon_mes_llarg = 0;
    angle_poligon_llarg =0;
    for x = 1:quantitat_poligons-1
        dist = (RF(x) - RF(x+1))^2 + (RC(x) - RC(x+1))^2;
        if dist > poligon_mes_llarg
            poligon_mes_llarg = dist;
            base = abs(RF(x) - RF(x+1));
            angle_poligon_llarg = sin(base/sqrt(dist));
        end
    end
    car_largest_pol = poligon_mes_llarg / Perimetre;
    car_angle_largest_pol = angle_poligon_llarg;
    %Aspect ratio de la BB
    car_aspect_BB = Width / Heigth;
    %Compacitat
    car_compacitat = Perimetre^2/Area;
    %Centroide x
    car_centroide_x = Properties.Centroid(1)/Width;   
    %Centroide y
    car_centroide_y = Properties.Centroid(2)/Heigth    
    %Obtenim el resultat
    carac = [car_num_forats car_rectangularitat car_largest_pol car_angle_largest_pol car_aspect_BB car_compacitat car_centroide_x car_centroide_y];
end