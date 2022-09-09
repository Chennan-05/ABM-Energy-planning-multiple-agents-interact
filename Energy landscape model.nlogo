extensions [ gis  csv matrix]
breed [spinners spinner]

Globals [
  DM;; decision makers, in the first step set only one DM-investor
  actor-type-list; Investor, policy maker,public
  tech-type-list; 0-6 NG Nuclear Wind PV Hydro BIO WTE

  price  initial-price initial-standard-price price-tmp
  Quan   initial-Quan
  M-share M-share-previous M-share-next M-share-sum
  total-con  total-pro  gap Tar
  con-rate
  R

  ;;C1-2  Levelized cost of electricity (yuan/kWh) Energy efficiency (%)
  ;;C3-6  CO2 emission (g/kWh) SO2 emission (g/kWh) NOx emission (g/kWh)  Total particulate matter (g/kWh)
  ;;C7-9  Human toxicity potential (kg 1,4 DCB‡ eq./kWh) Job creation (jobs/MWa) Social acceptance (ordinal scale)
  ;;C10-11 Secured capacity (%) Capacity factor (%)
  C1 C2 C3 C4 C5 C6 C7 C8 C9 C10 C11; criteria for technology
  C1-norm C2-norm C3-norm C4-norm C5-norm C6-norm C7-norm C8-norm C9-norm C10-norm C11-norm C12-norm C13-norm C14-norm;
  W-eco1 W-eco2 W-tec1 W-tec2 W-soc1 W-soc2 W-soc3 W-env1 W-env2 W-env3 W-env4 total-weight; weight of criteria
  C-IN C-PM C-PO

  P-NG P-Nuclear P-Wind P-PV P-Hydro P-Biomass P-WTE  P-total-tech
  P-NG-initial P-Nuclear-initial P-wind-initial P-PV-initial P-Hydro-initial P-Biomass-initial P-WTE-initial
  P-NG-start   P-Nuclear-start P-wind-start    P-PV-start   P-Hydro-start   P-Biomass-start P-WTE-start
  P0-list P1-list P2-list P3-list

  MX-NG MX-Nuclear MX-Wind MX-PV MX-Hydro MX-Biomass MX-WTE  MX-Nash

  ;GHG-emission
  num-ng num-nuclear num-wind num-pv num-hydro num-biomass num-wte
  num-ng-list num-nuclear-list num-wind-list num-pv-list num-hydro-list num-biomass-list num-wte-list
 ]

patches-own[
  S-a-NG S-a-Nuclear S-a-wind S-a-PV S-a-Hydro S-a-Biomass S-a-WTE S-b S-c S-d S-e S-f S-g S-h S-i ;; Spatial fator GIS loading data S-a theorotical energy potential, S-b levation S-c slop S-d water S-e grid S-f
  S-NG S-Nuclear S-wind S-PV S-hydro S-Biomass S-WTE;; Spatial potential of a techonology (WSM of S-a S-b and S-c)
  S-ng-PC S-Nuclear-PC S-wind-PC S-PV-PC S-hydro-PC S-Biomass-PC S-WTE-PC
  S-NG-norm S-Nuclear-norm S-wind-norm S-PV-norm S-Hydro-norm S-Biomass-norm S-WTE-norm;; normalized Spatial potential

  Q-NG Q-Nuclear Q-wind Q-PV Q-Hydro Q-Biomass Q-WTE Q-total

  X-NG X-Nuclear X-wind X-PV X-Hydro X-Biomass X-WTE X-total
  SI-NG SI-Nuclear SI-wind SI-PV SI-Hydro SI-Biomass SI-WTE
  PSI

  Nash-in   Nash-pm  Nash-pu Nash-total

  P-NG-next-year P-Nuclear-next-year P-wind-next-year P-PV-next-year P-Hydro-next-year P-Biomass-next-year P-WTE-next-year P-total;; to present each years priority
  P-NG-previous-year P-Nuclear-previous-year P-wind-previous-year P-PV-previous-year P-Hydro-previous-year P-Biomass-previous-year P-WTE-previous-year;l to present  last years priority P-privious + Maginal value = P-next

  total-preferences-new-Actor

  P0 P1 P2 P3 P-game P-negotiation  tmp tmp-n max-tmp max-tmp-n max2-tmp-n
  X0 X1 X2 X3 n m k
]

  ;;input data *******************************************************************************************************************************************************************************************************
to load-map

  clear-all
  gis:apply-raster gis:load-dataset "data01/NG.asc"       S-a-NG
  gis:apply-raster gis:load-dataset "data01/Nuclear.asc"  S-a-Nuclear
  gis:apply-raster gis:load-dataset "data01/Wind.asc"     S-a-wind
  gis:apply-raster gis:load-dataset "data01/Solar.asc"    S-a-PV
  gis:apply-raster gis:load-dataset "data01/Hydro.asc"    S-a-Hydro
  gis:apply-raster gis:load-dataset "data01/Biomass.asc"  S-a-Biomass
  gis:apply-raster gis:load-dataset "data01/WTE.asc"      S-a-WTE
  gis:apply-raster gis:load-dataset "data01/Elevation.asc"S-b
  gis:apply-raster gis:load-dataset "data01/Slope.asc"    S-c
  gis:apply-raster gis:load-dataset "data01/Road.asc"     S-d
  gis:apply-raster gis:load-dataset "data01/Water.asc"    S-e
  gis:apply-raster gis:load-dataset "data01/Grid.asc"     S-f
  gis:apply-raster gis:load-dataset "data01/Energydemand.asc"      S-g
  gis:apply-raster gis:load-dataset "data01/Pop.asc"      S-h
  gis:apply-raster gis:load-dataset "data01/Eco.asc"      S-i
  gis:apply-raster gis:load-dataset "data01/NGAHP.asc"        S-NG
  gis:apply-raster gis:load-dataset "data01/NuclearAHP.asc"   S-Nuclear
  gis:apply-raster gis:load-dataset "data01/WindAHP.asc"      S-wind
  gis:apply-raster gis:load-dataset "data01/SolarAHP.asc"     S-PV
  gis:apply-raster gis:load-dataset "data01/HydroAHP.asc"     S-Hydro
  gis:apply-raster gis:load-dataset "data01/BiomassAHP.asc"   S-Biomass
  gis:apply-raster gis:load-dataset "data01/WtEAHP.asc"       S-WTE

  gis:set-world-envelope gis:envelope-of (gis:load-dataset "data01/NG.asc")

  set DM  patches with [S-a-NG >= 0 or S-a-NG <= 0 ]
  output-print word "Count total patches:" count (patches)
  output-print word "Count DM:" count (DM)
  output-print word "Approx. area of DM (km2): "  round ( 360000 / count DM )
  output-print      "Finished loading GIS!"
  ask patches [set pcolor WHITE]
  ask DM [set pcolor 3]
  set spatial_boundary "BOUN"
end

to show-map
;;show S data map========================================================================================================================================================================================================
 ; ask patches [set pcolor red]
  ask DM [
   if spatial_boundary = "NG"       [ set tmp S-a-NG set pcolor scale-color brown tmp 1.2 0]
   if spatial_boundary = "Nuclear"  [ set tmp S-a-Nuclear set pcolor scale-color violet tmp 1.2 0]
   if spatial_boundary = "Wind"     [ set tmp S-a-wind set pcolor scale-color sky tmp 1.2 0]
   if spatial_boundary = "PV"       [ set tmp S-a-PV set pcolor scale-color orange tmp 1.2 0]
   if spatial_boundary = "Hydro"    [ set tmp S-a-Hydro set pcolor scale-color blue tmp 1.2 0]
   if spatial_boundary = "Biomass"  [ set tmp S-a-Biomass set pcolor scale-color lime tmp 1.2 0]
   if spatial_boundary = "WTE"      [ set tmp S-a-WTE set pcolor scale-color yellow tmp 1.2 0]
   if spatial_boundary = "Elevation"[ set tmp S-b set pcolor scale-color 77 tmp 1.5 0]
   if spatial_boundary = "Slop"     [ set tmp S-c set pcolor scale-color 87 tmp  1.5 0]
   if spatial_boundary = "Road"     [set tmp S-d set pcolor scale-color  57 tmp  1.5 0]
   if spatial_boundary = "Water"    [set tmp S-e set pcolor scale-color  108 tmp 1.5 0]
   if spatial_boundary = "Grid"     [set tmp S-f set pcolor scale-color  yellow tmp 1.5 0]
   if spatial_boundary = "Energydemand" [set tmp S-g set pcolor scale-color  125 tmp 1.5 0]
   if spatial_boundary = "POP"      [set tmp S-h set pcolor scale-color  135 tmp 1.5 0]
   if spatial_boundary = "ECO"      [set tmp S-i set pcolor scale-color  75 tmp 1.5 0]
;;show SF data map==============================================================================================================================================================================================================
    if spatial_boundary = "S-NG"      [set tmp S-NG set pcolor scale-color BROWN tmp 1.5 0 ]
    if spatial_boundary = "S-Nuclear" [ set tmp S-Nuclear set pcolor scale-color VIOLET tmp 1.5 0]
    if spatial_boundary = "S-wind"    [ set tmp S-wind set pcolor scale-color SKY tmp 1.5 0]
    if spatial_boundary = "S-PV"      [ set tmp S-PV set pcolor scale-color ORANGE tmp 1.5 0]
    if spatial_boundary = "S-Hydro"   [ set tmp S-Hydro set pcolor scale-color BLUE tmp 1.5 0]
    if spatial_boundary = "S-Biomass" [ set tmp S-Biomass set pcolor scale-color green tmp 1.5 0]
    if spatial_boundary = "S-WTE"     [ set tmp S-WTE set pcolor scale-color 40 tmp 1.5 0]
  ]
end

to export-map
  ask DM[
   if spatial_boundary = "NG"       [ export-view "NG.tif"  ]
   if spatial_boundary = "Nuclear"  [ export-view "Nuclear.tif" ]
   if spatial_boundary = "Wind"     [ export-view "Wind.tif"]
   if spatial_boundary = "PV"       [ export-view "PV.tif"]
   if spatial_boundary = "Hydro"    [ export-view "Hydro.tif"]
   if spatial_boundary = "Biomass"  [ export-view "Biomass.tif"]
   if spatial_boundary = "WTE"      [ export-view "WtE.tif"]
   if spatial_boundary = "Elevation"[ export-view "Elevation.tif"]
   if spatial_boundary = "Slop"     [ export-view "Slop.tif"]
   if spatial_boundary = "Road"     [ export-view "Road.tif"]
   if spatial_boundary = "Water"    [ export-view "Water.tif"]
   if spatial_boundary = "Grid"     [ export-view "Grid.tif"]
   if spatial_boundary = "Energydemand" [export-view "Energydemand.tif"]
   if spatial_boundary = "POP"      [export-view "POP.tif"]
   if spatial_boundary = "ECO"      [export-view "ECO.tif"]

    if spatial_boundary = "S-NG"      [export-view "S-NG.tif"]
    if spatial_boundary = "S-Nuclear" [export-view "S-Nuclear.tif"]
    if spatial_boundary = "S-wind"    [export-view "S-Wind.tif"]
    if spatial_boundary = "S-PV"      [export-view "S-Solar.tif"]
    if spatial_boundary = "S-Hydro"   [export-view "S-Hydro.tif"]
    if spatial_boundary = "S-Biomass" [export-view "S-Biomass.tif"]
    if spatial_boundary = "S-WTE"     [export-view "S-WtE.tif"]

  ]
