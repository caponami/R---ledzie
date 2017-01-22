-   [1. Krótkie streszczenie](#krotkie-streszczenie)
-   [2. Ładowanie wykorzystywanych
    bibliotek](#adowanie-wykorzystywanych-bibliotek)
-   [3. Wczytanie danych](#wczytanie-danych)
-   [4. Zapewnienie powtarzalności
    wyników](#zapewnienie-powtarzalnosci-wynikow)
-   [5. Przetwarzanie brakujących
    danych](#przetwarzanie-brakujacych-danych)
-   [6. Krótkie podsumowanie danych po
    czyszczeniu](#krotkie-podsumowanie-danych-po-czyszczeniu)
-   [7. Zmiana wielkości ryby w czasie](#zmiana-wielkosci-ryby-w-czasie)
-   [8. Graficzna prezentacja korelacji pomiędzy
    danymi](#graficzna-prezentacja-korelacji-pomiedzy-danymi)
-   [9. Regresor przewidujący rozmiar
    śledzia](#regresor-przewidujacy-rozmiar-sledzia)
-   [10. Model](#model)
-   [11. Przewidywanie wartości i ocena
    błędu](#przewidywanie-wartosci-i-ocena-bedu)
-   [12. Analiza ważności atrybutów](#analiza-waznosci-atrybutow)
-   [13. Wnioski](#wnioski)

1. Krótkie streszczenie
-----------------------

Analiza dotyczy zbióru danych na temat połowu śledzia oceanicznego w
Europie. Do analizy zebrano pomiary śledzi i warunków w jakich żyją z
ostatnich 60 lat. Dane były pobierane z połowów komercyjnych jednostek.
W ramach połowu jednej jednostki losowo wybierano od 50 do 100 sztuk
trzyletnich śledzi. Dane stanowiły duże wyzwanie dla analityka. Ze
względu na fakt, iż były one posortowane chronologicznie, to atrybut Id
odpowiadał za czas, a nie xmonth. Przy przetwarzaniu danych i budowaniu
modelu należało zwrócić dodatkowo na fakt, iż wiele atrybutów posiadało
identyczne wartości dla różnych długości śledzia.

Poniżej znajdują się szczegółowe opisy konkretnych atrybutów:

<table>
<colgroup>
<col width="12%" />
<col width="50%" />
<col width="37%" />
</colgroup>
<thead>
<tr class="header">
<th>Dane</th>
<th>Opis</th>
<th>Dane</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>length</td>
<td>długość śledzia</td>
<td>cm</td>
</tr>
<tr class="even">
<td>cfin1</td>
<td>dostępność planktonu</td>
<td>skupisko Calanus finmarchicus gat. 1</td>
</tr>
<tr class="odd">
<td>cfin2</td>
<td>dostępność planktonu</td>
<td>skupisko Calanus finmarchicus gat. 2</td>
</tr>
<tr class="even">
<td>chel1</td>
<td>dostępność planktonu</td>
<td>skupisko Calanus helgolandicus gat. 1</td>
</tr>
<tr class="odd">
<td>chel2</td>
<td>dostępność planktonu</td>
<td>skupisko Calanus helgolandicus gat. 2</td>
</tr>
<tr class="even">
<td>lcop1</td>
<td>dostępność planktonu</td>
<td>skupisko widłonogów gat. 1</td>
</tr>
<tr class="odd">
<td>lcop2</td>
<td>dostępność planktonu</td>
<td>skupisko widłonogów gat. 2</td>
</tr>
<tr class="even">
<td>fbar</td>
<td>intensywność połowów w regionie</td>
<td>ułamek pozostawionego narybku</td>
</tr>
<tr class="odd">
<td>recr</td>
<td>roczny narybek</td>
<td>liczba śledzi</td>
</tr>
<tr class="even">
<td>cumf</td>
<td>łączne roczne natężenie połowów w regionie</td>
<td>ułamek zachowanego narybku</td>
</tr>
<tr class="odd">
<td>totaln</td>
<td>łączna liczba ryb złowionych w ramach pojedynczego połowu</td>
<td>liczba śledzi</td>
</tr>
<tr class="even">
<td>sst</td>
<td>temperatura przy powierzchni wody</td>
<td>stopnie °C</td>
</tr>
<tr class="odd">
<td>sal</td>
<td>poziom zasolenia</td>
<td>liczba części na milion</td>
</tr>
<tr class="even">
<td>xmonth</td>
<td>miesiąc połowu</td>
<td>numer miesiąca</td>
</tr>
<tr class="odd">
<td>nao</td>
<td>oscylacja północnoatlantycka</td>
<td>mb</td>
</tr>
</tbody>
</table>

2. Ładowanie wykorzystywanych bibliotek
---------------------------------------

    library(knitr)
    library(plyr)
    library(dplyr)
    library(tidyr)
    library(ggplot2)
    library(plotly)
    library(corrplot)
    library(caret)
    library(zoo)

3. Wczytanie danych
-------------------

    fish_data <- read.csv(url("http://www.cs.put.poznan.pl/dbrzezinski/teaching/zed/sledzie.csv"),header = TRUE, sep = ",", comment.char = "", stringsAsFactors = TRUE, na.strings = "?", col.names = c("id", "length", "cfin1", "cfin2", "chel1", "chel2", "lcop1", "lcop2", "fbar", "recr", "cumf", "totaln", "sst", "sal", "xmonth", "nao"))

4. Zapewnienie powtarzalności wyników
-------------------------------------

Wywołanie funkcji "set.seed(25)" zapewnia powtarzalność wyników
dokonywanych operacji.

    set.seed(25)

5. Przetwarzanie brakujących danych
-----------------------------------

Poniższy wykres przedstawia liczbę wartości NA (brak wartości) dla
konkretnego zbioru danych (danej kolumny).

    liczba_na <- fish_data %>%
      gather("column", "value", 1:ncol(fish_data)) %>%
      filter(is.na(value))

    ggplot(liczba_na, aes(factor(column))) +
      geom_bar(fill="white", colour="black") +
      labs(x = "kolumna", y = "liczba brakujących wartości") + theme_dark()

![](Analiza_długości_śledziarmd_files/figure-markdown_strict/podsumowanie-1.png)

Brakujące dane znajdują się w kolumnach:

-   cfin1 - dostępność planktonu - skupisko Calanus finmarchicus gat. 1
-   cfin2 - dostępność planktonu - skupisko Calanus finmarchicus gat. 2
-   chel1 - dostępność planktonu - skupisko Calanus helgolandicus gat. 1
-   chel2 - dostępność planktonu - skupisko Calanus helgolandicus gat. 2
-   lcop1 - dostępność planktonu - skupisko widłonogów gat. 1
-   lcop2 - dostępność planktonu - skupisko widłonogów gat. 2
-   sst - temperatura przy powierzchni wody stopnie °C

Z powodu silnego powiązania danych, zostały one zastąpione tymi samymi
danymi z obserwacji określonych przez numer miesiąca oraz liczbę
złowionych ryb (sumę złowionych ryb).

    zast_data <- function(x) replace(x, is.na(x), mean(x, na.rm = TRUE))
    data_re <- ddply(fish_data, .(totaln), transform, 
                           cfin1 = zast_data(cfin1),
                           cfin2 = zast_data(cfin2),
                           chel1 = zast_data(chel1),
                           chel2 = zast_data(chel2),
                           lcop1 = zast_data(lcop1),
                           lcop2 = zast_data(lcop2),
                           sst = zast_data(sst))

6. Krótkie podsumowanie danych po czyszczeniu
---------------------------------------------

    ##        id            length         cfin1             cfin2        
    ##  Min.   :    0   Min.   :19.0   Min.   : 0.0000   Min.   : 0.0000  
    ##  1st Qu.:13145   1st Qu.:24.0   1st Qu.: 0.0000   1st Qu.: 0.2778  
    ##  Median :26290   Median :25.5   Median : 0.1111   Median : 0.7012  
    ##  Mean   :26290   Mean   :25.3   Mean   : 0.4462   Mean   : 2.0258  
    ##  3rd Qu.:39436   3rd Qu.:26.5   3rd Qu.: 0.3333   3rd Qu.: 1.7936  
    ##  Max.   :52581   Max.   :32.5   Max.   :37.6667   Max.   :19.3958  
    ##      chel1            chel2            lcop1              lcop2       
    ##  Min.   : 0.000   Min.   : 5.238   Min.   :  0.3074   Min.   : 7.849  
    ##  1st Qu.: 2.469   1st Qu.:13.427   1st Qu.:  2.5479   1st Qu.:17.808  
    ##  Median : 5.750   Median :21.435   Median :  7.0717   Median :24.859  
    ##  Mean   :10.003   Mean   :21.219   Mean   : 12.8080   Mean   :28.422  
    ##  3rd Qu.:11.500   3rd Qu.:27.193   3rd Qu.: 21.2315   3rd Qu.:37.232  
    ##  Max.   :75.000   Max.   :57.706   Max.   :115.5833   Max.   :68.736  
    ##       fbar             recr              cumf             totaln       
    ##  Min.   :0.0680   Min.   : 140515   Min.   :0.06833   Min.   : 144137  
    ##  1st Qu.:0.2270   1st Qu.: 360061   1st Qu.:0.14809   1st Qu.: 306068  
    ##  Median :0.3320   Median : 421391   Median :0.23191   Median : 539558  
    ##  Mean   :0.3304   Mean   : 520366   Mean   :0.22981   Mean   : 514973  
    ##  3rd Qu.:0.4560   3rd Qu.: 724151   3rd Qu.:0.29803   3rd Qu.: 730351  
    ##  Max.   :0.8490   Max.   :1565890   Max.   :0.39801   Max.   :1015595  
    ##       sst             sal            xmonth            nao          
    ##  Min.   :12.77   Min.   :35.40   Min.   : 1.000   Min.   :-4.89000  
    ##  1st Qu.:13.60   1st Qu.:35.51   1st Qu.: 5.000   1st Qu.:-1.89000  
    ##  Median :13.86   Median :35.51   Median : 8.000   Median : 0.20000  
    ##  Mean   :13.87   Mean   :35.51   Mean   : 7.258   Mean   :-0.09236  
    ##  3rd Qu.:14.16   3rd Qu.:35.52   3rd Qu.: 9.000   3rd Qu.: 1.63000  
    ##  Max.   :14.73   Max.   :35.61   Max.   :12.000   Max.   : 5.08000

7. Zmiana wielkości ryby w czasie
---------------------------------

Poniższy wykres przedstawia zmianę długości śledzi wględem czasu.

<!--html_preserve-->

<script type="application/json" data-for="htmlwidget-6ab126e51ffca0561148">{"x":{"data":[{"x":[0,665.582278481013,1331.16455696203,1996.74683544304,2662.32911392405,3327.91139240506,3993.49367088608,4659.07594936709,5324.6582278481,5990.24050632911,6655.82278481013,7321.40506329114,7986.98734177215,8652.56962025316,9318.15189873418,9983.73417721519,10649.3164556962,11314.8987341772,11980.4810126582,12646.0632911392,13311.6455696203,13977.2278481013,14642.8101265823,15308.3924050633,15973.9746835443,16639.5569620253,17305.1392405063,17970.7215189873,18636.3037974684,19301.8860759494,19967.4683544304,20633.0506329114,21298.6329113924,21964.2151898734,22629.7974683544,23295.3797468354,23960.9620253165,24626.5443037975,25292.1265822785,25957.7088607595,26623.2911392405,27288.8734177215,27954.4556962025,28620.0379746835,29285.6202531646,29951.2025316456,30616.7848101266,31282.3670886076,31947.9493670886,32613.5316455696,33279.1139240506,33944.6962025316,34610.2784810127,35275.8607594937,35941.4430379747,36607.0253164557,37272.6075949367,37938.1898734177,38603.7721518987,39269.3544303797,39934.9367088608,40600.5189873418,41266.1012658228,41931.6835443038,42597.2658227848,43262.8481012658,43928.4303797468,44594.0126582278,45259.5949367089,45925.1772151899,46590.7594936709,47256.3417721519,47921.9240506329,48587.5063291139,49253.0886075949,49918.6708860759,50584.253164557,51249.835443038,51915.417721519,52581],"y":[24.3992315080778,24.5291695130141,24.6580145649872,24.7846737110339,24.9080539981911,25.0270624734954,25.1406061839839,25.2475921766931,25.34692749866,25.437526041801,25.5194131353754,25.5949447901831,25.6667704912415,25.737539723568,25.8099019721802,25.8865067220954,25.9700034583312,26.0630416659048,26.168131928154,26.2835722009096,26.4027901998548,26.51894234833,26.6251850696753,26.7146747872309,26.780567924337,26.8160209043336,26.8141901505611,26.7690500740793,26.6840841931912,26.5689109340982,26.4332509714667,26.2868249799631,26.139353634254,26.0005576090058,25.8801575788848,25.7878742185575,25.7314065211486,25.7071407500615,25.7075303663256,25.7250248823732,25.7520738106369,25.7811266635492,25.8046329535424,25.8150421930491,25.8048066306038,25.7691036724492,25.7109496573914,25.6347618085204,25.5449573489258,25.4459535016977,25.3421674899257,25.2380165366998,25.1379178651098,25.0462492015808,24.9650184726597,24.892560415082,24.8268937922657,24.7660373676291,24.7080099045905,24.6508301665681,24.5925169169802,24.5310889192449,24.464686109255,24.393623711165,24.320098515313,24.246369352344,24.1746950529031,24.1073344476353,24.0465463671856,23.9945896421992,23.953723103321,23.9259047080662,23.9107029725339,23.9065469545268,23.9118586943984,23.9250602325023,23.944573609192,23.968820864821,23.9962240397429,24.0252051743113],"text":["id: 0<br>length: 24.4","id: 665.58<br>length: 24.53","id: 1331.16<br>length: 24.66","id: 1996.75<br>length: 24.78","id: 2662.33<br>length: 24.91","id: 3327.91<br>length: 25.03","id: 3993.49<br>length: 25.14","id: 4659.08<br>length: 25.25","id: 5324.66<br>length: 25.35","id: 5990.24<br>length: 25.44","id: 6655.82<br>length: 25.52","id: 7321.41<br>length: 25.59","id: 7986.99<br>length: 25.67","id: 8652.57<br>length: 25.74","id: 9318.15<br>length: 25.81","id: 9983.73<br>length: 25.89","id: 10649.32<br>length: 25.97","id: 11314.9<br>length: 26.06","id: 11980.48<br>length: 26.17","id: 12646.06<br>length: 26.28","id: 13311.65<br>length: 26.4","id: 13977.23<br>length: 26.52","id: 14642.81<br>length: 26.63","id: 15308.39<br>length: 26.71","id: 15973.97<br>length: 26.78","id: 16639.56<br>length: 26.82","id: 17305.14<br>length: 26.81","id: 17970.72<br>length: 26.77","id: 18636.3<br>length: 26.68","id: 19301.89<br>length: 26.57","id: 19967.47<br>length: 26.43","id: 20633.05<br>length: 26.29","id: 21298.63<br>length: 26.14","id: 21964.22<br>length: 26","id: 22629.8<br>length: 25.88","id: 23295.38<br>length: 25.79","id: 23960.96<br>length: 25.73","id: 24626.54<br>length: 25.71","id: 25292.13<br>length: 25.71","id: 25957.71<br>length: 25.73","id: 26623.29<br>length: 25.75","id: 27288.87<br>length: 25.78","id: 27954.46<br>length: 25.8","id: 28620.04<br>length: 25.82","id: 29285.62<br>length: 25.8","id: 29951.2<br>length: 25.77","id: 30616.78<br>length: 25.71","id: 31282.37<br>length: 25.63","id: 31947.95<br>length: 25.54","id: 32613.53<br>length: 25.45","id: 33279.11<br>length: 25.34","id: 33944.7<br>length: 25.24","id: 34610.28<br>length: 25.14","id: 35275.86<br>length: 25.05","id: 35941.44<br>length: 24.97","id: 36607.03<br>length: 24.89","id: 37272.61<br>length: 24.83","id: 37938.19<br>length: 24.77","id: 38603.77<br>length: 24.71","id: 39269.35<br>length: 24.65","id: 39934.94<br>length: 24.59","id: 40600.52<br>length: 24.53","id: 41266.1<br>length: 24.46","id: 41931.68<br>length: 24.39","id: 42597.27<br>length: 24.32","id: 43262.85<br>length: 24.25","id: 43928.43<br>length: 24.17","id: 44594.01<br>length: 24.11","id: 45259.59<br>length: 24.05","id: 45925.18<br>length: 23.99","id: 46590.76<br>length: 23.95","id: 47256.34<br>length: 23.93","id: 47921.92<br>length: 23.91","id: 48587.51<br>length: 23.91","id: 49253.09<br>length: 23.91","id: 49918.67<br>length: 23.93","id: 50584.25<br>length: 23.94","id: 51249.84<br>length: 23.97","id: 51915.42<br>length: 24","id: 52581<br>length: 24.03"],"key":null,"type":"scatter","mode":"lines","name":"fitted values","line":{"width":3.77952755905512,"color":"rgba(51,102,255,1)","dash":"solid"},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text"},{"x":[0,665.582278481013,1331.16455696203,1996.74683544304,2662.32911392405,3327.91139240506,3993.49367088608,4659.07594936709,5324.6582278481,5990.24050632911,6655.82278481013,7321.40506329114,7986.98734177215,8652.56962025316,9318.15189873418,9983.73417721519,10649.3164556962,11314.8987341772,11980.4810126582,12646.0632911392,13311.6455696203,13977.2278481013,14642.8101265823,15308.3924050633,15973.9746835443,16639.5569620253,17305.1392405063,17970.7215189873,18636.3037974684,19301.8860759494,19967.4683544304,20633.0506329114,21298.6329113924,21964.2151898734,22629.7974683544,23295.3797468354,23960.9620253165,24626.5443037975,25292.1265822785,25957.7088607595,26623.2911392405,27288.8734177215,27954.4556962025,28620.0379746835,29285.6202531646,29951.2025316456,30616.7848101266,31282.3670886076,31947.9493670886,32613.5316455696,33279.1139240506,33944.6962025316,34610.2784810127,35275.8607594937,35941.4430379747,36607.0253164557,37272.6075949367,37938.1898734177,38603.7721518987,39269.3544303797,39934.9367088608,40600.5189873418,41266.1012658228,41931.6835443038,42597.2658227848,43262.8481012658,43928.4303797468,44594.0126582278,45259.5949367089,45925.1772151899,46590.7594936709,47256.3417721519,47921.9240506329,48587.5063291139,49253.0886075949,49918.6708860759,50584.253164557,51249.835443038,51915.417721519,52581,52581,52581,51915.417721519,51249.835443038,50584.253164557,49918.6708860759,49253.0886075949,48587.5063291139,47921.9240506329,47256.3417721519,46590.7594936709,45925.1772151899,45259.5949367089,44594.0126582278,43928.4303797468,43262.8481012658,42597.2658227848,41931.6835443038,41266.1012658228,40600.5189873418,39934.9367088608,39269.3544303797,38603.7721518987,37938.1898734177,37272.6075949367,36607.0253164557,35941.4430379747,35275.8607594937,34610.2784810127,33944.6962025316,33279.1139240506,32613.5316455696,31947.9493670886,31282.3670886076,30616.7848101266,29951.2025316456,29285.6202531646,28620.0379746835,27954.4556962025,27288.8734177215,26623.2911392405,25957.7088607595,25292.1265822785,24626.5443037975,23960.9620253165,23295.3797468354,22629.7974683544,21964.2151898734,21298.6329113924,20633.0506329114,19967.4683544304,19301.8860759494,18636.3037974684,17970.7215189873,17305.1392405063,16639.5569620253,15973.9746835443,15308.3924050633,14642.8101265823,13977.2278481013,13311.6455696203,12646.0632911392,11980.4810126582,11314.8987341772,10649.3164556962,9983.73417721519,9318.15189873418,8652.56962025316,7986.98734177215,7321.40506329114,6655.82278481013,5990.24050632911,5324.6582278481,4659.07594936709,3993.49367088608,3327.91139240506,2662.32911392405,1996.74683544304,1331.16455696203,665.582278481013,0,0],"y":[24.3267572614693,24.4694144173589,24.6094261727919,24.7446867415255,24.8730725185675,24.9932429141026,25.1052771170574,25.2099174111257,25.307560913968,25.3980255609111,25.4814740743594,25.5594773227311,25.6335951380404,25.705423330634,25.7770946406164,25.8516325066158,25.9326907901676,26.0240323448498,26.1290560693297,26.2461050885989,26.3677303697169,26.4859672918042,26.5929561317124,26.6814637429857,26.7451542865894,26.7782433008728,26.7749895069232,26.7301708303241,26.6470639783324,26.5343260299747,26.4005421128618,26.2545012055366,26.1057212324086,25.9645933349922,25.8419458258615,25.74856996041,25.6928219085671,25.6706339701544,25.673435440602,25.692543357869,25.7195922861327,25.7470317378237,25.7681261736266,25.7764575804466,25.7655023724179,25.730891919367,25.6749853832995,25.6011294065835,25.5126335744066,25.4132446430102,25.3075825857324,25.2009963217769,25.0990386212849,25.00704855786,24.9272408691099,24.8571467772711,24.7936827480366,24.7338084298149,24.6750348483581,24.6157703368243,24.5550498050864,24.4920130607714,24.4256767883961,24.3563110429851,24.2852242996068,24.213562020416,24.142578659594,24.074159094157,24.011078899572,23.9566505810656,23.9142226222466,23.8865381230361,23.8730282065172,23.8712178873297,23.8780391355504,23.890078755065,23.9045866440048,23.9202324790763,23.9364689524828,23.9527309378781,23.9527309378781,24.0976794107445,24.055979127003,24.0174092505656,23.9845605743791,23.9600417099395,23.9456782532465,23.9418760217239,23.9483777385506,23.9652712930962,23.9932235843953,24.0325287033327,24.0820138347993,24.1405098011136,24.2068114462122,24.2791766842721,24.3549727310193,24.430936379345,24.503695430114,24.5701647777184,24.6299840288739,24.6858899963119,24.7409849608229,24.7982663054433,24.8601048364947,24.9279740528928,25.0027960762096,25.0854498453017,25.1767971089346,25.2750367516227,25.3767523941191,25.4786623603852,25.5772811234451,25.6683942104573,25.7469139314834,25.8073154255314,25.8441108887897,25.8536268056515,25.8411397334582,25.8152215892746,25.7845553351411,25.7575064068775,25.7416252920492,25.7436475299687,25.76999113373,25.827178476705,25.918369331908,26.0365218830193,26.1729860360995,26.3191487543897,26.4659598300716,26.6034958382217,26.72110440805,26.8079293178346,26.853390794199,26.8537985077944,26.8159815620845,26.7478858314761,26.6574140076383,26.5519174048558,26.4378500299928,26.3210393132202,26.2072077869784,26.1020509869599,26.0073161264947,25.9213809375751,25.8427093037441,25.7696561165021,25.6999458444426,25.6304122576351,25.5573521963914,25.477026522691,25.386294083352,25.2852669422605,25.1759352509103,25.0608820328883,24.9430354778147,24.8246606805424,24.7066029571825,24.5889246086693,24.4717057546863,24.3267572614693],"text":["id: 0<br>length: 24.4","id: 665.58<br>length: 24.53","id: 1331.16<br>length: 24.66","id: 1996.75<br>length: 24.78","id: 2662.33<br>length: 24.91","id: 3327.91<br>length: 25.03","id: 3993.49<br>length: 25.14","id: 4659.08<br>length: 25.25","id: 5324.66<br>length: 25.35","id: 5990.24<br>length: 25.44","id: 6655.82<br>length: 25.52","id: 7321.41<br>length: 25.59","id: 7986.99<br>length: 25.67","id: 8652.57<br>length: 25.74","id: 9318.15<br>length: 25.81","id: 9983.73<br>length: 25.89","id: 10649.32<br>length: 25.97","id: 11314.9<br>length: 26.06","id: 11980.48<br>length: 26.17","id: 12646.06<br>length: 26.28","id: 13311.65<br>length: 26.4","id: 13977.23<br>length: 26.52","id: 14642.81<br>length: 26.63","id: 15308.39<br>length: 26.71","id: 15973.97<br>length: 26.78","id: 16639.56<br>length: 26.82","id: 17305.14<br>length: 26.81","id: 17970.72<br>length: 26.77","id: 18636.3<br>length: 26.68","id: 19301.89<br>length: 26.57","id: 19967.47<br>length: 26.43","id: 20633.05<br>length: 26.29","id: 21298.63<br>length: 26.14","id: 21964.22<br>length: 26","id: 22629.8<br>length: 25.88","id: 23295.38<br>length: 25.79","id: 23960.96<br>length: 25.73","id: 24626.54<br>length: 25.71","id: 25292.13<br>length: 25.71","id: 25957.71<br>length: 25.73","id: 26623.29<br>length: 25.75","id: 27288.87<br>length: 25.78","id: 27954.46<br>length: 25.8","id: 28620.04<br>length: 25.82","id: 29285.62<br>length: 25.8","id: 29951.2<br>length: 25.77","id: 30616.78<br>length: 25.71","id: 31282.37<br>length: 25.63","id: 31947.95<br>length: 25.54","id: 32613.53<br>length: 25.45","id: 33279.11<br>length: 25.34","id: 33944.7<br>length: 25.24","id: 34610.28<br>length: 25.14","id: 35275.86<br>length: 25.05","id: 35941.44<br>length: 24.97","id: 36607.03<br>length: 24.89","id: 37272.61<br>length: 24.83","id: 37938.19<br>length: 24.77","id: 38603.77<br>length: 24.71","id: 39269.35<br>length: 24.65","id: 39934.94<br>length: 24.59","id: 40600.52<br>length: 24.53","id: 41266.1<br>length: 24.46","id: 41931.68<br>length: 24.39","id: 42597.27<br>length: 24.32","id: 43262.85<br>length: 24.25","id: 43928.43<br>length: 24.17","id: 44594.01<br>length: 24.11","id: 45259.59<br>length: 24.05","id: 45925.18<br>length: 23.99","id: 46590.76<br>length: 23.95","id: 47256.34<br>length: 23.93","id: 47921.92<br>length: 23.91","id: 48587.51<br>length: 23.91","id: 49253.09<br>length: 23.91","id: 49918.67<br>length: 23.93","id: 50584.25<br>length: 23.94","id: 51249.84<br>length: 23.97","id: 51915.42<br>length: 24","id: 52581<br>length: 24.03","id: 52581<br>length: 24.03","id: 52581<br>length: 24.03","id: 51915.42<br>length: 24","id: 51249.84<br>length: 23.97","id: 50584.25<br>length: 23.94","id: 49918.67<br>length: 23.93","id: 49253.09<br>length: 23.91","id: 48587.51<br>length: 23.91","id: 47921.92<br>length: 23.91","id: 47256.34<br>length: 23.93","id: 46590.76<br>length: 23.95","id: 45925.18<br>length: 23.99","id: 45259.59<br>length: 24.05","id: 44594.01<br>length: 24.11","id: 43928.43<br>length: 24.17","id: 43262.85<br>length: 24.25","id: 42597.27<br>length: 24.32","id: 41931.68<br>length: 24.39","id: 41266.1<br>length: 24.46","id: 40600.52<br>length: 24.53","id: 39934.94<br>length: 24.59","id: 39269.35<br>length: 24.65","id: 38603.77<br>length: 24.71","id: 37938.19<br>length: 24.77","id: 37272.61<br>length: 24.83","id: 36607.03<br>length: 24.89","id: 35941.44<br>length: 24.97","id: 35275.86<br>length: 25.05","id: 34610.28<br>length: 25.14","id: 33944.7<br>length: 25.24","id: 33279.11<br>length: 25.34","id: 32613.53<br>length: 25.45","id: 31947.95<br>length: 25.54","id: 31282.37<br>length: 25.63","id: 30616.78<br>length: 25.71","id: 29951.2<br>length: 25.77","id: 29285.62<br>length: 25.8","id: 28620.04<br>length: 25.82","id: 27954.46<br>length: 25.8","id: 27288.87<br>length: 25.78","id: 26623.29<br>length: 25.75","id: 25957.71<br>length: 25.73","id: 25292.13<br>length: 25.71","id: 24626.54<br>length: 25.71","id: 23960.96<br>length: 25.73","id: 23295.38<br>length: 25.79","id: 22629.8<br>length: 25.88","id: 21964.22<br>length: 26","id: 21298.63<br>length: 26.14","id: 20633.05<br>length: 26.29","id: 19967.47<br>length: 26.43","id: 19301.89<br>length: 26.57","id: 18636.3<br>length: 26.68","id: 17970.72<br>length: 26.77","id: 17305.14<br>length: 26.81","id: 16639.56<br>length: 26.82","id: 15973.97<br>length: 26.78","id: 15308.39<br>length: 26.71","id: 14642.81<br>length: 26.63","id: 13977.23<br>length: 26.52","id: 13311.65<br>length: 26.4","id: 12646.06<br>length: 26.28","id: 11980.48<br>length: 26.17","id: 11314.9<br>length: 26.06","id: 10649.32<br>length: 25.97","id: 9983.73<br>length: 25.89","id: 9318.15<br>length: 25.81","id: 8652.57<br>length: 25.74","id: 7986.99<br>length: 25.67","id: 7321.41<br>length: 25.59","id: 6655.82<br>length: 25.52","id: 5990.24<br>length: 25.44","id: 5324.66<br>length: 25.35","id: 4659.08<br>length: 25.25","id: 3993.49<br>length: 25.14","id: 3327.91<br>length: 25.03","id: 2662.33<br>length: 24.91","id: 1996.75<br>length: 24.78","id: 1331.16<br>length: 24.66","id: 665.58<br>length: 24.53","id: 0<br>length: 24.4","id: 0<br>length: 24.4"],"key":null,"type":"scatter","mode":"lines","line":{"width":3.77952755905512,"color":"transparent","dash":"solid"},"fill":"toself","fillcolor":"rgba(153,153,153,0.4)","hoveron":"points","hoverinfo":"x+y","showlegend":false,"xaxis":"x","yaxis":"y","name":""}],"layout":{"margin":{"t":26.2283105022831,"r":7.30593607305936,"b":40.1826484018265,"l":37.2602739726027},"plot_bgcolor":"rgba(127,127,127,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"xaxis":{"domain":[0,1],"type":"linear","autorange":false,"tickmode":"array","range":[-2629.05,55210.05],"ticktext":["0","10000","20000","30000","40000","50000"],"tickvals":[0,10000,20000,30000,40000,50000],"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.33208800332088,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(107,107,107,1)","gridwidth":0.33208800332088,"zeroline":false,"anchor":"y","title":"czas","titlefont":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"type":"linear","autorange":false,"tickmode":"array","range":[23.7220888563065,27.0029275388176],"ticktext":["24","25","26","27"],"tickvals":[24,25,26,27],"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.33208800332088,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":11.689497716895},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(107,107,107,1)","gridwidth":0.33208800332088,"zeroline":false,"anchor":"x","title":"długość śledzia [cm]","titlefont":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895}},"hovermode":"closest"},"source":"A","config":{"modeBarButtonsToAdd":[{"name":"Collaborate","icon":{"width":1000,"ascent":500,"descent":-50,"path":"M487 375c7-10 9-23 5-36l-79-259c-3-12-11-23-22-31-11-8-22-12-35-12l-263 0c-15 0-29 5-43 15-13 10-23 23-28 37-5 13-5 25-1 37 0 0 0 3 1 7 1 5 1 8 1 11 0 2 0 4-1 6 0 3-1 5-1 6 1 2 2 4 3 6 1 2 2 4 4 6 2 3 4 5 5 7 5 7 9 16 13 26 4 10 7 19 9 26 0 2 0 5 0 9-1 4-1 6 0 8 0 2 2 5 4 8 3 3 5 5 5 7 4 6 8 15 12 26 4 11 7 19 7 26 1 1 0 4 0 9-1 4-1 7 0 8 1 2 3 5 6 8 4 4 6 6 6 7 4 5 8 13 13 24 4 11 7 20 7 28 1 1 0 4 0 7-1 3-1 6-1 7 0 2 1 4 3 6 1 1 3 4 5 6 2 3 3 5 5 6 1 2 3 5 4 9 2 3 3 7 5 10 1 3 2 6 4 10 2 4 4 7 6 9 2 3 4 5 7 7 3 2 7 3 11 3 3 0 8 0 13-1l0-1c7 2 12 2 14 2l218 0c14 0 25-5 32-16 8-10 10-23 6-37l-79-259c-7-22-13-37-20-43-7-7-19-10-37-10l-248 0c-5 0-9-2-11-5-2-3-2-7 0-12 4-13 18-20 41-20l264 0c5 0 10 2 16 5 5 3 8 6 10 11l85 282c2 5 2 10 2 17 7-3 13-7 17-13z m-304 0c-1-3-1-5 0-7 1-1 3-2 6-2l174 0c2 0 4 1 7 2 2 2 4 4 5 7l6 18c0 3 0 5-1 7-1 1-3 2-6 2l-173 0c-3 0-5-1-8-2-2-2-4-4-4-7z m-24-73c-1-3-1-5 0-7 2-2 3-2 6-2l174 0c2 0 5 0 7 2 3 2 4 4 5 7l6 18c1 2 0 5-1 6-1 2-3 3-5 3l-174 0c-3 0-5-1-7-3-3-1-4-4-5-6z"},"click":"function(gd) { \n        // is this being viewed in RStudio?\n        if (location.search == '?viewer_pane=1') {\n          alert('To learn about plotly for collaboration, visit:\\n https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html');\n        } else {\n          window.open('https://cpsievert.github.io/plotly_book/plot-ly-for-collaboration.html', '_blank');\n        }\n      }"}],"modeBarButtonsToRemove":["sendDataToCloud"]},"base_url":"https://plot.ly"},"evals":["config.modeBarButtonsToAdd.0.click"],"jsHooks":[]}</script>
<!--/html_preserve-->
8. Graficzna prezentacja korelacji pomiędzy danymi
--------------------------------------------------

Największa korelacja dotyczy par lcop1 i chel1 oraz lcop2 i chel2, z
tego powodu dane zostały usunięte w dalszych etapach analizy.
Zoboserwoano również duży współczynnik korelacji pomiędzy cumf oraz
totaln - co naturalnie zmusza do postawienia wniosku, że wraz ze
wzrostem łącznej liczby ryb złowionych w ramach pojedynczego rownolegle
zwiększa się natężenie połowów. Dodatkowo można stwierdzić, że łączne
roczne natężenie połowów (cumf) było wysokie tak samo jak ich
intensywność (fbar).

    cor_dat <- cor(data_re %>% select(-id))
    corrplot(cor_dat, method="circle")

![](Analiza_długości_śledziarmd_files/figure-markdown_strict/correlation_analysis-1.png)

9. Regresor przewidujący rozmiar śledzia
----------------------------------------

Podział zbioru danych na zbiór treningowy i zbiór testowy. Dla zbioru
treningowego użyte zostały dane bez wartości NA, które zostały usunięte
ze względu na brak wpływu na wartość atrybutu "length". Dla zbioru
testowego zastosowano dane także bez tych atrybutów, które nie zostały
uwzględnione dla danych treningowych.

    clean_data <- select(data_re,-c(chel1,chel2,cumf))

    w_tren <-
      createDataPartition(
        y = clean_data$length,
        p = .80,
        list = FALSE)
    training <- clean_data[ w_tren,]
    testing  <- clean_data[-w_tren,]
    control <- trainControl(
      method = "repeatedcv",
      number = 3,
      repeats = 3)
    fish_done <- train(length ~ .,
                 data = training,
                 method = "rf",
                 trControl = control,
                 importance = TRUE,
                 ntree = 10
    )

10. Model
---------

    fish_done

    ## Random Forest 
    ## 
    ## 42067 samples
    ##    12 predictors
    ## 
    ## No pre-processing
    ## Resampling: Cross-Validated (3 fold, repeated 3 times) 
    ## Summary of sample sizes: 28044, 28046, 28044, 28046, 28043, 28045, ... 
    ## Resampling results across tuning parameters:
    ## 
    ##   mtry  RMSE      Rsquared 
    ##    2    1.134725  0.5283713
    ##    7    1.087922  0.5670916
    ##   12    1.182886  0.5115481
    ## 
    ## RMSE was used to select the optimal model using  the smallest value.
    ## The final value used for the model was mtry = 7.

11. Przewidywanie wartości i ocena błędu
----------------------------------------

Poniższe wyniki wskazują, że zbiór nie jest przetrenowany.

    testing <- na.omit(testing)
    przew <- predict(fish_done,testing)

    ## Loading required package: randomForest

    ## randomForest 4.6-12

    ## Type rfNews() to see new features/changes/bug fixes.

    ## 
    ## Attaching package: 'randomForest'

    ## The following object is masked from 'package:ggplot2':
    ## 
    ##     margin

    ## The following object is masked from 'package:dplyr':
    ## 
    ##     combine

    aktualne <- testing[,"length"]
    RMSE <- sqrt(mean((przew-aktualne)^2))
    RMSE

    ## [1] 1.085863

12. Analiza ważności atrybutów
------------------------------

    varImp(fish_done$finalModel)

    ##          Overall
    ## id     14.940561
    ## cfin1   5.424381
    ## cfin2   5.004971
    ## lcop1   7.429268
    ## lcop2   4.964534
    ## fbar    4.901743
    ## recr    2.895514
    ## totaln  4.454764
    ## sst     5.526494
    ## sal     2.169499
    ## xmonth 42.912946
    ## nao     6.594056

13. Wnioski
-----------

Według powyższej analizy, na długość śledzia najbardziej ma wpływ
atrybut xmonth. Można wysnuć wnioski, że ma to wpływ z występowaniem
planktonu o konkrentej porze roku.

------------------------------------------------------------------------

Moment, when laptop turns into heli because of Random Forest:

![Możliwość używania gifów wpływa pozytywnie na dalszą współpracę z
językiem R](https://media.giphy.com/media/26hit6zxaNMzsldDy/giphy.gif)
