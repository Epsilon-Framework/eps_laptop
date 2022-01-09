Config = {}

Config.Lang = "nl"
Config.DateLocal = "en-GB" -- hh:mm
                           -- dd/mm/yyyy


-----     ______________________________________ Boosting ______________________________________     -------

Config.PoliceJobName = "police"
Config.MinCopsOnline = 0

Config.ExpireTime = { hour=6, min=0, sec=0 }
Config.MaxContracts = 5
Config.ContractShare = {--The amount of Reputation and BNE in percent the players who joined a contract will recieve when contract is completed,
    bne = 0.25, --25% of the original contract value
    reputation = 0.75 --75% of the original contract reputation
}


Config.Notifications = {
    ["DropOffMsg"] = "Get out of the car and leave the area, you will get your money soon"
}

Config.Emails = { -- %s is a place holder for a value
    ["StartContract"] = {
        -- [1|%s] = Vehicle Name
        -- [2|%s] = Vehicle Class
        -- [3|%s] = Vehicle Plate

        subject = "Contract Details",
        message =
        [["Yo buddy , this is the vehicle details.

        <strong>
        Vehicle Model: %s<br>
        Vehicle Class: %s<br>
        Vehicle Plate: %s<br>
        </strong>"
        ]],
    },

    ["JoinContract"] = {
        -- [1|%s] = Vehicle Name
        -- [2|%s] = Vehicle Class
        -- [3|%s] = Vehicle Plate

        message =
        [["Yo buddy nice you want to help out, 
        this is the vehicle details.

        <strong>
        Vehicle Model: %s<br>
        Vehicle Class: %s<br>
        Vehicle Plate: %s<br>
        </strong>"
        ]],
    },
    ["RecievedContract"] = {
        -- [1|%s] = Vehicle Class

        subject = "Contract Offer",
        message =
        [[You have recieved a %s Boosting...
        ]],
    },
    ["CompletedContract"] = {
        -- [1|%s] = BNE Value

        sender = "Boosting inc.",
        subject = "Contract Payout",
        message =
        [[You just received %s BNE from your last contract.
        ]],
    }
}

Config.VehicleBlip = {
    Radius = 200.0,
    Color = 5,
    Alpha = 128,
    Route = false,
}

Config.DropOffBlip = {
    Sprite = 514,
    Scale = 0.7,
    Color = 5,
    Route = true,
    Label = "Drop Off",
}

Config.TrackerBlip = {
    Sprite = 161,
    Scale = 1.1,
    Color = 1,
}

Config.Classes = {
    ["S+"] = {
        value = { min=250, max=250 },
        trackerUpdateTime = 3000, -- in ms| 1s == 1000 ms
        tracker = false,
        reputationMult = { min=2, max=2.3 }
    },
    ["S"] = {
        value = { min=200, max=200 },
        trackerUpdateTime = 3000, -- in ms| 1s == 1000 ms
        tracker = false,
        reputationMult = { min=1.5, max=2.3 }
    },
    ["A"] = {
        value = { min=150, max=150 },
        trackerUpdateTime = 3000, -- in ms| 1s == 1000 ms
        tracker = false,
        reputationMult = { min=1.3, max=2 }
    },
    ["B"] = {
        value = { min=100, max=100 },
        trackerUpdateTime = 3000, -- in ms| 1s == 1000 ms
        tracker = false,
        reputationMult = { min=1, max=1.5 }
    },
    ["C"] = {
        value = { min=50, max=50 },
        trackerUpdateTime = 3000, -- in ms| 1s == 1000 ms
        tracker =  false,
        reputationMult = { min=1, max=1.2 }
    },
    ["D"] = {
        value = { min=25, max=25 },
        trackerUpdateTime = 3000, -- in ms| 1s == 1000 ms
        tracker = false,
        reputationMult = { min=1, max=1.1 }
    }
}

