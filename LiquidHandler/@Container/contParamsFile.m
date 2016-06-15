varArray = {'contName'  ,  'microplate_96_deep_well' ;
    'type'      ,  'microplate';
    'nRows'     ,   12;
    'nCols'     ,   8;
    'a1_x'      ,  13.5 ;
    'a1_y'      ,   16.5;
    'spacing'   ,   9;
    'diameter'  ,   7.5;
    'height'    ,   33.5;
    'well_depth',   33.5;
    'volume'    ,   2000;
    'min_vol'   ,   '';
    'max_vol'   ,   '';
    'custom'    ,    ''};

varArray = {'contName'  , 'microplate_348'  ;
    'type'      , 'microplate'  ;
    'nRows'     , 24  ;
    'nCols'     , 16  ;
    'a1_x'      , 12.13  ;
    'a1_y'      , 8.99  ;
    'spacing'   , 4.5  ;
    'diameter'  , 3.1  ;
    'height'    , 10  ;
    'well_depth', 9.5  ;
    'volume'    , 50  ;
    'min_vol'   , 1  ;
    'max_vol'   , 30  ;
    'custom'    , '{none}'   };


varArray = {'contName'  , 'tiprack_10'  ;
    'type'      ,  'tiprack' ;
    'nRows'     ,  12 ;
    'nCols'     ,  8 ;
    'a1_x'      ,   0;
    'a1_y'      ,   0;
    'spacing'   ,   8.85;
    'diameter'  ,   3.5;
    'height'    ,   0;
    'well_depth',   NaN;
    'volume'    ,   10;
    'min_vol'   ,   .5;
    'max_vol'   ,   10;
    'custom'    ,  '{none}'  };

varArray = {'contName'  ,  'tiprack_200' ;
    'type'      ,  'tiprack' ;
    'nRows'     ,  12 ;
    'nCols'     ,  8 ;
    'a1_x'      ,  0 ;
    'a1_y'      ,  0 ;
    'spacing'   ,  8.85 ;
    'diameter'  ,  3.5 ;
    'height'    ,  0 ;
    'well_depth',  NaN ;
    'volume'    ,  200 ;
    'min_vol'   ,  20 ;
    'max_vol'   ,  200 ;
    'custom'    ,  '{none}'  };

varArray = {'contName'  , 'tiprack_1000'  ;
    'type'      ,  'tiprack' ;
    'nRows'     ,  12 ;
    'nCols'     ,  8 ;
    'a1_x'      ,  0 ;
    'a1_y'      ,  0 ;
    'spacing'   ,  9 ;
    'diameter'  ,  6.4 ;
    'height'    ,  0 ;
    'well_depth',  NaN ;
    'volume'    ,  1000 ;
    'min_vol'   ,  100 ;
    'max_vol'   ,  1000 ;
    'custom'    ,  '{none}'  };

varArray = {'contName'  ,   ;
    'type'      ,   ;
    'nRows'     ,   ;
    'nCols'     ,   ;
    'a1_x'      ,   ;
    'a1_y'      ,   ;
    'spacing'   ,   ;
    'diameter'  ,   ;
    'height'    ,   ;
    'well_depth',   ;
    'volume'    ,   ;
    'min_vol'   ,   ;
    'max_vol'   ,   ;
    'custom'    ,  '{none}'  };

varArray = {'contName'  , 'trash'  ;
    'type'      , 'trash'  ;
    'nRows'     , 1  ;
    'nCols'     , 1  ;
    'a1_x'      , 50  ;
    'a1_y'      , 50  ;
    'spacing'   , 0  ;
    'diameter'  , NaN  ;
    'height'    , NaN ;
    'well_depth', NaN  ;
    'volume'    , NaN  ;
    'min_vol'   , NaN  ;
    'max_vol'   , NaN  ;
    'custom'    ,  '{none}'  };



customStr = ['{"A1":{"x": 0,"y":0},',...
              '"B1":{"x": 32,"y":0},',...
              '"C1":{"x": 64,"y":0},',...
              '"A2":{"x": 0,"y":24},',...
              '"B2":{"x": 32,"y":24},',...
              '"C2":{"x": 64,"y":24},',...
              '"A3":{"x": 10,"y":50,"diameter":26,"volume":50000},',...
              '"B3":{"x": 55,"y":50,"diameter":26,"volume":50000},',...
              '"A4":{"x": 10,"y":86,"diameter":26,"volume":50000},',...
              '"B4":{"x": 55,"y":86,"diameter":26,"volume":50000}}'];
          
customJSON = loadjson(customStr)

varArray = {'contName'  , '15_50mL_tuberack'  ;
    'type'      ,  'tuberack' ;
    'nRows'     ,  3 ;
    'nCols'     ,  4 ;
    'a1_x'      ,  0 ;
    'a1_y'      ,  0 ;
    'spacing'   ,  0 ;
    'diameter'  ,  16 ;
    'height'    ,  77 ;
    'well_depth',  76 ;
    'volume'    ,  15000 ;
    'min_vol'   ,  NaN ;
    'max_vol'   ,  15000;
    'custom'    ,  customJSON  };

  A2: 
     x: 0
     y: 24
  B2: 
     x: 32
     y: 24
  C2: 
     x: 64
     y: 24
  A3: 
     x: 10
     y: 50
     depth: 76
     diameter: 26
     volume: 50000
  B3: 
     x: 55
     y: 50
     depth: 76
     diameter: 26
     volume: 50000
  A4: 
     x: 5
     y: 86
     diameter: 26
     volume: 50000
  B4: 
     x: 55
     y: 86
     depth: 76
     diameter: 26
     volume: 50000

                    
