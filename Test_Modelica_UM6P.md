# Atterrissage sur MARS
Dans cette section on réalisera un model MarsLanding pour un atterrissage réussi de la fusée Apollo sur Mars tout en se basant sur le modèle MoonLanding déjà traité dans le tutoriel Modelica_Tutorial_Fritzson ; par conséquent, pour parvenir à nos fins on a procédé comme suit :
### - Présentation très simplifiée des équations physiques pour spécifier le comportement des classes dans Modelica ;
### - Création des classes interactives pour résoudre le problème de l’atterrissage sur Mars ;
### - Simulation de l'atterrissage sur Mars.

## 1.  Présentation très simplifiée des équations physiques pour la spécification du comportement des classes dans Modelica :
Pour simplifier les calculs, on a considéré un atterrissage vertical sans frottement. Le problème se limite à une seule dimension (comme le montre la figure ci-après).

  ![clipboard](https://i.imgur.com/hqudlKd.png)
Si on appelle Thrust la poussée du moteur et mg la force de gravité appliquée par le corps céleste sur Apollo, l’équation du mouvement permet d’écrire : 

![clipboard](https://i.imgur.com/g4GEBpw.png)

Aussi, la loi universelle de la gravitation permet d’écrire :

![clipboard](https://i.imgur.com/nKla3cz.png)

## 2.  Création des classes interactives entre elles pour résoudre le problème de l’atterrissage sur Mars :
Vue que les équations interagissent entre eux et pour simplifier la modélisation de l’atterrissage sur Mars à partir de l’atterrissage sur la lune, les classes (class) et l’héritage (extends) seront la meilleure solution adaptée à cette problématique;

`class param "paramètre à utiliser dans CeiestiaiBody et Rocket pour éviter la répétition "`
    
    Real mass(unit="Kg"); 
    String name;
`end param;`

`class CeiestiaiBody "class à utiliser dans Moonlanding et Marslanding pour éviter la répétition "`

    extends param;
    constant Real g = 6.672e-11(unit="N.m^2.Kg^(-2)")"constante  gravitationnelle";
    parameter Real radius(unit="m")"le rayon du Corps céleste";
   
`end CeiestiaiBody;`

`class Rocket"class à utiliser dans Moonlanding et Marslanding pour éviter la répétition "`

    extends param; 
    parameter Real massLossRate=0.000277;
    Real altitude(start= 59404,unit="m");//valeurs initiaux
    Real velocity(start= -2003,unit="m/s");
    Real acceleration(unit="m/s2");
    Real thrust(unit="N");
    Real gravity(unit="m/s2");
    equation
    (thrust - mass * gravity)/mass =  acceleration;//calcul de l'acceleration
    der(mass) = -massLossRate * abs(thrust);//calcul de la variation de la masse de la fusee
    der(altitude) = velocity;//calcul de la variation de l'altitude de la fusee
    der(velocity) = acceleration;//calcul de la variation de la   vitesse de la fusee
`end Rocket;`

`class Moonlanding`

    parameter Real forcel(unit="N") = 36350;//La force de poussée de la fusée avant un temps de 43,2 secondes
    parameter Real force2(unit="N") = 1308;//La force de poussée de la fusée aprés 43,2 secondes et avant 210
    protected//Les paramètres ci-dessus ne seront pas visible dans les variables de la section tracé
    parameter Real thrustEndTime(unit="s") = 210;
    parameter Real thrustDecreaseTime(unit="s") = 43.2;
    public// Les paramètres ci-dessus seront visible dans les variables de la section tracé
    Rocket apollo(name="apollol3", mass(start=1038.358));
    CeiestiaiBody moon(mass=7.382e22,radius=1.738e6,name="moon");//Propriétés de la lune
    equation
    apollo.thrust = if (time<thrustDecreaseTime) then forcel// calcul de la variation de la force de poussée
    else if (time<thrustEndTime) then force2
    else 0;
    apollo.gravity = moon.g*moon.mass/(apollo.altitude+moon.radius)^2;// calcul de la variation de la force de gravity
    when apollo.altitude < 0 then
    terminate("La fusee touche le sol de la lune");
    end when;
    when apollo.velocity < 0 then 
    terminate("La fusee touche le sol de la lune");
    end when;
`end Moonlanding;`

Pour l’atterrissage sur Mars on a hérité le modèle Moonlanding, et pour avoir un atterrissage réussi il suffit que les accélérations d’Apollo sur Moon et sur Mars soient égales, cela veut dire que le couple des forces pour avoir un atterrissage réussi sur Mars (Marslanding) sera en fonction des deux forces f1 et f2 déjà données dans l’exemple Moonlanding, par conséquent, on aura la classe ci-dessous qui présente l’atterrissage d’Apollo sur Mars ;

`class Marslanding`

    extends Moon;
    CeiestiaiBody mars(mass=6.391e23,radius=3.3895e6,name="mars");
    Rocket apolloM(name="apollol3", mass(start=1038.358));
    equation 
    apolloM.thrust = if (time<thrustDecreaseTime) then ((forcel-  apollo.mass*apollo.gravity)*(apolloM.mass/apollo.mass))+(apolloM.mass*apolloM.gravity)
    else 
    if (time<thrustEndTime) then ((force2-apollo.mass*apollo.gravity)*(apolloM.mass/apollo.mass))+(apolloM.mass*apolloM.gravity)
    else 
       0;
    apolloM.gravity = mars.g*mars.mass/(apolloM.altitude+mars.radius)^2;
    when apolloM.altitude < 0 then
    terminate("La fusee touche le sol du Mars");
    end when;
    when apolloM.velocity < 0 then 
    terminate("La fusee touche le sol du Mars");
    end when;
`end Marslanding;`

## 3.  Simulation de l'atterrissage sur Mars :
Le modèle Marslanding est simulé sur OpenModelica sur un intervalle du temps de [0,230] (s); et pour s'assurer qu'il y aura un bon couple de force (force1, force2) pour un atterrissage réussi sur Mars, il faudra trouver à la fin de la simulation: une altitude, vitesse qui tendent vers zéro et une gravité qui tend vers la gravité au sol de Mars qui vaut 3,711 m/s², pour ce faire, on présentera dans les graphes ci-dessous l'évolution de ceux-ci en fonction du temps.

![clipboard](https://i.imgur.com/DrjjkRB.png) ![clipboard](https://i.imgur.com/303fj8i.png)

![clipboard](https://i.imgur.com/Peie85K.png)

On voit clairement dans les graphes ci-dessus que les conditions d’un atterrissage réussi sont atteintes, ce qui permet de dire que le modèle Marslanding qu’on a conçu nous a donné un bon couple des forces (force1, force2) pour un atterrissage réussi d’Apollo sur Mars (voir le graphe ci-dessous) ;

![clipboard](https://i.imgur.com/7kGU03L.png)

En lisant les valeurs de la variation de la poussée (Thrust) sur le fichier Excel exporté depuis OpenModelica à travers la fonction « exported_Variables », on a pu extraire facilement le couple des forces (force1= 38489.3N, force2= 2160.27) pour avoir un atterrissage réussi d’Apollo sur Mars.

# Ajout d’une 4éme Pipe reliant la sortie de Pipe1 à boundary2

Pour atteindre l’objectif demandé qui est de lier la pipe4 à la sortie de la pipe1 et à l’entrée de boundary2, on a travaillé sur le Package Fluid et le package Media existés dans Navigateur de librairies sur OpenModelica.

## 1.  Schéma représentatif et compilation du modèle conçu :

![clipboard](https://i.imgur.com/8Esx4Ji.png)

   Quand on a consulté le code Modelica de ce modèle, on a constaté que la pipe4 n’est pas complète, d’où, le programme ne s’est pas compilé, par conséquent, on lui a ajouté les informations qui lui manquait : liquide, longueur et diamètre (voir la déclaration ci-dessous), et le modèle a bien été compilé.

Modelica.Fluid.Pipes.StaticPipe pipe4( redeclare package Medium = water length=20,diameter=1.5)

## 2.  Simulation du modèle :
   La simulation a été faite sur un intervalle du temps de [0,100]. En se basant sur le débit massique sorti de boundary1 et les débits rentrés de boundary2, on constate que le débit se conserve (3717,34 + 10685,7*2) e= (25088,7) s, comme le montrent les graphes ci-dessous :

![clipboard](https://i.imgur.com/BsKw6Im.png) ![clipboard](https://i.imgur.com/i2wiEtF.png)

## 3.  Tests de validation du modèle :
   Dans la simulation présentée ci-dessus, on a considéré le modèle comme une boite noire, du coup, on ne s’est pas intéressé par qu’est ce qui s’est passé dans chaque système unitaire, et pour faire les tests de validation on doit y passer, par ce fait, on a proposé les tests suivants :

-  Test1 : Changer le diamètre de la pipe1 par une valeur d=1.5m et visualiser les résultats en pression avec la même pipe en changeant que le diamètre d’une valeur d=10m, ci-dessous les résultats obtenus ;

![clipboard](https://i.imgur.com/3iLRvpN.png) ![clipboard](https://i.imgur.com/gJAh4nc.png)

-  Test2 : Changer la longueur de la pipe4 par une valeur L=30m et visualiser les résultats en pression avec la même pipe en changeant que la longueur d’une valeur L=50m, ci-dessous les résultats obtenus ;

![clipboard](https://i.imgur.com/ADuU0PE.png) ![clipboard](https://i.imgur.com/TzOFOiW.png)

Faisant une interprétation physique des résultats obtenus ci-dessus, on remarque que dans le premier test (Test1) que lorsque on augmente la valeur du diamètre de la pipe1 et on fixe sa longueur, les pertes de charges diminues ce qui coïncide avec la réalité, et pour le deuxième test (Test2) effectué on sait que la pression au niveau de boundary2 est constante et vaut 1bar, et pour combler les pertes de charge au niveau de la pipe4 il faut que la pression à son entrée augmente avec l’augmentation de sa longueur ce qui se voit dans les graphes des résultats de Test2 ; Par conséquent on peut dire que notre modèle est validé.


   Le langage Modelica, ayant le principe de programmation orientée objet, permet une grande flexibilité surtout en ce qui concerne les interactions entres les objets. Cet exemple qu’on traité est la grande preuve, que le fait de rajouter ou d’éliminer quelques objets d’un circuit ou programme n’a aucun effet sur la réussite de modélisation, ou d’interactions entre les objets. Il reste seulement de reparamétrer les objets selon le besoin.