end
;;in setup stage, shows the initial priority and spatial factors^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
to setup

  clear-all-plots
  clear-turtles
  ask DM [set pcolor black]

  ;;creat a colock
  create-spinners 1
  [ set shape "clock"
    setxy (max-pxcor - 8) (max-pycor - 8)
    set color blue
    set size 9
    set heading 0
    set label 2020
    set label-color black ]

  ;; define variables*************************************************************************************************************************************************************************************************
  ;; define 2 list 1,tech 2,actor
  set tech-type-list    n-values 7             [ ?1 -> ?1 ]
  set Actor-type-list   n-values Actor-types   [ ?1 -> ?1 ]
   ;; define actors' average priority of each tech                 Actors' variable========================================== total average priority of whole region  (one number for one actors' one tech)==============================================================================================
  set MX-NG              n-values Actor-types   [0]
  set MX-Nuclear         n-values Actor-types   [0]
  set MX-wind            n-values Actor-types   [0]
  set MX-PV              n-values Actor-types   [0]
  set MX-Hydro           n-values Actor-types   [0]
  set MX-Biomass         n-values Actor-types   [0]
  set MX-WTE             n-values Actor-types   [0]
  set MX-Nash            n-values 7             [0]

  set P-NG              n-values Actor-types   [0]
  set P-Nuclear         n-values Actor-types   [0]
  set P-wind            n-values Actor-types   [0]
  set P-PV              n-values Actor-types   [0]
  set P-Hydro           n-values Actor-types   [0]
  set P-Biomass         n-values Actor-types   [0]
  set P-WTE             n-values Actor-types   [0]
  SET P-total-tech      n-values Actor-types   [0]
  ;; define initial input actors' average priority of each tech   Actors' variable===========================================total initial average priority of whole region  (one number for one actors' one tech)==================================================================================================
  set P-NG-initial      n-values Actor-types   [0]
  set P-Nuclear-initial n-values Actor-types   [0]
  set P-wind-initial    n-values Actor-types   [0]
  set P-PV-initial      n-values Actor-types   [0]
  set P-Hydro-initial   n-values Actor-types   [0]
  set P-Biomass-initial n-values Actor-types   [0]
  set P-WTE-initial     n-values Actor-types   [0]

  set P-NG-start      n-values Actor-types   [0]
  set P-Nuclear-start n-values Actor-types   [0]
  set P-wind-start    n-values Actor-types   [0]
  set P-PV-start      n-values Actor-types   [0]
  set P-Hydro-start   n-values Actor-types   [0]
  set P-Biomass-start n-values Actor-types   [0]
  set P-WTE-start     n-values Actor-types   [0]

  set P0-list [] set P1-list [] set P2-list [] set P3-list []

    ;; using sustainable indicators to evaluate the influences of decision (energy techonology)------------------------------------------- ----Criteria-----------------------------------------------------------------------------
  ;;define criteria-normalization data                            Techs'variables
  set C1-norm           n-values 7 [0]
  set C2-norm           n-values 7 [0]
  set C3-norm           n-values 7 [0]
  set C4-norm           n-values 7 [0]
  set C5-norm           n-values 7 [0]
  set C6-norm           n-values 7 [0]
  set C7-norm           n-values 7 [0]
  set C8-norm           n-values 7 [0]
  set C9-norm           n-values 7 [0]
  set C10-norm          n-values 7 [0]
  set C11-norm          n-values 7 [0]
  set C12-norm          n-values 7 [0]
  set C13-norm          n-values 7 [0]
  set C14-norm          n-values 7 [0]

  ;; using economic indicators to evaluate the influences of decision (energy techonology)------------------------------------------- ----price-----------------------------------------------------------------------------

  set price          n-values 7 [0]
  set price-tmp          n-values 7 [0]
  set initial-standard-price 0.40155
  set initial-price [0.4155 0.43 0.4153 0.4153 0.35 0.75 0.65]
  foreach tech-type-list
  [ ?1 ->
    set Price replace-item ?1 Price  item ?1 initial-price
  ]

  set Quan          n-values 7 [0]
  set Tar           n-values 7 [0]
  SET R             n-values 7 [0]
  set M-share-next  n-values 7 [0]
  set M-share-previous  n-values 7 [0]
  set M-share  [0.0636 0.0702 0.0224 0.0288 0.0201 0.0200 0.0028]
  set M-share-sum   sum M-share
   foreach tech-type-list
  [ ?1 ->
    set M-share replace-item ?1 M-share  (item ?1 M-share / M-share-sum)
  ]

  foreach tech-type-list
  [ ?1 ->
    set M-share-next replace-item ?1 M-share-next  (item ?1 M-share)
  ]

  set total-con 1520.750000000;;GW
  set total-pro 1226.797000000;;GW
  set gap (total-con - total-pro)
  SET con-rate 0.056
  set Tar n-values 7 [0]

  set num-ng-list      []
  set num-nuclear-list []
  set num-wind-list    []
  set num-pv-list      []
  set num-hydro-list   []
  set num-biomass-list []
  set num-wte-list     []

     ;; define patches-own variables (S, X, SI PSI) ----------------------------------------------------------------------Action value X, marinal value SI PSI--------------------------------------------------------------------------==================
  ask DM [
    ; define techs' values of each actors    X-tech = S-tech * WSM[W-actor * C-tech]     Actors' variable
  set Q-NG              n-values Actor-types   [0]
  set Q-nuclear         n-values Actor-types   [0]
  set Q-wind            n-values Actor-types   [0]
  set Q-PV              n-values Actor-types   [0]
  set Q-Hydro           n-values Actor-types   [0]
  set Q-Biomass         n-values Actor-types   [0]
  set Q-WTE             n-values Actor-types   [0]
  set Q-total           n-values Actor-types   [0]

  set X-NG              n-values Actor-types   [0]
  set X-nuclear         n-values Actor-types   [0]
  set X-wind            n-values Actor-types   [0]
  set X-PV              n-values Actor-types   [0]
  set X-Hydro           n-values Actor-types   [0]
  set X-Biomass         n-values Actor-types   [0]
  set X-WTE             n-values Actor-types   [0]
  set X-total           n-values Actor-types   [0]


  set  Nash-in          n-values 7  [0]
  set  Nash-pm          n-values 7  [0]
  set  Nash-pu          n-values 7  [0]
  set  Nash-total       n-values 7  [0]
    ; define techs' Marginal value of each actors SI-Actor-tech = SI-ACTOR-TECH /SI-ACTOR-TOAL   Actors' variable
  set SI-NG              n-values Actor-types   [0]
  set SI-nuclear         n-values Actor-types   [0]
  set SI-wind            n-values Actor-types   [0]
  set SI-PV              n-values Actor-types   [0]
  set SI-Hydro           n-values Actor-types   [0]
  set SI-Biomass         n-values Actor-types   [0]
  set SI-WTE             n-values Actor-types   [0]
  set PSI                n-values Actor-types   [0]
   ; define tempare sf of each tech                                                       Techs'variables
       ; define actor's average priority of each tech             Techs'variables=============================================transposition of P-tech-next matrix ===========================================================================================
  set P0                 n-values 7 [0]
  set P1                 n-values 7 [0]
  set P2                 n-values 7 [0]
  set P3                 n-values 7 [0]
  set P-game             n-values 7 [0]
  set P-negotiation      n-values 7 [0]
  set tmp                n-values 7 [0]
  set tmp-n              n-values 7 [0]

  set X0                 n-values 7 [0]
  set X1                 n-values 7 [0]
  set X2                 n-values 7 [0]
  set X3                 n-values 7 [0]
  ; define storing variable for Actors'priority of each tech      Privious     Actors'variable===============================Storing variable P-previous===========================================================================================
  set P-total                   n-values Actor-types   [0]
  set P-NG-previous-year        n-values Actor-types   [0]
  set P-Nuclear-previous-year   n-values Actor-types   [0]
  set P-wind-previous-year      n-values Actor-types   [0]
  set P-PV-previous-year        n-values Actor-types   [0]
  set P-Hydro-previous-year     n-values Actor-types   [0]
  set P-Biomass-previous-year   n-values Actor-types   [0]
  set P-WTE-previous-year       n-values Actor-types   [0]

  ]

  ; weighting initial data input  Actors' Weight of three catagoris criteria   Actor's variables=============================================Criteria weight============================================================================
           ; inv    PM   PV   NA
  set W-eco1 [0.5  0       0      "a"]
  set W-eco2 [0.5  0       0      "a"]
  set W-env1 [0    0.4392  0      "b"]
  set W-env2 [0    0     0.220418 "b"]
  set W-env3 [0    0     0.217338 "b"]
  set W-env4 [0    0     0.208322 "b"]
  set W-soc1 [0    0     0.213225 "c"]
  set W-soc2 [0    0     0.030128 "c"]
  set W-soc3 [0    0     0.110545 "c"]
  set W-tec1 [0    0.3286  0      "d"]
  set W-tec2 [0    0.2322  0      "d"]

  set total-weight (weighting-eco + Weighting-env + Weighting-soc + Weighting-tec)
  if (total-weight != 0)
  [
   set W-eco1 replace-item 3 W-eco1 (weighting-eco / total-weight / 2)
   set W-eco2 replace-item 3 W-eco2 (weighting-eco / total-weight / 2)
   set W-env1 replace-item 3 W-env1 (weighting-env / total-weight / 4)
   set W-env2 replace-item 3 W-env2 (weighting-env / total-weight / 4)
   set W-env3 replace-item 3 W-env3 (weighting-env / total-weight / 4)
   set W-env4 replace-item 3 W-env4 (weighting-env / total-weight / 4)
   set W-tec1 replace-item 3 W-tec1 (weighting-tec / total-weight / 2)
   set W-tec2 replace-item 3 W-tec2 (weighting-tec / total-weight / 2)
   set W-soc1 replace-item 3 W-soc1 (weighting-soc / total-weight / 3)
   set W-soc2 replace-item 3 W-soc2 (weighting-soc / total-weight / 3)
   set W-soc3 replace-item 3 W-soc3 (weighting-soc / total-weight / 3)
  ]
 ;;----------------------------------------------------------------------------------------------------------------------------priority------------------------------------------------------------------------------------------

  ask DM [
 ; define storing variable for Actors'priority of each tech      Next        Actors'variable================================Storing variable P-next, input P data====================================================================================================
    ;setup-priority       investor policymaker  PV
  set P-NG-next-year         [0.2218 0.1737 0.1063 "e"]
  set P-Nuclear-next-year    [0.1470 0.0960 0.0937 "f"]
  set P-wind-next-year       [0.1721 0.2395 0.2466 "g"]
  set P-PV-next-year         [0.2140 0.2476 0.2375 "h"]
  set P-Hydro-next-year      [0.1203 0.1680 0.2249 "i"]
  set P-Biomass-next-year    [0.0845 0.0446 0.0330 "j"]
  set P-WTE-next-year        [0.0404 0.0307 0.0580 "k"]
  set P-total                [  1     1      1      1 ]

  set  total-preferences-new-Actor ( NG + Nuclear + Wind + PV + Hydro + biomass + WTE)
  set  P-NG-next-year        replace-item 3 P-ng-next-year      (NG       / total-preferences-new-Actor )
  set  P-Nuclear-next-year   replace-item 3 P-Nuclear-next-year (Nuclear  / total-preferences-new-Actor )
  set  P-wind-next-year      replace-item 3 P-wind-next-year    (wind     / total-preferences-new-Actor )
  set  P-PV-next-year        replace-item 3 P-PV-next-year      (PV       / total-preferences-new-Actor )
  set  P-Hydro-next-year     replace-item 3 P-Hydro-next-year   (Hydro    / total-preferences-new-Actor )
  set  P-biomass-next-year   replace-item 3 P-biomass-next-year (biomass  / total-preferences-new-Actor )
  set  P-WtE-next-year       replace-item 3 P-WtE-next-year     (WtE      / total-preferences-new-Actor )
  ]
   ;;*************************************************************************************************************************************************initial counting ************************************************************************************************88

  ; Here below are the initial preference values of technologies per DM type before applying the spatial effect====================================1. counting P-initial ====================================================================================
  foreach Actor-type-list
  [ ?1 ->
  set P-NG-initial      replace-item ?1 P-NG-initial      ( sum [item ?1 P-NG-next-year]           of DM  / count (DM))
  set P-Nuclear-initial replace-item ?1 P-Nuclear-initial ( sum [item ?1 P-Nuclear-next-year]      of DM  / count (DM))
  set P-wind-initial    replace-item ?1 P-wind-initial    ( sum [item ?1 P-wind-next-year]         of DM  / count (DM))
  set P-PV-initial      replace-item ?1 P-PV-initial      ( sum [item ?1 P-PV-next-year]           of DM  / count (DM))
  set P-Hydro-initial   replace-item ?1 P-Hydro-initial   ( sum [item ?1 P-Hydro-next-year]        of DM  / count (DM))
  set P-Biomass-initial replace-item ?1 P-Biomass-initial ( sum [item ?1 P-Biomass-next-year]      of DM  / count (DM))
  set P-WTE-initial     replace-item ?1 P-WTE-initial     ( sum [item ?1 P-WTE-next-year]          of DM  / count (DM))
  ]

  ;;----------------------------------------------------------------------------------------------------------------------------Counting SF ----------------------------------------------------------------------------------------
  ask DM [
 ;============================================================================================================================================================== S-tech-norm =======================================================================================
    ifelse S-a-NG = 0        [set S-NG      0] [set S-NG      S-NG]
    ifelse S-a-Nuclear = 0   [set S-Nuclear 0] [set S-Nuclear S-Nuclear]
    ifelse S-a-wind = 0      [set S-wind    0] [set S-wind    S-wind]
    ifelse S-a-pv = 0        [set S-PV      0] [set S-PV      S-PV]
    ifelse S-a-Hydro = 0     [set S-Hydro   0] [set S-Hydro   S-Hydro]
    ifelse S-a-Biomass = 0   [set S-Biomass 0] [set S-Biomass S-Biomass]
    ifelse S-a-WTE = 0       [set S-WTE     0] [set S-WTE     S-WTE  ]
  ]
  ask DM[
    ;normalizing SF
  if ((sum [S-NG] of DM)       != 0)  [set S-NG-norm      (S-NG      / sum [S-NG]      of DM)]
  if ((sum [S-Nuclear] of DM)  != 0)  [set S-Nuclear-norm (S-Nuclear / sum [S-Nuclear] of DM)]
  if ((sum [S-wind] of DM)     != 0)  [set S-wind-norm    (S-wind    / sum [S-wind]    of DM)]
  if ((sum [S-PV] of DM)       != 0)  [set S-PV-norm      (S-PV      / sum [S-PV]      of DM)]
  if ((sum [S-Hydro] of DM)    != 0)  [set S-Hydro-norm   (S-Hydro   / sum [S-Hydro]   of DM)]
  if ((sum [S-Biomass] of DM)  != 0)  [set S-Biomass-norm (S-Biomass / sum [S-Biomass] of DM)]
  if ((sum [S-WTE] of DM)      != 0)  [set S-WTE-norm     (S-WTE     / sum [S-WTE]     of DM)]
  ]

  foreach Actor-type-list [?1 ->
  ask DM [;initial priority========================================================================================================================2. Counting first P-next = P-next * SF-tech-norm ===========================================================================
;====================================================================================================================================================================P-next-norm =======================================================================================
  set P-NG-next-year       replace-item ?1 P-NG-next-year        (item ?1 P-NG-next-year      * S-NG-norm      )
  set P-Nuclear-next-year  replace-item ?1 P-Nuclear-next-year   (item ?1 P-Nuclear-next-year * S-Nuclear-norm )
  set P-wind-next-year     replace-item ?1 P-wind-next-year      (item ?1 P-wind-next-year    * S-wind-norm    )
  set P-PV-next-year       replace-item ?1 P-PV-next-year        (item ?1 P-PV-next-year      * S-PV-norm     )
  set P-Hydro-next-year    replace-item ?1 P-Hydro-next-year     (item ?1 P-Hydro-next-year   * S-Hydro-norm   )
  set P-Biomass-next-year  replace-item ?1 P-Biomass-next-year   (item ?1 P-Biomass-next-year * S-Biomass-norm )
  set P-WTE-next-year      replace-item ?1 P-WTE-next-year       (item ?1 P-WTE-next-year     * S-WTE-norm     )
  set P-total              replace-item ?1 P-total               (item ?1 P-wind-next-year + item ?1 P-NG-next-year + item ?1 P-Nuclear-next-year  + item ?1 P-PV-next-year + item ?1 P-Hydro-next-year + item ?1 P-Biomass-next-year + item ?1 P-WTE-next-year )

  ;normalization
  if ((item ?1 P-total) != 0)
  [
  set P-NG-next-year       replace-item ?1 P-NG-next-year        (item ?1 P-NG-next-year      / item ?1 P-total)
  set P-Nuclear-next-year  replace-item ?1 P-Nuclear-next-year   (item ?1 P-Nuclear-next-year / item ?1 P-total)
  set P-wind-next-year     replace-item ?1 P-wind-next-year      (item ?1 P-wind-next-year    / item ?1 P-total)
  set P-PV-next-year       replace-item ?1 P-PV-next-year        (item ?1 P-PV-next-year      / item ?1 P-total)
  set P-Hydro-next-year    replace-item ?1 P-Hydro-next-year     (item ?1 P-Hydro-next-year   / item ?1 P-total)
  set P-Biomass-next-year  replace-item ?1 P-Biomass-next-year   (item ?1 P-Biomass-next-year / item ?1 P-total)
  set P-WTE-next-year      replace-item ?1 P-WTE-next-year       (item ?1 P-WTE-next-year     / item ?1 P-total)
  set P-total              replace-item ?1 P-total               (item ?1 P-wind-next-year + item ?1 P-NG-next-year + item ?1 P-Nuclear-next-year  + item ?1 P-PV-next-year + item ?1 P-Hydro-next-year + item ?1 P-Biomass-next-year + item ?1 P-WTE-next-year )
  ]
  ]]

  foreach Actor-type-list
  [ ?1 ->
  set P-NG-start      replace-item ?1 P-NG-start        ( sum [item ?1 P-NG-next-year]           of DM  / count (DM))
  set P-Nuclear-start replace-item ?1 P-Nuclear-start   ( sum [item ?1 P-Nuclear-next-year]      of DM  / count (DM))
  set P-wind-start    replace-item ?1 P-wind-start      ( sum [item ?1 P-wind-next-year]         of DM  / count (DM))
  set P-PV-start      replace-item ?1 P-PV-start        ( sum [item ?1 P-PV-next-year]           of DM  / count (DM))
  set P-Hydro-start    replace-item ?1 P-Hydro-start    ( sum [item ?1 P-Hydro-next-year]        of DM  / count (DM))
  set P-Biomass-start  replace-item ?1 P-Biomass-start  ( sum [item ?1 P-Biomass-next-year]      of DM  / count (DM))
  set P-WTE-start      replace-item ?1 P-WTE-start      ( sum [item ?1 P-WTE-next-year]          of DM  / count (DM))
  ]
;;===============================================================================================================================================3. Counting average priority of each actor's each tech========================
   foreach Actor-type-list [?1 ->
  set P-NG         replace-item ?1 P-NG          (sum [item ?1 P-NG-next-year]      of DM     / count (DM)); WITH [s-NG != 0]))
  set P-Nuclear    replace-item ?1 P-Nuclear     (sum [item ?1 P-Nuclear-next-year] of DM     / count (DM));  WITH [s-NUCLEAR != 0] ))
  set P-wind       replace-item ?1 P-wind        (sum [item ?1 P-wind-next-year]    of DM     / count (DM));  WITH [s-WIND != 0]))
  set P-PV         replace-item ?1 P-PV          (sum [item ?1 P-PV-next-year]      of DM     / count (DM));  WITH [s-PV != 0]))
  set P-Hydro      replace-item ?1 P-Hydro       (sum [item ?1 P-Hydro-next-year]   of DM     / count (DM));  WITH [s-HYDRO != 0]))
  set P-Biomass    replace-item ?1 P-Biomass     (sum [item ?1 P-Biomass-next-year] of DM     / count (DM));  WITH [s-BIOMASS != 0]))
  set P-WTE        replace-item ?1 P-WTE         (sum [item ?1 P-WTE-next-year]     of DM     / count (DM));  WITH [s-WTE != 0]))
  set P-total-tech replace-item ?1 P-total-tech  (sum [item ?1 P-total]             of DM     / count (DM))
  ]

 ; set  GHG-emission [0.476	0.811	0.820	0.797	0.827	1.000	0.076]