-----      |REPUTATION LEVELS|     -------
Config.Levels = {
    {
        rep = 0, --<<<<<<<<<<<<<<<<<<<<<[ Reputation ]
        label = "D", --<<<<<<<<<<<<<<<<<[ Label showed ]
        weights = { --<<<<<<<<<<<<<<<<<<[ Contract Type Weights ]
            { value="S+", weight=0  },
            { value="S",  weight=0  },
            { value="A",  weight=0  },
            { value="B",  weight=1  },
            { value="C",  weight=9  },
            { value="D",  weight=90 }
        },
        reputationGain = { min=50, max=60 },
        bneMult = { min=1, max=1 }
    },
    {
        rep = 1000, --<<<<<<<<<<<<<<<<<<<<<[ Reputation ]
        label = "C", --<<<<<<<<<<<<<<<<<<<<[ Label showed ]
        weights = { --<<<<<<<<<<<<<<<<<<<<<[ Contract Type Weights ]
            { value="S+", weight=0  },
            { value="S",  weight=0  },
            { value="A",  weight=1  },
            { value="B",  weight=9  },
            { value="C",  weight=20 },
            { value="D",  weight=50 }
        },
        reputationGain = { min=50, max=60 },
        bneMult = { min=1, max=1 }
    },
    {
        rep = 2000, --<<<<<<<<<<<<<<<<<<<<<[ Reputation ]
        label = "B", --<<<<<<<<<<<<<<<<<<<<[ Label showed ]
        weights = { --<<<<<<<<<<<<<<<<<<<<<[ Contract Type Weights ]
            { value="S+", weight=0  },
            { value="S",  weight=1  },
            { value="A",  weight=5  },
            { value="B",  weight=14 },
            { value="C",  weight=60 },
            { value="D",  weight=20 }
        },
        reputationGain = { min=50, max=60 },
        bneMult = { min=1, max=1 }
    },
    {
        rep = 5000, --<<<<<<<<<<<<<<<<<<<<<[ Reputation ]
        label = "A", --<<<<<<<<<<<<<<<<<<<<[ Label showed ]
        weights = { --<<<<<<<<<<<<<<<<<<<<<[ Contract Type Weights ]
            { value="S+", weight=0  },
            { value="S",  weight=1  },
            { value="A",  weight=39 },
            { value="B",  weight=50 },
            { value="C",  weight=1  },
            { value="D",  weight=1  }
        },
        reputationGain = { min=50, max=60 },
        bneMult = { min=1, max=1 }
    },
    {
        rep = 10000, --<<<<<<<<<<<<<<<<<<<<<[ Reputation ]
        label = "S", --<<<<<<<<<<<<<<<<<<<<<[ Label showed ]
        weights = { --<<<<<<<<<<<<<<<<<<<<<<[ Contract Type Weights ]
            { value="S+", weight=0  },
            { value="S",  weight=20 },
            { value="A",  weight=30 },
            { value="B",  weight=44 },
            { value="C",  weight=5  },
            { value="D",  weight=1  }
        },
        reputationGain = { min=50, max=60 },
        bneMult = { min=1, max=1 }
    },
    {
        rep = 20000, --<<<<<<<<<<<<<<<<<<<<<[ Reputation ]
        label = "S+", --<<<<<<<<<<<<<<<<<<<<[ Label showed ]
        weights = { --<<<<<<<<<<<<<<<<<<<<<<[ Contract Type Weights ]
            { value="S+", weight=10  },
            { value="S",  weight=30 },
            { value="A",  weight=20 },
            { value="B",  weight=15 },
            { value="C",  weight=1  },
            { value="D",  weight=1  }
        },
        raeputationGain = { min=50, max=60 },
        bneMult = { min=1, max=1 }
    },
}


-----     VEHCILES TO SPAWN        -------
Config.Vehicles = {

    ------------ S+ CLASS ------------
    ["S+"] = {
        "admin"
    },

    ------------ S CLASS ------------
    ["S"] = {
        "t20",
        "Zion2",
        "Felon",
        "Zentorno",
    },

    ------------ A CLASS ------------
    ["A"] = {
        "Oracle2",
        "Windsor2",
        "SabreGT2",
        "Sentinel2",
        "Zion",
        "Phoenix",
        "Washington",
        "Banshee2",
        "Infernus2",
        "Nero",
        "Nero2",
        "Brawler",
    },

    ------------ B CLASS ------------
    ["B"] = {
        "Prairie",
        "Chino",
        "Dukes",
        "Virgo3",
        "Tampa",
        "Blade",
        "Sultan",
        "Primo",
        "Primo2",
        "Regina",
        "ZType",
        "Bison3",
        "Bison",
        "blista",
        "blista2",
        "Issi2",
        "Issi2",
        "Buccaneer2",
        "Picador",
    },

    ------------ C CLASS ------------
    ["C"] = {
        "Tornado3",
        "BType",
        "Sadler",
        "Bison2",
        "Minivan2",
        "RatLoader",
        "Virgo2",
    },

    ------------ D CLASS ------------
    ["D"] = {
        "Emperor2",
        "Dilettante",
    }
}


-----     DROP OFF LOCATIONS        -------
Config.DropOffCoords = {
	{ x =   196.87251281738, y =  -156.60850524902, z =    56.7869758605960 },
	{ x = -1286.96215820310, y =  -274.47973632813, z =    38.7249183654790 },
	{ x = -1330.84326171880, y = -1034.86230468750, z =     7.5180292129510 },
}


