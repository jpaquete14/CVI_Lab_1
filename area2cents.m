function cents = area2cents(area)
    
    coin1CentPA = 9448;
    coin2CentPA = 13073;
    coin5CentPA = 16345;
    coin10CentPA = 14005;
    coin20CentPA = 17903;
    coin50CentPA = 21623;
    coin1EurPA = 19775;
    
    delta1Cent = 551;
    delta2Cent = 640;
    delta5Cent = 715;
    delta10Cent = 667;
    delta20Cent = 752;
    delta50Cent = 823;
    delta1Eur = 786;
   
    
    if area > ( coin1CentPA - delta1Cent ) && area <= ( coin1CentPA + delta1Cent ) 
        cents = 1;
    elseif area > (coin2CentPA - delta2Cent) && area <= ( coin2CentPA + delta2Cent)
        cents = 2;
    elseif area > (coin10CentPA - delta10Cent) &&  area <= (coin10CentPA + delta10Cent)
        cents = 10;
    elseif area > (coin5CentPA - delta5Cent) &&  area <= (coin5CentPA + delta5Cent)
        cents = 5;
    elseif area > (coin20CentPA - delta20Cent) && area <= (coin20CentPA + delta20Cent)
        cents = 20;
    elseif area > (coin1EurPA - delta1Eur) &&  area <= (coin1EurPA + delta1Eur)
        cents = 100;
    elseif area > (coin50CentPA - delta50Cent) &&  area <= (coin50CentPA + delta50Cent)
        cents = 50;
    else
        cents = 0;
    end
end