;;===============================================================================================================================================5. transposition of P-tech-next ============================================

  foreach Actor-type-list [?1 ->
   ask DM[
   set S-ng-PC      (S-NG-norm      / SUM [S-NG-norm ] of DM)
   set S-nuclear-PC (S-Nuclear-norm / SUM [S-Nuclear-norm] of DM)
   set S-wind-PC    (S-wind-norm    / SUM [S-Wind-norm ] of DM)
   set S-PV-PC      (S-pv-norm     / SUM [S-pv-norm ] of DM)
   set S-hydro-PC   (S-hydro-norm   / SUM [S-hydro-norm ] of DM)
   set S-biomass-PC (S-biomass-norm / SUM [S-biomass-norm ] of DM)
   set S-wte-PC     (S-WTE-norm     / SUM [S-wte-norm ] of DM)
   ]]

          ;setup-Criteria  criteria input                                   Techs'variables
    ;     NG   Nuclear wind  PV   hydro biomass WTE
  set C1[0.12   0.3   0.42  0.36  0.30  0.48  0.84]; C1-LCOE
  set C2[0.475	0.330	0.540	0.158	0.900	0.253 0.303]; C2-energy efficiency
  set C3[527.083	36.994	22.705	57.709	13.900	-240.000 1112.250]; C3-CO2
  set C4[0.137	0.042	0.019	0.196	0.025	0.275 0.117]; C4-SO2
  set C5[0.777	0.063	0.042	0.138	0.016	0.652 1.041]; C5-NOx
  set C6[0.371	0.017	0.010	0.035	0.065	0.122 0.089]; C6-TPM
  set C7[0.383	0.033	0.040	0.137	0.027	0.760 0.644]; c7-HTP
  set C8[1.157	1.125	3.675	9.643	14.550	3.480 1.900]; C8-JC
  set C9[21.338	20.666	28.764	28.284	27.609	17.456 18.772]; C9-SA
  set C10[0.845	0.845	0.500	0.1	0.500	0.850 0.850]; C10-SC
  set C11[0.420	0.900	0.380	0.200	0.400	0.650 0.650]; C11-CF

  SELECT-SCENARIO
  show-result-maps

reset-ticks

end
;;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^;;go stage , the decision makers' priority changes according to the sustainable influences of its last decision

TO SELECT-SCENARIO
   if scenario-selection = "SSPs1"    [ SET Actor-type  "Negotiation"  set N-in 8 set N-PM 8 set N-PO 8 ]
   if scenario-selection = "SSPs2"    [ SET Actor-type  "Negotiation"  set N-in 8 set N-PM 6 set N-PO 4 ]
   if scenario-selection = "SSPs3"    [ SET Actor-type  "Negotiation"  set N-in 8 set N-PM 4 set N-PO 2 ]
   if scenario-selection = "SSPs5"    [ SET Actor-type  "Negotiation"  set N-in 8 set N-PM 4 set N-PO 8 ]
   if scenario-selection = "SSPs4"    [ SET Actor-type  "Negotiation"  set N-in 8 set N-PM 8 set N-PO 4 ]
END