-----     VEHICLE SPAWN LOCATIONS        -------
Config.VehicleCoords = {
    { x = -1132.39500, y = -1070.60700, z =     1.64372, h = 120.000000 },
    { x =  -935.11760, y = -1080.55200, z =     1.68334, h = 120.106000 },
    { x = -1074.95300, y = -1160.54500, z =     1.66157, h = 119.000000 },
    { x = -1023.62500, y =  -890.40140, z =     5.20200, h = 216.039900 },
    { x = -1609.64700, y =  -382.79200, z =    42.70383, h =  52.535000 },
    { x = -1527.88000, y =  -309.87570, z =    47.88678, h = 323.430000 },
    { x = -1658.96900, y =  -205.17320, z =    54.84480, h =  71.138000 },
    { x =    97.57888, y = -1946.47200, z =    20.27978, h = 215.933000 },
    { x =   -61.59007, y = -1844.62100, z =    26.16850, h = 138.984800 },
    { x =    28.51439, y = -1734.88100, z =    28.54150, h = 231.968000 },
    { x =   437.54280, y = -1925.46500, z =    24.00400, h =  28.822860 },
    { x =   406.53160, y = -1920.47100, z =    24.51589, h = 224.643200 },
    { x =   438.44820, y = -1838.67200, z =    27.47369, h =  42.812900 },
    { x =   187.35300, y = -1542.98400, z =    28.72487, h =  39.006270 },
    { x =  1153.46700, y =  -330.26820, z =    68.60548, h =   7.200000 },
    { x =  1144.62200, y =  -465.76940, z =    66.20689, h =  76.612770 },
    { x =  1295.84400, y =  -567.60000, z =    70.77858, h = 166.552000 },
    { x =  1319.56600, y =  -575.94920, z =    72.58221, h = 155.924900 },
    { x =  1379.46600, y =  -596.09990, z =    73.89736, h = 230.594000 },
    { x =  1256.64800, y =  -624.05940, z =    68.93141, h = 117.415000 },
    { x =  1368.12700, y =  -748.26130, z =    66.62316, h = 231.535000 },
    { x =   981.71670, y =  -709.73890, z =    57.18427, h = 128.729000 },
    { x =   958.20600, y =  -662.75450, z =    57.57119, h = 116.929900 },
    { x = -2012.40400, y =   484.04580, z =   106.55970, h =  78.130000 },
    { x = -2001.29400, y =   454.76470, z =   102.01940, h = 108.117800 },
    { x = -1994.72500, y =   377.49330, z =    94.04324, h =  89.640670 },
    { x = -1967.54900, y =   262.15070, z =    86.23506, h = 109.184600 },
    { x =  -989.67960, y =   418.49770, z =    74.73100, h =  20.262000 },
    { x =  -979.65170, y =   518.11900, z =    81.03075, h = 328.386000 },
    { x = -1040.91500, y =   496.56220, z =    82.52803, h =  54.439000 },
    { x = -1094.62100, y =   439.26050, z =    74.84596, h =  84.936000 },
    { x = -1236.89500, y =   487.97220, z =    92.82943, h = 330.663400 },
    { x = -1209.09800, y =   557.95880, z =    99.04235, h =   3.252600 },
    { x = -1155.29600, y =   565.42970, z =   101.39190, h =   7.410600 },
    { x = -1105.37800, y =   551.57970, z =   102.17590, h = 211.711000 },
    { x =  1708.02000, y =  3775.48600, z =    34.08183, h =  35.045800 },
    { x =  2113.36500, y =  4770.11300, z =    40.72895, h = 297.532300 },
    { x =  2865.44800, y =  1512.71500, z =    24.12726, h = 252.326200 },
    { x =  1413.97300, y =  1119.02400, z =   114.39810, h = 305.998680 },
    { x =   -78.39651, y =   497.47490, z =   143.96460, h = 160.294800 },
    { x =  -248.98410, y =   492.91050, z =   125.07110, h = 208.576100 },
    { x =    14.09792, y =   548.84020, z =   175.75710, h = 241.401977 },
    { x =    51.48445, y =   562.25090, z =   179.84920, h = 203.159000 },
    { x =  -319.39120, y =   478.97310, z =   111.71860, h = 298.764500 },
    { x =  -202.00350, y =   410.20640, z =   110.00860, h = 195.613600 },
    { x =  -187.10090, y =   379.95140, z =   108.01380, h = 176.946200 },
    { x =   213.51590, y =   389.31230, z =   106.41540, h = 348.890255 },
    { x =   323.72560, y =   343.33080, z =   104.76100, h = 345.494260 },
    { x =   701.11970, y =   254.44240, z =    92.85217, h = 240.628840 },
    { x =   656.47580, y =   184.84820, z =    94.53828, h = 248.937600 },
    { x =   615.55240, y =   161.48010, z =    96.91451, h =  69.257700 },
    { x =   899.26930, y =   -41.99047, z =    78.32366, h =  28.130860 },
    { x =   873.33140, y =     9.00833, z =    78.32432, h = 329.343000 },
    { x =   941.24770, y =  -248.01610, z =    68.15629, h = 328.122000 },
    { x =   842.75010, y =  -191.99540, z =    72.19750, h = 329.212400 },
    { x =   534.35830, y =   -26.70270, z =    70.18916, h =  30.709780 },
    { x =   302.50770, y =  -176.57270, z =    56.95071, h = 249.333900 },
    { x =    85.26346, y =  -214.71790, z =    54.05132, h = 160.214200 },
    { x =    78.38569, y =  -198.41820, z =    55.79539, h =  70.137700 },
    { x =   -30.09893, y =   -89.37914, z =    56.81360, h = 340.328790 },
}