to scenario

  if scenario-selection = "As usual" [
  ifelse  con-rate > 0.001  [set con-rate 0.056 * (1 - (round (ticks / 5)) * 0.2)] [set con-rate 0.001]
    if (ticks <= 5 )  [
     set C1 replace-item 0 C1  (item 0 C1 * (1 + ticks  * NG-price-increasing-rate-in-5yrs))
    ]
  if (ticks <= 10 )  [

                    set C1 replace-item 1 C1 (item 1 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 1 C4 (item 1 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 1 C5 (item 1 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 1 C6 (item 1 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 1 C10 (item 1 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 2 C1 (item 2 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 2 C4 (item 2 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 2 C5 (item 2 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 2 C6 (item 2 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 2 C10 (item 2 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 3 C1 (item 3 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 3 C4 (item 3 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 3 C5 (item 3 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 3 C6 (item 3 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 3 C10 (item 3 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 4 C1 (item 4 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 4 C4 (item 4 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 4 C5 (item 4 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 4 C6 (item 4 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 4 C10 (item 4 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 5 C1 (item 5 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 5 C4 (item 5 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 5 C5 (item 5 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 5 C6 (item 5 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 5 C10 (item 5 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 6 C1 (item 6 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 6 C4 (item 6 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 6 C5 (item 6 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 6 C6 (item 6 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 6 C10 (item 6 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    ]
  ]

  if scenario-selection = "SSPs1"    [
  ifelse  con-rate > 0.001  [ set con-rate 0.056 * (1 - ((1 / 100) * (ticks  * ticks)))] [set con-rate 0.001]
   if (ticks <= 5 )  [ set C1 replace-item 0 C1  (item 0 C1 * (1 + ticks  * ((random round 5) / 1000)))]
  if (ticks <= 10)   [

                   set C1 replace-item 1 C1  (item 1 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 1 C4 (item 1 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 1 C5 (item 1 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 1 C6 (item 1 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 1 C10 (item 1 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 2 C1  (item 2 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 2 C4 (item 2 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 2 C5 (item 2 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 2 C6 (item 2 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 2 C10 (item 2 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 3 C1  (item 3 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 3 C4 (item 3 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 3 C5 (item 3 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 3 C6 (item 3 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 3 C10 (item 3 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 4 C1  (item 4 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 4 C4 (item 4 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 4 C5 (item 4 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 4 C6 (item 4 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 4 C10 (item 4 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 5 C1  (item 5 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 5 C4 (item 5 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 5 C5 (item 5 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 5 C6 (item 5 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 5 C10 (item 5 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 6 C1  (item 6 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 6 C4 (item 6 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 6 C5 (item 6 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 6 C6 (item 6 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 6 C10 (item 6 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   ]
  ]

  if scenario-selection = "SSPs2"    [
   ifelse  con-rate > 0.001  [set con-rate 0.056 * (1 - ((1 / 625) * (ticks  * ticks)))]  [set con-rate 0.001]
   if (ticks <= 5 )  [ set C1 replace-item 0 C1  (item 0 C1 * (1 + ticks  * ((random round 5 + 5) / 1000))) ]
   if (ticks <= 10 )  [

                    set C1 replace-item 1 C1 (item 1 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 1 C4 (item 1 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 1 C5 (item 1 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 1 C6 (item 1 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 1 C10 (item 1 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 2 C1 (item 2 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 2 C4 (item 2 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 2 C5 (item 2 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 2 C6 (item 2 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 2 C10 (item 2 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 3 C1 (item 3 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 3 C4 (item 3 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 3 C5 (item 3 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 3 C6 (item 3 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 3 C10 (item 3 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 4 C1 (item 4 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 4 C4 (item 4 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 4 C5 (item 4 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 4 C6 (item 4 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 4 C10 (item 4 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 5 C1 (item 5 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 5 C4 (item 5 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 5 C5 (item 5 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 5 C6 (item 5 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 5 C10 (item 5 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                    set C1 replace-item 6 C1 (item 6 C1 * (1 - ticks  * ((random round 5 + 5) / 1000)))    set C4 replace-item 6 C4 (item 6 C4 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C5 replace-item 6 C5 (item 6 C5 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C6 replace-item 6 C6 (item 6 C6 * (1 - ticks  * ((random round 5 + 5) / 1000))) set C10 replace-item 6 C10 (item 6 C10 * (1 + ticks  * ((random round 5 + 5) / 1000)))
                   ]
  ]

   if scenario-selection = "SSPs3"    [
    ifelse  con-rate > 0.001  [set con-rate 0.056 * (1 - ((1 / 1600) * (ticks  * ticks)))] [set con-rate 0.001]
       if (ticks <= 5 )  [
  set C1 replace-item 0 C1  (item 0 C1 * (1 + ticks  * ((random round 5 + 10 ) / 1000)))
    ]
    if (ticks <= 10 )  [

                   set C1 replace-item 1 C1  (item 1 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 1 C4 (item 1 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 1 C5 (item 1 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 1 C6 (item 1 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 1 C10 (item 1 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 2 C1  (item 2 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 2 C4 (item 2 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 2 C5 (item 2 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 2 C6 (item 2 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 2 C10 (item 2 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 3 C1  (item 3 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 3 C4 (item 3 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 3 C5 (item 3 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 3 C6 (item 3 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 3 C10 (item 3 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 4 C1  (item 4 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 4 C4 (item 4 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 4 C5 (item 4 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 4 C6 (item 4 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 4 C10 (item 4 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 5 C1  (item 5 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 5 C4 (item 5 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 5 C5 (item 5 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 5 C6 (item 5 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 5 C10 (item 5 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 6 C1  (item 6 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 6 C4 (item 6 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 6 C5 (item 6 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 6 C6 (item 6 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 6 C10 (item 6 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   ]
  ]

  if scenario-selection = "SSPs5"    [
  ifelse  con-rate > 0.001  [set con-rate 0.056 * (1 - ((1 / 1600) * (ticks  * ticks)))]  [set con-rate 0.001]
    if (ticks <= 5 )  [
  set C1 replace-item 0 C1  (item 0 C1 * (1 + ticks  * ((random round 5 + 10 ) / 1000)))
    ]
   if (ticks <= 10 )  [

                   set C1 replace-item 1 C1  (item 1 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 1 C4 (item 1 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 1 C5 (item 1 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 1 C6 (item 1 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 1 C10 (item 1 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 2 C1  (item 2 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 2 C4 (item 2 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 2 C5 (item 2 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 2 C6 (item 2 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 2 C10 (item 2 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 3 C1  (item 3 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 3 C4 (item 3 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 3 C5 (item 3 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 3 C6 (item 3 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 3 C10 (item 3 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 4 C1  (item 4 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 4 C4 (item 4 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 4 C5 (item 4 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 4 C6 (item 4 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 4 C10 (item 4 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 5 C1  (item 5 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 5 C4 (item 5 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 5 C5 (item 5 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 5 C6 (item 5 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 5 C10 (item 5 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                   set C1 replace-item 6 C1  (item 6 C1 * (1 - ticks  * ((random round 5 ) / 1000)))    set C4 replace-item 6 C4 (item 6 C4 * (1 - ticks  * ((random round 5 ) / 1000))) set C5 replace-item 6 C5 (item 6 C5 * (1 - ticks  * ((random round 5 ) / 1000))) set C6 replace-item 6 C6 (item 6 C6 * (1 - ticks  * ((random round 5 ) / 1000))) set C10 replace-item 6 C10 (item 6 C10 * (1 + ticks  * ((random round 5 ) / 1000)))
                    ]
  ]

  if scenario-selection = "SSPs4"    [
  ifelse  con-rate > 0.001  [set con-rate 0.056 * (1 - ((1 / 1600) * (ticks  * ticks)))]  [set con-rate 0.001]
    if (ticks <= 5 )  [
    set C1 replace-item 0 C1  (item 0 C1 * (1 + ticks  * ((random round 5 + 5) / 1000)))
    ]
   if (ticks <= 10)   [

                   set C1 replace-item 1 C1  (item 1 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 1 C4 (item 1 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 1 C5 (item 1 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 1 C6 (item 1 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 1 C10 (item 1 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 2 C1  (item 2 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 2 C4 (item 2 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 2 C5 (item 2 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 2 C6 (item 2 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 2 C10 (item 2 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 3 C1  (item 3 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 3 C4 (item 3 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 3 C5 (item 3 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 3 C6 (item 3 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 3 C10 (item 3 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 4 C1  (item 4 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 4 C4 (item 4 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 4 C5 (item 4 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 4 C6 (item 4 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 4 C10 (item 4 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 5 C1  (item 5 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 5 C4 (item 5 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 5 C5 (item 5 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 5 C6 (item 5 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 5 C10 (item 5 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   set C1 replace-item 6 C1  (item 6 C1 * (1 - ticks  * ((random round 5 + 10) / 1000)))    set C4 replace-item 6 C4 (item 6 C4 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C5 replace-item 6 C5 (item 6 C5 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C6 replace-item 6 C6 (item 6 C6 * (1 - ticks  * ((random round 5 + 10) / 1000))) set C10 replace-item 6 C10 (item 6 C10 * (1 + ticks  * ((random round 5 + 10) / 1000)))
                   ]
  ]


end

to go

  if ticks >= 40 [stop]

  tick

  scenario

  ;=========Q=====================================================================================================================================================================================
  set total-con (total-con * (1 + con-rate))
  set gap (total-con - total-pro)

  set Tar replace-item  0 Tar (gap * item 0 P-NG)
  set Tar replace-item  1 Tar (gap * item 0 P-Nuclear)
  set Tar replace-item  2 Tar (gap * item 0 P-Wind)
  set Tar replace-item  3 Tar (gap * item 0 P-PV)
  set Tar replace-item  4 Tar (gap * item 0 P-Hydro)
  set Tar replace-item  5 Tar (gap * item 0 P-Biomass)
  set Tar replace-item  6 Tar (gap * item 0 P-WTE)

  foreach Actor-type-list [?1 ->
   ask DM[
   set Q-NG      replace-item  ?1 Q-NG       (ITEM 0 Tar * S-NG-PC      )
   set Q-Nuclear replace-item  ?1 Q-Nuclear  (ITEM 1 Tar * S-Nuclear-PC )
   set Q-Wind    replace-item  ?1 Q-wind     (ITEM 2 Tar * S-wind-PC    )
   set Q-PV      replace-item  ?1 Q-PV       (ITEM 3 Tar * S-pv-PC      )
   set Q-Hydro   replace-item  ?1 Q-Hydro    (ITEM 4 Tar * S-hydro-PC   )
   set Q-Biomass replace-item  ?1 Q-Biomass  (ITEM 5 Tar * S-biomass-PC )
   set Q-WTE     replace-item  ?1 Q-WTE      (ITEM 6 Tar * S-WTE-PC     )

   set Q-total   replace-item  ?1 Q-total    (item ?1 Q-wind + item ?1 Q-NG + item ?1 Q-Nuclear + item ?1 Q-PV + item ?1 Q-Hydro + item ?1 Q-Biomass + item ?1 Q-WTE)
   ]]

   set Quan replace-item 0 Quan (sum [item 0 Q-NG] of DM)
   set Quan replace-item 1 Quan (sum [item 0 Q-Nuclear] of DM)
   set Quan replace-item 2 Quan (sum [item 0 Q-wind] of DM)
   set Quan replace-item 3 Quan (sum [item 0 Q-PV] of DM)
   set Quan replace-item 4 Quan (sum [item 0 Q-Hydro]  of DM)
   set Quan replace-item 5 Quan (sum [item 0 Q-Biomass] of DM)
   set Quan replace-item 6 Quan (sum [item 0 Q-WTE] of DM)

  ;===============================================================================================================================================================================================

    ; criteria-normalization
  foreach tech-type-list [ ?1 ->
   set C1-norm  replace-item ?1 C1-norm  (((max C1  + (0.1 * max C1))  - item ?1 C1)  / ((max C1  + (0.1 * max C1))  - min C1) )
   set C2-norm  replace-item ?1 C2-norm  ((item ?1 C2  - (min C2  - (0.1 * min C2)))  / (max C2  - (min C2  - (0.1 * min C2))) )
   set C3-norm  replace-item ?1 C3-norm  (((max C3  + (0.1 * max C3))  - item ?1 C3)  / ((max C3  + (0.1 * max C3))  - min C3) )
   set C4-norm  replace-item ?1 C4-norm  (((max C4  + (0.1 * max C4))  - item ?1 C4)  / ((max C4  + (0.1 * max C4))  - min C4) )
   set C5-norm  replace-item ?1 C5-norm  (((max C5  + (0.1 * max C5))  - item ?1 C5)  / ((max C5  + (0.1 * max C5))  - min C5) )
   set C6-norm  replace-item ?1 C6-norm  (((max C6  + (0.1 * max C6))  - item ?1 C6)  / ((max C6  + (0.1 * max C6))  - min C6) )
   set C7-norm  replace-item ?1 C7-norm  (((max C7  + (0.1 * max C7))  - item ?1 C7)  / ((max C7  + (0.1 * max C7))  - min C7) )
   set C8-norm  replace-item ?1 C8-norm  ((item ?1 C8  - (min C8  - (0.1 * min C8)))  / (max C8  - (min C8  - (0.1 * min C8))) )
   set C9-norm  replace-item ?1 C9-norm  ((item ?1 C9  - (min C9  - (0.1 * min C9)))  / (max C9  - (min C9  - (0.1 * min C9))) )
   set C10-norm  replace-item ?1 C10-norm  ((item ?1 C10  - (min C10  - (0.1 * min C10)))  / (max C10  - (min C10  - (0.1 * min C10))) )
   set C11-norm  replace-item ?1 C11-norm  ((item ?1 C11  - (min C11  - (0.1 * min C11)))  / (max C11  - (min C11  - (0.1 * min C11))) )
   ]


    ask DM[
    set R      replace-item  0 R      ((item 0 Price - ITEM 0 C1) * 1000000000 * item 0 Q-NG )                                ;if item  0 R < 0  [set R replace-item  0 R 0];+ (36.755 * 12 * 300 * 1000)
    set R      replace-item  1 R      ((item 1 Price - ITEM 1 C1) * 1000000000 * item 0 Q-Nuclear)                           ;if item  1 R < 1  [set R replace-item  0 R 0]
    set R      replace-item  2 R      ((item 2 Price - ITEM 2 C1) * 1000000000 * item 0 Q-wind)                              ;if item  2 R < 2  [set R replace-item  0 R 0]
    set R      replace-item  3 R      ((item 3 Price - ITEM 3 C1) * 1000000000 * item 0 Q-PV)                                ;if item  3 R < 3  [set R replace-item  0 R 0]
    set R      replace-item  4 R      ((item 4 Price - ITEM 4 C1) * 1000000000 * item 0 Q-Hydro)                             ;if item  4 R < 4  [set R replace-item  0 R 0]; + (58 * 12 * 1400 * 1000)
    set R      replace-item  5 R      ((item 5 Price - ITEM 5 C1) * 1000000000 * item 0 Q-Biomass)                           ;if item  5 R < 5  [set R replace-item  0 R 0]
    set R      replace-item  6 R      ((item 6 Price - ITEM 6 C1 + 0.25 + 0.1) * 1000000000 * item 0 Q-WTE)                  ;if item  6 R < 6  [set R replace-item  0 R 0]

   ]

  ask DM[
    set X-NG      replace-item  0 X-NG       (S-NG *      ((max R + (0.1 * max R))  - item 0 R)  / ((max R  + (0.1 * max R))  - min R))
    set X-Nuclear replace-item  0 X-Nuclear  (S-Nuclear * ((max R + (0.1 * max R))  - item 1 R)  / ((max R  + (0.1 * max R))  - min R))
    set X-Wind    replace-item  0 X-wind     (S-wind *    ((max R + (0.1 * max R))  - item 2 R)  / ((max R  + (0.1 * max R))  - min R))
    set X-PV      replace-item  0 X-PV       (S-PV *      ((max R + (0.1 * max R))  - item 3 R)  / ((max R  + (0.1 * max R))  - min R))
    set X-Hydro   replace-item  0 X-Hydro    (S-Hydro *   ((max R + (0.1 * max R))  - item 4 R)  / ((max R  + (0.1 * max R))  - min R))
    set X-Biomass replace-item  0 X-Biomass  (S-Biomass * ((max R + (0.1 * max R))  - item 5 R)  / ((max R  + (0.1 * max R))  - min R))
    set X-WTE     replace-item  0 X-WTE      (S-WTE *     ((max R + (0.1 * max R))  - item 6 R)  / ((max R  + (0.1 * max R))  - min R))

   set X-total   replace-item  0 X-total    (item 0 X-wind + item 0 X-NG + item 0 X-Nuclear + item 0 X-PV + item 0 X-Hydro + item 0 X-Biomass + item 0 X-WTE)

  ]

   ask DM[
   set X-NG      replace-item  1 X-NG       (S-NG *      ((item 1 W-env1 * item 0 C3-norm) + (item 1 W-tec1 * item 0 C10-norm) + (item 1 W-tec2 * item 0 C11-norm) ))
   set X-Nuclear replace-item  1 X-Nuclear  (S-Nuclear * ((item 1 W-env1 * item 1 C3-norm) + (item 1 W-tec1 * item 1 C10-norm) + (item 1 W-tec2 * item 1 C11-norm) ))
   set X-wind    replace-item  1 X-wind     (S-wind *    ((item 1 W-env1 * item 2 C3-norm) + (item 1 W-tec1 * item 2 C10-norm) + (item 1 W-tec2 * item 2 C11-norm) ))
   set X-PV      replace-item  1 X-PV       (S-PV *      ((item 1 W-env1 * item 3 C3-norm) + (item 1 W-tec1 * item 3 C10-norm) + (item 1 W-tec2 * item 3 C11-norm) ))
   set X-Hydro   replace-item  1 X-Hydro    (S-Hydro *   ((item 1 W-env1 * item 4 C3-norm) + (item 1 W-tec1 * item 4 C10-norm) + (item 1 W-tec2 * item 4 C11-norm) ))
   set X-Biomass replace-item  1 X-Biomass  (S-Biomass * ((item 1 W-env1 * item 5 C3-norm) + (item 1 W-tec1 * item 5 C10-norm) + (item 1 W-tec2 * item 5 C11-norm) ))
   set X-WTE     replace-item  1 X-WTE      (S-WTE *     ((item 1 W-env1 * item 6 C3-norm) + (item 1 W-tec1 * item 6 C10-norm) + (item 1 W-tec2 * item 6 C11-norm) ))
   set X-total   replace-item  1 X-total    (item 1 X-wind + item 1 X-NG + item 1 X-Nuclear + item 1 X-PV + item 1 X-Hydro + item 1 X-Biomass + item 1 X-WTE)
  ]

   ask DM[
   set X-NG      replace-item  2 X-NG        (S-NG *      (((item 2 W-env2) * item 0 C4-norm) + ((item 2 W-env3) * item 0 C5-norm) + ((item 2 W-env4) * item 0 C6-norm) + ((item 2 W-soc1) * item 0 C7-norm) + ((item 2 W-soc2) * item 0 C8-norm) + ((item 2 W-soc3) * item 0 C9-norm)))
   set X-Nuclear replace-item  2 X-Nuclear   (S-Nuclear * (((item 2 W-env2) * item 1 C4-norm) + ((item 2 W-env3) * item 1 C5-norm) + ((item 2 W-env4) * item 1 C6-norm) + ((item 2 W-soc1) * item 1 C7-norm) + ((item 2 W-soc2) * item 1 C8-norm) + ((item 2 W-soc3) * item 1 C9-norm)))
   set X-wind    replace-item  2 X-wind      (S-wind *    (((item 2 W-env2) * item 2 C4-norm) + ((item 2 W-env3) * item 2 C5-norm) + ((item 2 W-env4) * item 2 C6-norm) + ((item 2 W-soc1) * item 2 C7-norm) + ((item 2 W-soc2) * item 2 C8-norm) + ((item 2 W-soc3) * item 2 C9-norm)))
   set X-PV      replace-item  2 X-PV        (S-PV *      (((item 2 W-env2) * item 3 C4-norm) + ((item 2 W-env3) * item 3 C5-norm) + ((item 2 W-env4) * item 3 C6-norm) + ((item 2 W-soc1) * item 3 C7-norm) + ((item 2 W-soc2) * item 3 C8-norm) + ((item 2 W-soc3) * item 3 C9-norm)))
   set X-Hydro   replace-item  2 X-Hydro     (S-Hydro *   (((item 2 W-env2) * item 4 C4-norm) + ((item 2 W-env3) * item 4 C5-norm) + ((item 2 W-env4) * item 4 C6-norm) + ((item 2 W-soc1) * item 4 C7-norm) + ((item 2 W-soc2) * item 4 C8-norm) + ((item 2 W-soc3) * item 4 C9-norm)))
   set X-Biomass replace-item  2 X-Biomass   (S-Biomass * (((item 2 W-env2) * item 5 C4-norm) + ((item 2 W-env3) * item 5 C5-norm) + ((item 2 W-env4) * item 5 C6-norm) + ((item 2 W-soc1) * item 5 C7-norm) + ((item 2 W-soc2) * item 5 C8-norm) + ((item 2 W-soc3) * item 5 C9-norm)))
   set X-WTE     replace-item  2 X-WTE       (S-WTE *     (((item 2 W-env2) * item 6 C4-norm) + ((item 2 W-env3) * item 6 C5-norm) + ((item 2 W-env4) * item 6 C6-norm) + ((item 2 W-soc1) * item 6 C7-norm) + ((item 2 W-soc2) * item 6 C8-norm) + ((item 2 W-soc3) * item 6 C9-norm)))
   set X-total   replace-item  2 X-total    (item 1 X-wind + item 1 X-NG + item 1 X-Nuclear + item 1 X-PV + item 1 X-Hydro + item 1 X-Biomass + item 1 X-WTE)
  ]

  ask DM[
   set X-NG      replace-item 3 X-NG        (S-NG *      (((item 3 W-eco1) * item 0 C1-norm) + ((item 3 W-eco2) * item 0 C2-norm) + ((item 3 W-env1) * item 0 C3-norm) + ((item 3 W-env2) * item 0 C4-norm) + ((item 3 W-env3) * item 0 C5-norm) + ((item 3 W-env4) * item 0 C6-norm) + ((item 3 W-soc1) * item 0 C7-norm) + ((item 3 W-soc2) * item 0 C8-norm) + ((item 3 W-soc3) * item 0 C9-norm) + ((item 3 W-tec1) * item 0 C10-norm) + ((item 3 W-tec2) * item 0 C11-norm)))
   set X-Nuclear replace-item 3 X-Nuclear   (S-Nuclear * (((item 3 W-eco1) * item 1 C1-norm) + ((item 3 W-eco2) * item 1 C2-norm) + ((item 3 W-env1) * item 1 C3-norm) + ((item 3 W-env2) * item 1 C4-norm) + ((item 3 W-env3) * item 1 C5-norm) + ((item 3 W-env4) * item 1 C6-norm) + ((item 3 W-soc1) * item 1 C7-norm) + ((item 3 W-soc2) * item 1 C8-norm) + ((item 3 W-soc3) * item 1 C9-norm) + ((item 3 W-tec1) * item 1 C10-norm) + ((item 3 W-tec2) * item 1 C11-norm)))
   set X-wind    replace-item 3 X-wind      (S-wind *    (((item 3 W-eco1) * item 2 C1-norm) + ((item 3 W-eco2) * item 2 C2-norm) + ((item 3 W-env1) * item 2 C3-norm) + ((item 3 W-env2) * item 2 C4-norm) + ((item 3 W-env3) * item 2 C5-norm) + ((item 3 W-env4) * item 2 C6-norm) + ((item 3 W-soc1) * item 2 C7-norm) + ((item 3 W-soc2) * item 2 C8-norm) + ((item 3 W-soc3) * item 2 C9-norm) + ((item 3 W-tec1) * item 2 C10-norm) + ((item 3 W-tec2) * item 2 C11-norm)))
   set X-PV      replace-item 3 X-PV        (S-PV *      (((item 3 W-eco1) * item 3 C1-norm) + ((item 3 W-eco2) * item 3 C2-norm) + ((item 3 W-env1) * item 3 C3-norm) + ((item 3 W-env2) * item 3 C4-norm) + ((item 3 W-env3) * item 3 C5-norm) + ((item 3 W-env4) * item 3 C6-norm) + ((item 3 W-soc1) * item 3 C7-norm) + ((item 3 W-soc2) * item 3 C8-norm) + ((item 3 W-soc3) * item 3 C9-norm) + ((item 3 W-tec1) * item 3 C10-norm) + ((item 3 W-tec2) * item 3 C11-norm)))
   set X-Hydro   replace-item 3 X-Hydro     (S-Hydro *   (((item 3 W-eco1) * item 4 C1-norm) + ((item 3 W-eco2) * item 4 C2-norm) + ((item 3 W-env1) * item 4 C3-norm) + ((item 3 W-env2) * item 4 C4-norm) + ((item 3 W-env3) * item 4 C5-norm) + ((item 3 W-env4) * item 4 C6-norm) + ((item 3 W-soc1) * item 4 C7-norm) + ((item 3 W-soc2) * item 4 C8-norm) + ((item 3 W-soc3) * item 4 C9-norm) + ((item 3 W-tec1) * item 4 C10-norm) + ((item 3 W-tec2) * item 4 C11-norm)))
   set X-Biomass replace-item 3 X-Biomass   (S-Biomass * (((item 3 W-eco1) * item 5 C1-norm) + ((item 3 W-eco2) * item 5 C2-norm) + ((item 3 W-env1) * item 5 C3-norm) + ((item 3 W-env2) * item 5 C4-norm) + ((item 3 W-env3) * item 5 C5-norm) + ((item 3 W-env4) * item 5 C6-norm) + ((item 3 W-soc1) * item 5 C7-norm) + ((item 3 W-soc2) * item 5 C8-norm) + ((item 3 W-soc3) * item 5 C9-norm) + ((item 3 W-tec1) * item 5 C10-norm) + ((item 3 W-tec2) * item 5 C11-norm)))
   set X-WTE     replace-item 3 X-WTE       (S-WTE *     (((item 3 W-eco1) * item 6 C1-norm) + ((item 3 W-eco2) * item 6 C2-norm) + ((item 3 W-env1) * item 6 C3-norm) + ((item 3 W-env2) * item 6 C4-norm) + ((item 3 W-env3) * item 6 C5-norm) + ((item 3 W-env4) * item 6 C6-norm) + ((item 3 W-soc1) * item 6 C7-norm) + ((item 3 W-soc2) * item 6 C8-norm) + ((item 3 W-soc3) * item 6 C9-norm) + ((item 3 W-tec1) * item 6 C10-norm) + ((item 3 W-tec2) * item 6 C11-norm)))
   set X-total   replace-item 3 X-total    (item 3 X-wind + item 3 X-NG + item 3 X-Nuclear + item 3 X-PV + item 3 X-Hydro + item 3 X-Biomass + item 3 X-WTE)
  ]

   foreach Actor-type-list [?1 ->
   ask DM[
   if ((item ?1 X-total) != 0)
      [
    ;; marginal value
   set SI-NG      replace-item ?1 SI-NG      (item ?1 X-NG      / item ?1 X-total)
   set SI-Nuclear replace-item ?1 SI-Nuclear (item ?1 X-Nuclear / item ?1 X-total)
   set SI-wind    replace-item ?1 SI-wind    (item ?1 X-wind    / item ?1 X-total)
   set SI-PV      replace-item ?1 SI-PV      (item ?1 X-PV      / item ?1 X-total)
   set SI-Hydro   replace-item ?1 SI-Hydro   (item ?1 X-Hydro   / item ?1 X-total)
   set SI-Biomass replace-item ?1 SI-Biomass (item ?1 X-Biomass / item ?1 X-total)
   set SI-WTE     replace-item ?1 SI-WTE     (item ?1 X-WTE     / item ?1 X-total)
      ]

    ;; define new priority P(t+1)
   set P-NG-previous-year       replace-item ?1  P-NG-previous-year       (item ?1 P-NG-next-year)
   set P-Nuclear-previous-year  replace-item ?1  P-Nuclear-previous-year  (item ?1 P-Nuclear-next-year)
   set P-wind-previous-year     replace-item ?1  P-wind-previous-year     (item ?1 P-wind-next-year)
   set P-PV-previous-year       replace-item ?1  P-PV-previous-year       (item ?1 P-PV-next-year)
   set P-Hydro-previous-year    replace-item ?1  P-Hydro-previous-year    (item ?1 P-Hydro-next-year)
   set P-Biomass-previous-year  replace-item ?1  P-Biomass-previous-year  (item ?1 P-Biomass-next-year)
   set P-WTE-previous-year      replace-item ?1  P-WTE-previous-year      (item ?1 P-WTE-next-year)

   set PSI replace-item ?1 PSI (((item ?1 P-NG-previous-year * item ?1 SI-NG) + (item ?1 P-Nuclear-previous-year * item ?1 SI-Nuclear) + (item ?1 P-wind-previous-year * item ?1 SI-wind )
                               + (item ?1 P-PV-previous-year * item ?1 SI-PV ) + (item ?1 P-Hydro-previous-year * item ?1 SI-Hydro ) + (item ?1 P-Biomass-previous-year * item ?1 SI-Biomass)
                               + (item ?1 P-WTE-previous-year * item ?1 SI-WTE)))

   set P-NG-next-year      replace-item ?1 P-NG-next-year           (item ?1 P-NG-previous-year        + alpha * (item ?1 P-NG-previous-year        * (item ?1 SI-NG - item ?1 PSI)))
   set P-Nuclear-next-year replace-item ?1 P-Nuclear-next-year      (item ?1 P-Nuclear-previous-year   + alpha * (item ?1 P-Nuclear-previous-year   * (item ?1 SI-Nuclear - item ?1 PSI)))
   set P-wind-next-year    replace-item ?1 P-wind-next-year         (item ?1 P-wind-previous-year      + alpha * (item ?1 P-wind-previous-year      * (item ?1 SI-wind - item ?1 PSI)))
   set P-PV-next-year      replace-item ?1 P-PV-next-year           (item ?1 P-PV-previous-year        + alpha * (item ?1 P-PV-previous-year        * (item ?1 SI-PV - item ?1 PSI)))
   set P-Hydro-next-year   replace-item ?1 P-Hydro-next-year        (item ?1 P-Hydro-previous-year     + alpha * (item ?1 P-Hydro-previous-year     * (item ?1 SI-Hydro - item ?1 PSI)))
   set P-Biomass-next-year replace-item ?1 P-Biomass-next-year      (item ?1 P-Biomass-previous-year   + alpha * (item ?1 P-Biomass-previous-year   * (item ?1 SI-Biomass - item ?1 PSI)))
   set P-WTE-next-year     replace-item ?1 P-WTE-next-year          (item ?1 P-WTE-previous-year       + alpha * (item ?1 P-WTE-previous-year       * (item ?1 SI-WTE - item ?1 PSI)))
   set P-total             replace-item ?1 P-total                  (item ?1 P-wind-next-year + item ?1 P-NG-next-year + item ?1 P-Nuclear-next-year + item ?1  P-PV-next-year + item ?1 P-Hydro-next-year + item ?1 P-Biomass-next-year + item ?1 P-WTE-next-year)
   ]]

  ;=========price=====================================================================================================================================================================================

  foreach tech-type-list [ ?1 ->
    set M-share-previous replace-item ?1 M-share-previous (item ?1 M-share-next)
  ]
  foreach tech-type-list [ ?1 ->
    set M-share-next replace-item ?1 M-share-next (item ?1 Quan / gap)
  ]

  foreach tech-type-list [ ?1 -> set  price replace-item ?1 price (item ?1 price * (1 -  (item ?1 M-share-next - item ?1 M-share-previous)))]
  if Market-free? = 0
  [  foreach tech-type-list [ ?1 ->

     if (item ?1 price > 1.2 * initial-standard-price) [set price replace-item ?1 price (1.2 * initial-standard-price)]
     if (item ?1 price < 0.85 * initial-standard-price) [set price replace-item ?1 price (0.85 * initial-standard-price)]
  ]]
  ;==============================================================================================================================================================================================
   show-result-maps
  ;;=============================================================================================================================================================================================

  foreach Actor-type-list [?1 ->
  set P-NG         replace-item ?1 P-NG          (sum [item ?1 P-NG-next-year]      of DM     / count (DM))
  set P-Nuclear    replace-item ?1 P-Nuclear     (sum [item ?1 P-Nuclear-next-year] of DM     / count (DM))
  set P-wind       replace-item ?1 P-wind        (sum [item ?1 P-wind-next-year]    of DM     / count (DM))
  set P-PV         replace-item ?1 P-PV          (sum [item ?1 P-PV-next-year]      of DM     / count (DM))
  set P-Hydro      replace-item ?1 P-Hydro       (sum [item ?1 P-Hydro-next-year]   of DM     / count (DM))
  set P-Biomass    replace-item ?1 P-Biomass     (sum [item ?1 P-Biomass-next-year] of DM     / count (Dm))
  set P-WTE        replace-item ?1 P-WTE         (sum [item ?1 P-WTE-next-year]     of DM     / count (DM))
  set P-total-tech replace-item ?1 P-total-tech  (sum [item ?1 P-total]             of DM     / count (DM))

  set MX-NG         replace-item ?1 MX-NG          (sum [item ?1 X-NG]      of DM     / count (DM))
  set MX-Nuclear    replace-item ?1 MX-Nuclear     (sum [item ?1 X-Nuclear] of DM     / count (DM))
  set MX-wind       replace-item ?1 MX-wind        (sum [item ?1 X-wind]    of DM     / count (DM))
  set MX-PV         replace-item ?1 MX-PV          (sum [item ?1 X-PV]      of DM     / count (DM))
  set MX-Hydro      replace-item ?1 MX-Hydro       (sum [item ?1 X-Hydro]   of DM     / count (DM))
  set MX-Biomass    replace-item ?1 MX-Biomass     (sum [item ?1 X-Biomass] of DM     / count (DM))
  set MX-WTE        replace-item ?1 MX-WTE         (sum [item ?1 X-WTE]     of DM     / count (DM))
  ]

  foreach tech-type-list [?1 ->
  set MX-Nash       replace-item ?1 MX-Nash        (sum [item ?1 Nash-total]   of DM     / count (DM))
  ]

   if ticks mod 1 = 0 [
    set P0-list lput item 0 P-NG P0-list  set P0-list lput item 0 P-Nuclear P0-list  set P0-list lput item 0 P-wind P0-list   set P0-list lput item 0 P-PV P0-list  set P0-list lput item 0 P-Hydro P0-list  set P0-list lput item 0 P-Biomass P0-list  set P0-list lput item 0 P-WTE P0-list
    set P1-list lput item 1 P-NG P1-list  set P1-list lput item 1 P-Nuclear P1-list  set P1-list lput item 1 P-wind P1-list   set P1-list lput item 1 P-PV P1-list  set P1-list lput item 1 P-Hydro P1-list  set P1-list lput item 1 P-Biomass P1-list  set P1-list lput item 1 P-WTE P1-list
    set P2-list lput item 2 P-NG P2-list  set P2-list lput item 2 P-Nuclear P2-list  set P2-list lput item 2 P-wind P2-list   set P2-list lput item 2 P-PV P2-list  set P2-list lput item 2 P-Hydro P2-list  set P2-list lput item 2 P-Biomass P2-list  set P2-list lput item 2 P-WTE P2-list
    set P3-list lput item 3 P-NG P3-list  set P3-list lput item 3 P-Nuclear P3-list  set P3-list lput item 3 P-wind P3-list   set P3-list lput item 3 P-PV P3-list  set P3-list lput item 3 P-Hydro P3-list  set P3-list lput item 3 P-Biomass P3-list  set P3-list lput item 3 P-WTE P3-list
  ]
  ;;========================================================================================================================================================================================
  ask spinners
  [ set heading ticks * 72
    set label ticks + 2020
  ]

  export-tech

end

to export-data
  if ticks = 40
  [ export-world "fire.csv"
  ]
end

to run-sensitivity-analysis
   load-map
   setup
   repeat 40 [go]
END

to sensitivity-analysis
  if Scenario-selection = "As usual"
[
   repeat 2
  [
   run-sensitivity-analysis
   file-open "decision makers priority - as usual.csv"
   file-print csv:to-string (list P0-list P1-list P2-list P3-list)
  ]
  file-close-all
  ]

  if Scenario-selection = "SSPs1"
[
   repeat 2
  [
   run-sensitivity-analysis
   file-open "decision makers priority - SSPs1.csv"
   file-print csv:to-string (list P0-list P1-list P2-list P3-list)
  ]
  file-close-all
  ]

   if Scenario-selection = "SSPs2"
[
   repeat 2
  [
   run-sensitivity-analysis
   file-open "decision makers priority - SSPs3.csv"
   file-print csv:to-string (list P0-list P1-list P2-list P3-list)
  ]
  file-close-all
  ]

   if Scenario-selection = "SSPs5"
[
   repeat 2
  [
   run-sensitivity-analysis
   file-open "decision makers priority - SSPs5.csv"
   file-print csv:to-string (list P0-list P1-list P2-list P3-list)
  ]
  file-close-all
  ]


end

to export-tech

  set num-ng      count patches with [pcolor = brown]
  set num-nuclear count patches with [pcolor = violet]
  set num-wind    count patches with [pcolor = sky]
  set num-pv      count patches with [pcolor = orange]
  set num-hydro   count patches with [pcolor = blue]
  set num-biomass count patches with [pcolor = green]
  set num-wte     count patches with [pcolor = yellow]

  if ticks mod 1 = 0 [
  set  num-ng-list      lput num-ng      num-ng-list
  set  num-nuclear-list lput num-nuclear num-nuclear-list
  set  num-wind-list    lput num-wind    num-wind-list
  set  num-pv-list      lput num-pv      num-pv-list
  set  num-hydro-list   lput num-hydro   num-hydro-list
  set  num-biomass-list lput num-biomass num-biomass-list
  set  num-wte-list     lput num-wte     num-wte-list
  ]
end

to export-tech-file
  file-open "tech-percent.csv"
  file-print csv:to-string (list num-ng-list num-nuclear-list num-wind-list num-pv-list num-hydro-list num-biomass-list num-wte-list)
  file-close-all
end


to show-result-maps


   foreach tech-type-list [
    ?1 -> ask DM [
    set P0 replace-item 0 P0 ( item 0 P-NG-next-year)
    set P0 replace-item 1 P0 ( item 0 P-Nuclear-next-year)
    set P0 replace-item 2 P0 ( item 0 P-wind-next-year)
    set P0 replace-item 3 P0 ( item 0 P-PV-next-year)
    set P0 replace-item 4 P0 ( item 0 P-Hydro-next-year)
    set P0 replace-item 5 P0 ( item 0 P-Biomass-next-year)
    set P0 replace-item 6 P0 ( item 0 P-WTE-next-year)

    set P1 replace-item 0 P1 ( item 1 P-NG-next-year)
    set P1 replace-item 1 P1 ( item 1 P-Nuclear-next-year)
    set P1 replace-item 2 P1 ( item 1 P-wind-next-year)
    set P1 replace-item 3 P1 ( item 1 P-PV-next-year)
    set P1 replace-item 4 P1 ( item 1 P-Hydro-next-year)
    set P1 replace-item 5 P1 ( item 1 P-Biomass-next-year)
    set P1 replace-item 6 P1 ( item 1 P-WTE-next-year)

    set P2 replace-item 0 P2 ( item 2 P-NG-next-year)
    set P2 replace-item 1 P2 ( item 2 P-Nuclear-next-year)
    set P2 replace-item 2 P2 ( item 2 P-wind-next-year)
    set P2 replace-item 3 P2 ( item 2 P-PV-next-year)
    set P2 replace-item 4 P2 ( item 2 P-Hydro-next-year)
    set P2 replace-item 5 P2 ( item 2 P-Biomass-next-year)
    set P2 replace-item 6 P2 ( item 2 P-WTE-next-year)

    set P3 replace-item 0 P3 ( item 3 P-NG-next-year)
    set P3 replace-item 1 P3 ( item 3 P-Nuclear-next-year)
    set P3 replace-item 2 P3 ( item 3 P-wind-next-year)
    set P3 replace-item 3 P3 ( item 3 P-PV-next-year)
    set P3 replace-item 4 P3 ( item 3 P-Hydro-next-year)
    set P3 replace-item 5 P3 ( item 3 P-Biomass-next-year)
    set P3 replace-item 6 P3 ( item 3 P-WTE-next-year)

    set P-game replace-item 0 P-game ( max P-NG-next-year)
    set P-game replace-item 1 P-game ( max P-Nuclear-next-year)
    set P-game replace-item 2 P-game ( max P-wind-next-year)
    set P-game replace-item 3 P-game ( max P-PV-next-year)
    set P-game replace-item 4 P-game ( max P-Hydro-next-year)
    set P-game replace-item 5 P-game ( max P-Biomass-next-year)
    set P-game replace-item 6 P-game ( max P-WTE-next-year)

    set C-IN N-IN / (N-IN + N-PM + N-PO)
    set C-PM N-PM / (N-IN + N-PM + N-PO)
    set C-PO N-PO / (N-IN + N-PM + N-PO)

    set P-negotiation replace-item 0 P-negotiation ( item 0 P-NG-next-year      * C-IN + item 1 P-NG-next-year      * C-PM + item 2 P-NG-next-year      * C-PO)
    set P-negotiation replace-item 1 P-negotiation ( item 0 P-Nuclear-next-year * C-IN + item 1 P-Nuclear-next-year * C-PM + item 2 P-Nuclear-next-year * C-PO)
    set P-negotiation replace-item 2 P-negotiation ( item 0 P-Wind-next-year    * C-IN + item 1 P-Wind-next-year    * C-PM + item 2 P-Wind-next-year    * C-PO)
    set P-negotiation replace-item 3 P-negotiation ( item 0 P-PV-next-year      * C-IN + item 1 P-PV-next-year      * C-PM + item 2 P-PV-next-year      * C-PO)
    set P-negotiation replace-item 4 P-negotiation ( item 0 P-Hydro-next-year   * C-IN + item 1 P-Hydro-next-year   * C-PM + item 2 P-Hydro-next-year   * C-PO)
    set P-negotiation replace-item 5 P-negotiation ( item 0 P-Biomass-next-year * C-IN + item 1 P-Biomass-next-year * C-PM + item 2 P-Biomass-next-year * C-PO)
    set P-negotiation replace-item 6 P-negotiation ( item 0 P-WTE-next-year     * C-IN + item 1 P-WTE-next-year     * C-PM + item 2 P-WTE-next-year     * C-PO)

    set X0 replace-item 0 X0 ( item 0 X-NG)
    set X0 replace-item 1 X0 ( item 0 X-Nuclear)
    set X0 replace-item 2 X0 ( item 0 X-wind)
    set X0 replace-item 3 X0 ( item 0 X-PV)
    set X0 replace-item 4 X0 ( item 0 X-Hydro)
    set X0 replace-item 5 X0 ( item 0 X-Biomass)
    set X0 replace-item 6 X0 ( item 0 X-WTE)

    set X1 replace-item 0 X1 ( item 1 X-NG)
    set X1 replace-item 1 X1 ( item 1 X-Nuclear)
    set X1 replace-item 2 X1 ( item 1 X-wind)
    set X1 replace-item 3 X1 ( item 1 X-PV)
    set X1 replace-item 4 X1 ( item 1 X-Hydro)
    set X1 replace-item 5 X1 ( item 1 X-Biomass)
    set X1 replace-item 6 X1 ( item 1 X-WTE)

    set X2 replace-item 0 X2 ( item 2 X-NG)
    set X2 replace-item 1 X2 ( item 2 X-Nuclear)
    set X2 replace-item 2 X2 ( item 2 X-wind)
    set X2 replace-item 3 X2 ( item 2 X-PV)
    set X2 replace-item 4 X2 ( item 2 X-Hydro)
    set X2 replace-item 5 X2 ( item 2 X-Biomass)
    set X2 replace-item 6 X2 ( item 2 X-WTE)

    set X3 replace-item 0 X3 ( item 3 X-NG)
    set X3 replace-item 1 X3 ( item 3 X-Nuclear)
    set X3 replace-item 3 X3 ( item 3 X-wind)
    set X3 replace-item 3 X3 ( item 3 X-PV)
    set X3 replace-item 4 X3 ( item 3 X-Hydro)
    set X3 replace-item 5 X3 ( item 3 X-Biomass)
    set X3 replace-item 6 X3 ( item 3 X-WTE)
  ]]

    nashi-equ
;===============================================================================================================================================6. Find max priority for each tech ==============================================
  ;================================================================================================================================================= Find max priority relevant actor ==============================================

  foreach tech-type-list [
    ?1 -> ask DM [
  ;  if GHG?     [ set tech  "NAN"]
    if players? [ set tech  "NAN" set Actor-type  "Game"]

    if Actor-type = "Investor"        [set tmp replace-item ?1 tmp ( item ?1 P0) ]
    if Actor-type = "Policy maker"    [set tmp replace-item ?1 tmp ( item ?1 P1) ]
    if Actor-type = "Public overseer" [set tmp replace-item ?1 tmp ( item ?1 P2) ]
    if Actor-type = "New Actor"       [set tmp replace-item ?1 tmp ( item ?1 P3) ]
    if Actor-type = "Game"            [set tmp replace-item ?1 tmp ( item ?1 P-game) ]
    if Actor-type = "Negotiation"     [set tmp replace-item ?1 tmp ( item ?1 P-negotiation) ]
    if Actor-type = "Negotiation2"    [set tmp-n replace-item ?1 tmp-n ( item ?1 P0) set tmp replace-item ?1 tmp ( item ?1 P1)]
    if Actor-type = "Nashi"           [set tmp replace-item ?1 tmp ( item ?1 Nash-total)  ]
    if players?
      [
        if max P-game  = max P0 [set pcolor violet]  ; Investor            ;; who's p win  using maxP-game as pointer
        if max P-game  = max P1 [set pcolor blue  ]  ; policymaker
        if max P-game  = max P2 [set pcolor yellow ]  ; public overseer
        if max P-game  = max P3 [set pcolor green  ]  ; NEW ACTOR
       ]

    if tech = "NG"        [ set pcolor scale-color BROWN   item 0 tmp 0.5 0 ]
    if tech = "Nuclear"   [ set pcolor scale-color violet  item 1 tmp 0.5 0 ]
    if tech = "wind"      [ set pcolor scale-color SKY     item 2 tmp 0.5 0 ]
    if tech = "PV"        [ set pcolor scale-color ORANGE  item 3 tmp 0.5 0 ]
    if tech = "Hydro"     [ set pcolor scale-color BLUE    item 4 tmp 0.5 0 ]
    if tech = "Biomass"   [ set pcolor scale-color LIME    item 5 tmp 0.5 0 ]
    if tech = "WTE"       [ set pcolor scale-color GREEN   item 6 tmp 0.5 0 ]

    if tech = "mix" and item 0 tmp = max tmp [ set pcolor Brown  ] ;;  which tech win, using max tmp as pointer
    if tech = "mix" and item 1 tmp = max tmp [ set pcolor violet ]
    if tech = "mix" and item 2 tmp = max tmp [ set pcolor sky    ]
    if tech = "mix" and item 3 tmp = max tmp [ set pcolor orange ]
    if tech = "mix" and item 4 tmp = max tmp [ set pcolor blue   ]
    if tech = "mix" and item 5 tmp = max tmp [ set pcolor green  ]
    if tech = "mix" and item 6 tmp = max tmp [ set pcolor yellow ]

    if tech = "mix-negotiation"
      [ set max-tmp-n max P0     set n position max-tmp-n P0
        set max-tmp   max tmp    set m position max-tmp   tmp
        let a max Nash-total     let b position a Nash-total
        ifelse (item n X1 >= Negotiator_satification_level?)[set pcolor item n [brown violet sky orange blue green yellow]]
        [;set tmp-n replace-item n tmp-n 0
         ;set max2-tmp-n max tmp-n set k position max2-tmp-n tmp-n
         ;if ((item k X1) >= Negotiator_satification_level?) [set pcolor item k [brown violet sky orange blue green yellow]]
         ;if ((item k X1) <  Negotiator_satification_level?)
         ;[
          ifelse ((item m X0) >=  Negotiator_satification_level?) [set pcolor item m [brown violet sky orange blue green yellow]] [set pcolor black];item b [brown violet sky orange blue green yellow]]
          ;]
    ]]

    if tech = "mix-scale" and item 0 tmp = max tmp [ set pcolor scale-color brown   item 0 tmp 1 0]
    if tech = "mix-scale" and item 1 tmp = max tmp [ set pcolor scale-color violet  item 1 tmp 1 0]
    if tech = "mix-scale" and item 2 tmp = max tmp [ set pcolor scale-color sky     item 2 tmp 1 0]
    if tech = "mix-scale" and item 3 tmp = max tmp [ set pcolor scale-color orange  item 3 tmp 1 0]
    if tech = "mix-scale" and item 4 tmp = max tmp [ set pcolor scale-color blue    item 4 tmp 1 0]
    if tech = "mix-scale" and item 5 tmp = max tmp [ set pcolor scale-color green   item 5 tmp 1 0]
    if tech = "mix-scale" and item 6 tmp = max tmp [ set pcolor scale-color yellow  item 6 tmp 1 0]

  ]]


   ;=========indicators chang during negotiation==================================================================================================================================================================

end

to show-negitiation-map

  foreach tech-type-list [
    ?1 -> ask DM [
      if max P0 = item 0 P0 [set n 0]
      if max P0 = item 1 P0 [set n 1]
      if max P0 = item 2 P0 [set n 2]
      if max P0 = item 3 P0 [set n 3]
      if max P0 = item 4 P0 [set n 4]
      if max P0 = item 5 P0 [set n 5]
      if max P0 = item 6 P0 [set n 6]
  ]]

end

to nashi-equ
 ask DM [
     foreach tech-type-list [
    ?1 ->
      set nash-in replace-item ?1 nash-in (item ?1 X0 * (item ?1 p1 * item 0 p2 + item ?1 p1 * item 1 p2 + item ?1 p1 * item 2 p2 + item ?1 p1 * item 3 p2 + item ?1 p1 * item 4 p2 + item ?1 p1 * item 5 p2 + item ?1 p1 * item 6 p2))
      set nash-pm replace-item ?1 nash-pm (item ?1 X1 * (item ?1 p0 * item 0 p2 + item ?1 p0 * item 1 p2 + item ?1 p0 * item 2 p2 + item ?1 p0 * item 3 p2 + item ?1 p0 * item 4 p2 + item ?1 p0 * item 5 p2 + item ?1 p0 * item 6 p2))
      set nash-pu replace-item ?1 nash-pu (item ?1 X2 * (item ?1 p1 * item 0 p0 + item ?1 p1 * item 1 p0 + item ?1 p1 * item 2 p0 + item ?1 p1 * item 3 p0 + item ?1 p1 * item 4 p0 + item ?1 p1 * item 5 p0 + item ?1 p1 * item 6 p0))
  ]]

   ask DM [foreach tech-type-list [
    ?1 ->
      SET Nash-total replace-item ?1 Nash-total (item ?1 nash-in + item ?1 nash-pm + item ?1 nash-pu)
    ]]

end
@#$#@#$#@
GRAPHICS-WINDOW
332
27
764
488
-1
-1
4.764045
1
10
1
1
1
0
1
1
1
-44
44
-47
47
1
1
1
ticks
30.0

BUTTON
6
207
88
240
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
210
207
306
242
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
102
136
296
181
spatial_boundary
spatial_boundary
"BOUN" "NG" "Nuclear" "Wind" "PV" "Hydro" "Biomass" "WTE" "Elevation" "Slop" "Road" "Water" "Grid" "Energydemand" "POP" "ECO" "S-NG" "S-Nuclear" "S-wind" "S-PV" "S-Hydro" "S-Biomass" "S-WTE"
7

BUTTON
5
135
89
168
NIL
show-map
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
5
65
300
132
10

SLIDER
6
737
147
770
Weighting-eco
Weighting-eco
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
6
783
146
816
Weighting-soc
Weighting-soc
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
7
244
157
277
alpha
alpha
0
1
0.07
0.01
1
NIL
HORIZONTAL

BUTTON
104
207
198
241
go once
go 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
330
498
678
722
Investors' priority of energy technologies
Year
Priority
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot item 0 P-NG]"
"Nuclear" 1.0 0 -8630108 true "" "if Actor-types  > 0 [plot item 0 P-Nuclear]"
"Wind" 1.0 0 -13791810 true "" "if Actor-types  > 0 [plot item 0 P-wind]"
"PV" 1.0 0 -955883 true "" "if Actor-types  > 0 [plot item 0 P-PV]"
"Hydro" 1.0 0 -13345367 true "" "if Actor-types  > 0 [plot item 0 P-Hydro]"
"Biomass" 1.0 0 -10899396 true "" "if Actor-types  > 0 [plot item 0 P-Biomass]"
"WTE" 1.0 0 -1184463 true "" "if Actor-types  > 0 [plot item 0 P-WTE]"

SLIDER
170
244
307
277
Actor-types
Actor-types
0
5
4.0
1
1
NIL
HORIZONTAL

CHOOSER
6
346
151
391
Actor-type
Actor-type
"Investor" "Policy maker" "Public overseer" "New actor" "Game" "Negotiation" "Negotiation2" "Nashi"
4

CHOOSER
157
346
305
391
tech
tech
"NG" "Nuclear" "wind" "PV" "Hydro" "Biomass" "WTE" "mix" "mix-negotiation" "mix-scale" "NAN"
7

SLIDER
161
737
303
770
Weighting-env
Weighting-env
0
10
10.0
1
1
NIL
HORIZONTAL

BUTTON
7
29
88
62
NIL
load-map
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
683
496
1018
722
Policy makers' priority of energy technologies
Years
Priorities
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot item 1 P-NG]"
"Nuclear" 1.0 0 -8630108 true "" "if Actor-types  > 0 [plot item 1 P-Nuclear]"
"Wind" 1.0 0 -13791810 true "" "if Actor-types  > 0 [plot item 1 P-wind]"
"PV" 1.0 0 -955883 true "" "if Actor-types  > 0 [plot item 1 P-PV]"
"Hydro" 1.0 0 -13345367 true "" "if Actor-types  > 0 [plot item 1 P-Hydro]"
"Biomass" 1.0 0 -10899396 true "" "if Actor-types  > 0 [plot item 1 P-Biomass]"
"WTE" 1.0 0 -1184463 true "" "if Actor-types  > 0 [plot item 1 P-WTE]"

SWITCH
221
308
311
341
players?
players?
1
1
-1000

MONITOR
334
1018
407
1063
P-NG-initial
item 0 P-NG-initial
3
1
11

MONITOR
408
1018
497
1063
P-Nuclear-initial
item 0 P-nuclear-initial
3
1
11

MONITOR
499
1018
574
1063
P-Wind-initial
item 0 P-wind-initial
3
1
11

MONITOR
576
1018
650
1063
P-Solar-initial
item 0 P-PV-initial
3
1
11

MONITOR
335
1068
414
1113
P-Hydro-initial
item 0 P-hydro-initial
3
1
11

MONITOR
416
1068
504
1113
P-Biomass-initial
item 0 P-Biomass-initial
3
1
11

MONITOR
507
1068
587
1113
P-WtE-initial
item 0 P-WtE-initial
3
1
11

MONITOR
339
1255
409
1300
P-NG
item 0 P-NG
5
1
11

MONITOR
414
1255
485
1300
P-Nuclear
item 0 P-Nuclear
5
1
11

MONITOR
491
1255
559
1300
P-Wind
item 0 P-WIND
5
1
11

MONITOR
564
1255
633
1300
P-Solar
item 0 P-pv
5
1
11

MONITOR
339
1303
410
1348
P-Hydro
item 0 P-hydro
5
1
11

MONITOR
415
1303
486
1348
P-Biomass
item 0 P-biomass
5
1
11

MONITOR
492
1303
559
1348
P-WtE
item 0 P-Wte
5
1
11

MONITOR
689
1019
762
1064
P-NG-initial
item 1 P-ng-initial
3
1
11

MONITOR
766
1019
855
1064
 P-nuclear-initial
item 1 P-Nuclear-initial
3
1
11

MONITOR
858
1019
933
1064
 P-wind-initial
item 1 P-wind-initial
3
1
11

MONITOR
937
1019
1011
1064
P-Solar-initial
item 1 P-pv-initial
3
1
11

MONITOR
689
1070
770
1115
P-Hydro-initial
item 1 P-hydro-initial
3
1
11

MONITOR
774
1069
870
1114
 P-biomass-initial
item 1 P-Biomass-initial
3
1
11

MONITOR
874
1069
947
1114
 P-WtE-initial
item 1 P-WtE-initial
3
1
11

MONITOR
692
1256
763
1301
 P-NG
item 1 P-ng
5
1
11

MONITOR
767
1256
837
1301
 P-Nuclear
item 1 P-Nuclear
5
1
11

MONITOR
840
1256
906
1301
P-Wind
item 1 P-Wind
5
1
11

MONITOR
909
1256
975
1301
 P-Solar
item 1 P-pv
5
1
11

MONITOR
693
1304
764
1349
P-Hydro
item 1 P-hydro
5
1
11

MONITOR
766
1304
837
1349
 P-Biomass
item 1 P-Biomass
5
1
11

MONITOR
840
1304
906
1349
 P-WtE
item 1 P-WtE
5
1
11

MONITOR
1029
1018
1102
1063
P-NG-initial
item 2 P-NG-initial
3
1
11

MONITOR
1105
1018
1190
1063
P-Nuclear-initial
item 2 P-Nuclear-initial
3
1
11

MONITOR
1193
1018
1266
1063
P-Wind-initial
item 2 P-Wind-initial
3
1
11

MONITOR
1269
1018
1344
1063
P-Solar-initial
item 2 P-PV-initial
3
1
11

MONITOR
1029
1066
1110
1111
P-Hydro-initial
item 2 P-Hydro-initial
3
1
11

MONITOR
1113
1066
1206
1111
 P-Biomass-initial
item 2 P-Biomass-initial
3
1
11

MONITOR
1209
1066
1289
1111
P-WtE-initial
item 2 P-WtE-initial
3
1
11

MONITOR
1033
1256
1104
1301
 P-NG
item 2 P-NG
5
1
11

MONITOR
1110
1256
1177
1301
P-Nuclear
item 2 P-NUClEAr
5
1
11

MONITOR
1183
1256
1250
1301
P-Wind
item 2 P-Wind
5
1
11

MONITOR
1257
1256
1322
1301
 P-Solar
item 2 P-pv
5
1
11

MONITOR
1033
1304
1104
1349
P-Hydro
item 2 P-Hydro
5
1
11

MONITOR
1110
1305
1178
1350
P-Biomass
item 2 P-Biomass
5
1
11

MONITOR
1182
1305
1251
1350
 P-WtE
item 2 P-WtE
5
1
11

MONITOR
564
1303
634
1348
P-total
item 0 P-total-tech
2
1
11

MONITOR
910
1304
976
1349
P-total
Item 1 P-total-tech
2
1
11

MONITOR
1257
1306
1324
1351
P-total
item 2 P-total-tech
2
1
11

SLIDER
7
829
124
862
NG
NG
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
133
828
250
861
Nuclear
Nuclear
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
135
905
254
938
Wind
Wind
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
8
866
126
899
PV
PV
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
133
866
253
899
Hydro
Hydro
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
6
947
123
980
Biomass
Biomass
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
7
905
127
938
WtE
WtE
0
10
10.0
1
1
NIL
HORIZONTAL

SLIDER
162
782
305
815
Weighting-tec
Weighting-tec
0
10
10.0
1
1
NIL
HORIZONTAL

BUTTON
103
29
184
62
NIL
export-map
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
336
1002
679
1020
Priority of electricity generation technologies from survey data
11
0.0
1

TEXTBOX
338
1123
635
1151
Initial priority adapts to the spatial potential
11
0.0
1

TEXTBOX
342
1239
492
1257
Priority changes
11
0.0
1

MONITOR
337
1139
410
1184
P-NG-start
item 0 P-NG-start
3
1
11

MONITOR
411
1139
500
1184
P-Nuclear-start
item 0 P-Nuclear-start
3
1
11

MONITOR
501
1139
573
1184
P-Wind-start
item 0 P-wind-start
3
1
11

MONITOR
575
1139
651
1184
P-Solar-start
item 0 P-pv-start
3
1
11

MONITOR
337
1188
418
1233
P-Hydro-start
item 0 P-Hydro-start
3
1
11

MONITOR
419
1188
508
1233
P-Biomass-start
item 0 P-Biomass-start
3
1
11

MONITOR
510
1188
589
1233
P-WtE-start
item 0 P-wte-start
3
1
11

TEXTBOX
324
994
1719
1012
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
11
0.0
1

TEXTBOX
327
1231
1370
1254
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
11
0.0
1

TEXTBOX
324
1114
1374
1132
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
11
0.0
1

MONITOR
690
1139
762
1184
P-NG-start
item 1 P-NG-start
3
1
11

MONITOR
765
1139
856
1184
P-Nuclear-start
item 1 P-Nuclear-start
3
1
11

MONITOR
858
1139
933
1184
P-Wind-start
item 1 P-Wind-start
3
1
11

MONITOR
935
1139
1011
1184
 P-Solar-start
item 1 P-pv-start
3
1
11

MONITOR
690
1188
769
1233
P-Hydro-start
item 1 P-Hydro-start
3
1
11

MONITOR
772
1188
864
1233
P-Biomass-start
item 1 P-Biomass-start
3
1
11

MONITOR
866
1188
945
1233
P-WtE-start
item 1 P-WtE-start
3
1
11

MONITOR
1032
1139
1104
1184
P-NG-start
item 2 P-NG-start
3
1
11

MONITOR
1106
1139
1191
1184
P-Nuclear-start
item 2 P-Nuclear-start
3
1
11

MONITOR
1194
1139
1270
1184
P-Wind-start
item 2 P-Wind-start
3
1
11

MONITOR
1272
1139
1345
1184
 P-PV-start
item 2 P-pv-start
3
1
11

MONITOR
1033
1187
1110
1232
P-Hydro-start
item 2 P-Hydro-start
3
1
11

MONITOR
1113
1187
1202
1232
P-Biomass-start
item 2 P-Biomass-start
3
1
11

MONITOR
1205
1187
1284
1232
P-WtE-start
item 2 P-WtE-start
3
1
11

PLOT
807
23
1336
173
Price
Years
RMB/kWh
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "plot item 0 price"
"Nuclear" 1.0 0 -8630108 true "" "plot item 1 price"
"Wind" 1.0 0 -13791810 true "" "plot item 2 price"
"PV" 1.0 0 -955883 true "" "plot item 3 price"
"Hydro" 1.0 0 -13345367 true "" "plot item 4 price"
"Biomass" 1.0 0 -10899396 true "" "plot item 5 price"
"WTE" 1.0 0 -1184463 true "" "plot item 6 price"

PLOT
807
179
1337
329
QUAN
Years
TWh
0.0
40.0
0.0
100.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "plot item 0 Quan"
" Nuclear" 1.0 0 -8630108 true "" "plot item 1 Quan"
"Wind" 1.0 0 -13791810 true "" "plot item 2 Quan"
"PV" 1.0 0 -955883 true "" "plot item 3 Quan"
"Hydro" 1.0 0 -13345367 true "" "plot item 4 Quan"
"Biomass" 1.0 0 -10899396 true "" "plot item 5 Quan"
"WTE" 1.0 0 -1184463 true "" "plot item 6 Quan"

PLOT
1029
496
1367
720
Public's priority of energy technologies
Year
Priority
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot item 2 P-NG]"
"Nuclear" 1.0 0 -8630108 true "" "if Actor-types  > 0 [plot item 2 P-Nuclear]"
"Wind" 1.0 0 -13791810 true "" "if Actor-types  > 0 [plot item 2 P-Wind]"
"PV" 1.0 0 -955883 true "" "if Actor-types  > 0 [plot item 2 P-PV]"
"Hydro" 1.0 0 -13345367 true "" "if Actor-types  > 0 [plot item 2 P-Hydro]"
"Biomass" 1.0 0 -10899396 true "" "if Actor-types  > 0 [plot item 2 P-Biomass]"
"WTE" 1.0 0 -1184463 true "" "if Actor-types  > 0 [plot item 2 P-WTE]"

PLOT
1352
21
1689
247
Group priority of energy technologies
Year
Priority
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot (item 0 P-NG * C-IN + item 1 P-NG * C-PM + item 2 P-NG * C-PO)]"
"Nuclear" 1.0 0 -8630108 true "" "if Actor-types  > 0 [plot (item 0 P-Nuclear * C-IN + item 1 P-Nuclear * C-PM + item 2 P-Nuclear * C-PO)]"
"Wind" 1.0 0 -13791810 true "" "if Actor-types  > 0 [plot (item 0 P-Wind * C-IN + item 1 P-Wind * C-PM + item 2 P-Wind * C-PO)]"
"PV" 1.0 0 -955883 true "" "if Actor-types  > 0 [plot (item 0 P-PV * C-IN + item 1 P-PV * C-PM + item 2 P-PV * C-PO)]"
"Hydro" 1.0 0 -13345367 true "" "if Actor-types  > 0 [plot (item 0 P-Hydro * C-IN + item 1 P-Hydro * C-PM + item 2 P-Hydro * C-PO)]"
"Biomass" 1.0 0 -10899396 true "" "if Actor-types  > 0 [plot (item 0 P-Biomass * C-IN + item 1 P-Biomass  * C-PM + item 2 P-Biomass  * C-PO)]"
"WTE" 1.0 0 -1184463 true "" "if Actor-types  > 0 [plot (item 0 P-WTE * C-IN + item 1 P-WTE * C-PM + item 2 P-WTE * C-PO)]"

SLIDER
7
396
99
429
N-IN
N-IN
0
10
8.0
1
1
NIL
HORIZONTAL

SLIDER
109
396
201
429
N-PM
N-PM
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
211
396
303
429
N-PO
N-PO
0
10
4.0
1
1
NIL
HORIZONTAL

BUTTON
201
29
299
62
NIL
export-data
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
80
559
137
604
num-ng
num-ng
0
1
11

MONITOR
139
559
209
604
num-nuclear
num-nuclear
0
1
11

MONITOR
211
559
277
604
num-wind
num-wind
0
1
11

MONITOR
12
606
69
651
num-pv
num-pv
0
1
11

MONITOR
71
606
138
651
num-hydro
num-hydro
0
1
11

MONITOR
140
606
216
651
num-biomass
num-biomass
0
1
11

MONITOR
218
605
276
650
num-wte
num-WTE
0
1
11

BUTTON
12
564
77
598
export-tech
export-tech
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
654
137
687
NIL
export-tech-file
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
7
308
108
341
NIL
show-result-maps
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1375
496
1716
718
NA priority of energy technologies
NIL
NIL
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot item 3 P-NG]"
"Nuclear" 1.0 0 -8630108 true "" "if Actor-types  > 0 [plot item 3 P-Nuclear]"
"Wind" 1.0 0 -13791810 true "" "if Actor-types  > 0 [plot item 3 P-wind]"
"PV" 1.0 0 -955883 true "" "if Actor-types  > 0 [plot item 3 P-pv]"
"Hydro" 1.0 0 -13345367 true "" "if Actor-types  > 0 [plot item 3 P-hydro]"
"Biomass" 1.0 0 -10899396 true "" "if Actor-types  > 0 [plot item 3 P-biomass]"
"WTE" 1.0 0 -1184463 true "" "if Actor-types  > 0 [plot item 3 P-WTE]"

PLOT
806
338
1334
488
Market share
NIL
NIL
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "plot item 0 m-share-next"
"Nuclear" 1.0 0 -8630108 true "" "plot item 1 m-share-next"
"Wind" 1.0 0 -13791810 true "" "plot item 2 m-share-next"
"PV" 1.0 0 -955883 true "" "plot item 3 m-share-next"
"Hydro" 1.0 0 -13345367 true "" "plot item 4 m-share-next"
"Biomass" 1.0 0 -10899396 true "" "plot item 5 m-share-next"
"WTE" 1.0 0 -1184463 true "" "plot item 6 m-share-next"

SWITCH
110
308
219
341
Market-free?
Market-free?
1
1
-1000

BUTTON
167
431
301
464
sensitivity-analysis
sensitivity-analysis
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
7
431
145
476
Scenario-selection
Scenario-selection
"As usual" "SSPs1" "SSPs2" "SSPs3" "SSPs4" "SSPs5"
0

SLIDER
7
481
300
514
NG-price-increasing-rate-in-5yrs
NG-price-increasing-rate-in-5yrs
0
0.2
0.0
0.05
1
NIL
HORIZONTAL

SLIDER
8
515
299
548
Negotiator_satification_level?
Negotiator_satification_level?
0
1
0.4
0.1
1
NIL
HORIZONTAL

PLOT
330
731
677
964
Investors'value of energy technologies
Year
Value
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot item 0 MX-NG]"
"Nuclear" 1.0 0 -8630108 true "" "if Actor-types  > 0 [plot item 0 MX-Nuclear]"
"Wind" 1.0 0 -13791810 true "" "if Actor-types  > 0 [plot item 0 MX-wind]"
"PV" 1.0 0 -955883 true "" "if Actor-types  > 0 [plot item 0 MX-pv]"
"Hydro" 1.0 0 -13345367 true "" "if Actor-types  > 0 [plot item 0 MX-hydro]"
"Biomass" 1.0 0 -10899396 true "" "if Actor-types  > 0 [plot item 0 MX-biomass]"
"WTE" 1.0 0 -1184463 true "" "if Actor-types  > 0 [plot item 0 MX-wte]"

PLOT
684
731
1018
965
Policy makers'value of energy technologies
Year
Value
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot item 1 MX-NG]"
"Nuclear" 1.0 0 -8630108 true "" "if Actor-types  > 0 [plot item 1 MX-Nuclear]"
"Wind" 1.0 0 -13791810 true "" "if Actor-types  > 0 [plot item 1 MX-Wind]"
"PV" 1.0 0 -955883 true "" "if Actor-types  > 0 [plot item 1 MX-PV]"
"Hydro" 1.0 0 -13345367 true "" "if Actor-types  > 0 [plot item 1 MX-HYDRO]"
"Biomass" 1.0 0 -10899396 true "" "if Actor-types  > 0 [plot item 1 MX-Biomass]"
"WTE" 1.0 0 -1184463 true "" "if Actor-types  > 0 [plot item 0 MX-wte]"

PLOT
1030
732
1366
962
Publics' value of energy technologies
Year
Value
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot item 2 MX-NG]"
"Nuclear" 1.0 0 -8630108 true "" "if Actor-types  > 0 [plot item 2 MX-Nuclear]"
"Wind" 1.0 0 -13791810 true "" "if Actor-types  > 0 [plot item 2 MX-wind]"
"PV" 1.0 0 -955883 true "" "if Actor-types  > 0 [plot item 2 MX-pv]"
"Hydro" 1.0 0 -13345367 true "" "if Actor-types  > 0 [plot item 2 MX-hydro]"
"Biomass" 1.0 0 -10899396 true "" "if Actor-types  > 0 [plot item 2 MX-biomass]"
"WTE" 1.0 0 -1184463 true "" "if Actor-types  > 0 [plot item 2 MX-wte]"

PLOT
1375
731
1717
961
NA value of energy technologies
Year
Value
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot item 3 MX-NG]"
"Nuclear" 1.0 0 -8630108 true "" "if Actor-types  > 0 [plot item 3 MX-Nuclear]"
"Wind" 1.0 0 -13791810 true "" "if Actor-types  > 0 [plot item 3 MX-Wind]"
"PV" 1.0 0 -955883 true "" "if Actor-types  > 0 [plot item 3 MX-PV]"
"Hydro" 1.0 0 -6459832 true "" "if Actor-types  > 0 [plot item 3 MX-Hydro]"
"Biomass" 1.0 0 -10899396 true "" "if Actor-types  > 0 [plot item 3 MX-Biomass]"
"WTE" 1.0 0 -1184463 true "" "if Actor-types  > 0 [plot item 3 MX-WTE]"

PLOT
1353
264
1691
484
Nashi value of energy technologies
Year
Value
0.0
40.0
0.0
1.0
true
true
"" ""
PENS
"NG" 1.0 0 -6459832 true "" "plot item 0 MX-NASH"
"Nuclear" 1.0 0 -8630108 true "" "plot item 1 MX-NASH"
"Wind" 1.0 0 -13791810 true "" "plot item 2 MX-NASH"
"PV" 1.0 0 -955883 true "" "plot item 3 MX-NASH"
"Hydro" 1.0 0 -13345367 true "" "plot item 4 MX-NASH"
"Biomass" 1.0 0 -10899396 true "" "plot item 5 MX-NASH"
"WTE" 1.0 0 -1184463 true "" "plot item 6 MX-NASH"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

clock
true
0
Circle -7500403 true true 30 30 240
Polygon -16777216 true false 150 31 128 75 143 75 143 150 158 150 158 75 173 75
Circle -16777216 true false 135 135 30

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="2" runMetricsEveryStep="true">
    <setup>load-map
setup</setup>
    <go>go</go>
    <metric>P-NG</metric>
    <enumeratedValueSet variable="WtE">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Wind">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Weighting-tec">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Actor-types">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-PO">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-IN">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="alpha">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Marketlized-free?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Weighting-env">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PV">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tech">
      <value value="&quot;mix&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Weighting-eco">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Weighting-soc">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="players?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Actor-type">
      <value value="&quot;Negotiation&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Nuclear">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="spatial_boundary">
      <value value="&quot;S-wind&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Biomass">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Hydro">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NG">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GHG?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="N-PM">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