-----     CITIZEN NAMES        -------
Config.CitizenFirstNames = {
    "Geoffrey", "Judy", "Nathan", "Arnold", "Brittany", "Natalie", "Garry", "Terrell", "Vincent", "Todd", "Elvira", "Rudy",
    "Rickey", "Shawn", "Archie", "Josephine", "Gregory", "Marjorie","Lois", "Darla", "Guadalupe", "Jack", "Clifford", "Neil", "Betsy", "Regina",
    "Maxine", "Elisa", "Geneva", "Trevor", "Candice", "Roman", "Juanita", "Laurie", "Horace", "Julio", "Rosalie", "Eleanor", "Kristine", "Lynn",
    "Ruben", "Janice", "Drew", "Maggie", "Kenneth", "Sara ", "Allen", "Jared", "Jesse", "Andre", "Pam", "Abel", "Casey", "Kimberly", "Gary",
    "Theresa ", "Lorraine", "Melvin", "Courtney", "Ora", "Cecil", "Kenny", "Salvatore", "Ethel", "Ross", "Peter", "Noel", "Joseph", "Russell", "Phil",
    "Bertha", "Rufus", "Jeremiah", "Kim Roy", "Sally", "Joshua", "Kurt", "Marlon", "Jane", "Marshall", "Stacey", "Ivan", "Alberta", "Earnest",
    "Henrietta","Bryant", "Viola", "Roosevelt", "Rolando", "Bernice", "Carl", "Justin", "Toni", "Amos", "Lamar", "Wm", "Johnnie", "Jenna",
}

Config.CitizenLastNames = {
    "Willis", "Gordon", "Ross", "Mona", "Collins", "Pittman", "Wallace", "Talyor", "Stewart", "Todd",
    "Price", "Hardy", "Gross", "Newman", "Nash", "Harris", "Delgado", "Hall", "Elliott", "Carlson", "Phillips", "Lowe", "Blake", "Curry",
    "Sanchez", "Howard", "Mitchell", "Moss", "Davis", "Estrada", "Newton", "Shelton", "Murphy", "Austin", "Rhodes", "Thompson", "Goodwin",
    "Kennedy", "Norton", "Gilbert", "Frank", "Olson", "Huff", "Page", "Parks", "Garner", "Mcdaniel", "Herrera", "Morton", "Klein",
    "Little", "Fleming", "Ruiz", "Foster", "Brewer", "Glover", "Mccormick", "Patrick", "Drake", "Frazier", "Mendez", "Burns", "Pope",
    "Moreno", "Richardson", "Larson", "Martinez", "Sims", "Hubbard", "Evans", "Hunter", "Keller", "Simon", "Cruz", "Carroll", "Russell",
    "Obrien", "Hunt", "Singleton", "Carter", "Collier", "Johnston", "Morris", "Lindsey", "Oliver", "Paul", "Doyle", "Green", 
    "Wagner", "Jacobs", "Clayton", "Graham", "Knight", "Carr", "Briggs", "Williamson", "Leonard", "Allison", "Quinn", "Anderson"
}

COLOR_NAMES = {
    "Metallic Black",
    "Metallic Graphite Black",
    "Metallic Black Steal",
    "Metallic Dark Silver",
    "Metallic Silver",
    "Metallic Blue Silver",
    "Metallic Steel Gray",
    "Metallic Shadow Silver",
    "Metallic Stone Silver",
    "Metallic Midnight Silver",
    "Metallic Gun Metal",
    "Metallic Anthracite Grey",
    "Matte Black",
    "Matte Gray",
    "Matte Light Grey",
    "Util Black",
    "Util Black Poly",
    "Util Dark silver",
    "Util Silver",
    "Util Gun Metal",
    "Util Shadow Silver",
    "Worn Black",
    "Worn Graphite",
    "Worn Silver Grey",
    "Worn Silver",
    "Worn Blue Silver",
    "Worn Shadow Silver",
    "Metallic Red",
    "Metallic Torino Red",
    "Metallic Formula Red",
    "Metallic Blaze Red",
    "Metallic Graceful Red",
    "Metallic Garnet Red",
    "Metallic Desert Red",
    "Metallic Cabernet Red",
    "Metallic Candy Red",
    "Metallic Sunrise Orange",
    "Metallic Classic Gold",
    "Metallic Orange",
    "Matte Red",
    "Matte Dark Red",
    "Matte Orange",
    "Matte Yellow",
    "Util Red",
    "Util Bright Red",
    "Util Garnet Red",
    "Worn Red",
    "Worn Golden Red",
    "Worn Dark Red",
    "Metallic Dark Green",
    "Metallic Racing Green",
    "Metallic Sea Green",
    "Metallic Olive Green",
    "Metallic Green",
    "Metallic Gasoline Blue Green",
    "Matte Lime Green",
    "Util Dark Green",
    "Util Green",
    "Worn Dark Green",
    "Worn Green",
    "Worn Sea Wash",
    "Metallic Midnight Blue",
    "Metallic Dark Blue",
    "Metallic Saxony Blue",
    "Metallic Blue",
    "Metallic Mariner Blue",
    "Metallic Harbor Blue",
    "Metallic Diamond Blue",
    "Metallic Surf Blue",
    "Metallic Nautical Blue",
    "Metallic Bright Blue",
    "Metallic Purple Blue",
    "Metallic Spinnaker Blue",
    "Metallic Ultra Blue",
    "Metallic Bright Blue",
    "Util Dark Blue",
    "Util Midnight Blue",
    "Util Blue",
    "Util Sea Foam Blue",
    "Uil Lightning blue",
    "Util Maui Blue Poly",
    "Util Bright Blue",
    "Matte Dark Blue",
    "Matte Blue",
    "Matte Midnight Blue",
    "Worn Dark blue",
    "Worn Blue",
    "Worn Light blue",
    "Metallic Taxi Yellow",
    "Metallic Race Yellow",
    "Metallic Bronze",
    "Metallic Yellow Bird",
    "Metallic Lime",
    "Metallic Champagne",
    "Metallic Pueblo Beige",
    "Metallic Dark Ivory",
    "Metallic Choco Brown",
    "Metallic Golden Brown",
    "Metallic Light Brown",
    "Metallic Straw Beige",
    "Metallic Moss Brown",
    "Metallic Biston Brown",
    "Metallic Beechwood",
    "Metallic Dark Beechwood",
    "Metallic Choco Orange",
    "Metallic Beach Sand",
    "Metallic Sun Bleeched Sand",
    "Metallic Cream",
    "Util Brown",
    "Util Medium Brown",
    "Util Light Brown",
    "Metallic White",
    "Metallic Frost White",
    "Worn Honey Beige",
    "Worn Brown",
    "Worn Dark Brown",
    "Worn straw beige",
    "Brushed Steel",
    "Brushed Black steel",
    "Brushed Aluminium",
    "Chrome",
    "Worn Off White",
    "Util Off White",
    "Worn Orange",
    "Worn Light Orange",
    "Metallic Securicor Green",
    "Worn Taxi Yellow",
    "police car blue",
    "Matte Green",
    "Matte Brown",
    "Worn Orange",
    "Matte White",
    "Worn White",
    "Worn Olive Army Green",
    "Pure White",
    "Hot Pink",
    "Salmon pink",
    "Metallic Vermillion Pink",
    "Orange",
    "Green",
    "Blue",
    "Mettalic Black Blue",
    "Metallic Black Purple",
    "Metallic Black Red",
    "hunter green",
    "Metallic Purple",
    "Metaillic V Dark Blue",
    "MODSHOP BLACK1",
    "Matte Purple",
    "Matte Dark Purple",
    "Metallic Lava Red",
    "Matte Forest Green",
    "Matte Olive Drab",
    "Matte Desert Brown",
    "Matte Desert Tan",
    "Matte Foilage Green",
    "DEFAULT ALLOY COLOR",
    "Epsilon Blue",
}