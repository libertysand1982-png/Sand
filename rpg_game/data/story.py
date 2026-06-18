STORY = {
    "start": {
        "id": "start",
        "title": "La Taverne du Griffon d'Or",
        "text": """La pluie martèle les volets de la Taverne du Griffon d'Or à Piedval, petit village au bord de la Forêt de Brume. \nVous êtes attablé devant une chope de bière brune quand l'aubergiste, un homme rondouillard nommé Bertrand, s'approche d'un air soucieux.\n\n"Étranger... je vois à votre équipement que vous n'êtes pas un simple voyageur. Nous avons besoin d'aide. Trois villageois ont disparu ce mois-ci en entrant dans la Forêt de Brume. Les gardes du comte refusent d'y mettre les pieds depuis que leur chef en est revenu fou il y a deux semaines."\n\nIl pose sur la table une bourse qui cliquète lourdement.\n\n"Cent pièces d'or si vous découvrez ce qui se passe là-dedans. Deux cents si vous ramenez les disparus, ou une preuve de leur sort."\n\nLa forêt murmure au dehors. Dans l'âtre, les flammes vacillent sans raison apparente.""",
        "choices": [
            {"text": "Accepter la mission et interroger Bertrand sur la forêt", "next": "taverne_info", "skill_check": None},
            {"text": "Accepter et partir immédiatement pour la forêt", "next": "lisiere_foret", "skill_check": None},
            {"text": "[Persuasion DD10] Négocier une avance de 50 pièces", "next": "negociation", "skill_check": "Persuasion", "difficulty": 10},
            {"text": "Demander s'il y a d'autres témoins", "next": "temoins", "skill_check": None},
        ]
    },
    "negociation": {
        "id": "negociation",
        "title": "Negociation",
        "text": """RÉSULTAT DU JET —\n\nEn cas de succès: Bertrand soupire, fouille sous le comptoir et pose 50 pièces d'or sur la table. "Soit. Mais revenez avec des réponses."\n\nEn cas d'échec: Bertrand secoue la tête. "Pas d'avance, étranger. Résultats d'abord."\n\nDans les deux cas, vous acceptez la mission.""",
        "choices": [
            {"text": "Interroger Bertrand sur la forêt", "next": "taverne_info", "skill_check": None},
            {"text": "Partir pour la forêt", "next": "lisiere_foret", "skill_check": None},
        ]
    },
    "temoins": {
        "id": "temoins",
        "title": "Les Témoins",
        "text": """Bertrand vous amène une vieille femme, Madeleine, dont les mains tremblent autour de sa tasse de tisane.\n\n"Mon fils... il est parti chercher des champignons à l'orée de la forêt. Il est rentré en courant deux heures plus tard, le visage blanc comme neige. Il a dit avoir vu des lumières bleues entre les arbres, et entendu... des voix. Des voix qui récitaient quelque chose en boucle."\n\nElle baisse la voix.\n\n"Le lendemain, il est reparti. Seul. Comme si quelque chose l'appelait. C'était il y a quinze jours."\n\nUn vieil homme dans le coin vous fait signe. C'est Roderic, l'ancien chasseur.\n\n"J'ai vu quelque chose aussi. Un village à l'intérieur de la forêt — mais sur aucune carte. Les arbres autour étaient noirs. Morts. Je suis pas resté pour en voir plus."\n\nVous avez maintenant des informations précieuses.""",
        "choices": [
            {"text": "Remercier les témoins et interroger l'aubergiste", "next": "taverne_info", "skill_check": None},
            {"text": "Partir immédiatement pour la forêt", "next": "lisiere_foret", "skill_check": None},
        ]
    },
    "taverne_info": {
        "id": "taverne_info",
        "title": "Informations sur la Forêt",
        "text": """Bertrand s'essuie les mains sur son tablier et parle à voix basse.\n\n"La Forêt de Brume... on dit qu'un sorcier y vivait autrefois. Un certain Valdris l'Ombre. Il cherchait le secret de la vie éternelle. Quand il a disparu il y a cent ans, on a pensé qu'il avait échoué."\n\nIl s'arrête, regardant les flammes.\n\n"Mais ces dernières semaines... les animaux fuient la forêt. La brume n'est plus naturelle — elle bouge à l'envers du vent. Et les disparus avaient tous quelque chose en commun: ils avaient tous touché la Pierre de Croisée — cette grosse pierre gravée à l'entrée du village."\n\nIl vous montre une carte rudimentaire: le sentier principal, une bifurcation vers un vieux village abandonné, et plus loin, ce qui ressemble à l'entrée d'un souterrain.""",
        "choices": [
            {"text": "Prendre la carte et partir pour la forêt", "next": "lisiere_foret", "skill_check": None},
            {"text": "[Arcanes DD12] Demander des détails sur Valdris", "next": "info_valdris", "skill_check": "Arcanes", "difficulty": 12},
        ]
    },
    "info_valdris": {
        "id": "info_valdris",
        "title": "Valdris l'Ombre",
        "text": """RÉSULTAT DU JET —\n\nEn cas de succès: Votre mémoire vous revient. Valdris l'Ombre... ce nom figure dans les annales de la Guilde des Mages. Un nécromancien brillant mais fou qui cherchait à se transformer en Liche — un mort-vivant immortel de puissance immense. On pensait qu'il avait échoué dans le rituel et péri. Mais si des gens disparaissent... peut-être que le rituel n'était qu'incomplet. Peut-être qu'il a besoin d'âmes pour le compléter.\n\nEn cas d'échec: Le nom vous dit vaguement quelque chose, mais vous n'arrivez pas à le situer précisément.""",
        "choices": [
            {"text": "Partir pour la forêt, armé de ces informations", "next": "lisiere_foret", "skill_check": None},
        ]
    },
    "lisiere_foret": {
        "id": "lisiere_foret",
        "title": "La Lisière de la Forêt de Brume",
        "text": """Le sentier de terre battue s'arrête au pied d'une masse de chênes noirs. La Forêt de Brume porte bien son nom: une brume grisâtre rampe entre les troncs, s'enroulant autour de vos chevilles.\n\nLa Pierre de Croisée se dresse à votre gauche: un monolithe de granit couvert de runes gravées. À votre grande surprise, certaines runes luisent faiblement d'une lumière violette.\n\nUn sentier s'enfonce dans les ténèbres forestières. Quelque part au loin, vous croyez entendre... un gémissement?\n\nUn buisson sur votre droite frémit brusquement.""",
        "choices": [
            {"text": "[Perception DD11] Examiner la Pierre de Croisée", "next": "pierre_croisee", "skill_check": "Perception", "difficulty": 11},
            {"text": "Vous enfoncer sur le sentier principal", "next": "sentier_foret", "skill_check": None},
            {"text": "[Discrétion DD12] Approcher silencieusement du buisson", "next": "buisson", "skill_check": "Discrétion", "difficulty": 12},
        ]
    },
    "pierre_croisee": {
        "id": "pierre_croisee",
        "title": "La Pierre de Croisée",
        "text": """RÉSULTAT DU JET —\n\nEn cas de succès: Les runes racontent une histoire. "Ici se croisent les mondes des vivants et des morts. Que celui qui passe prenne garde: l'Ombre qui veille n'est jamais rassasiée." Plus bas, gravées plus récemment, des marques qui ressemblent à des noms: Pieter, Agnès, Thomas. Les disparus ont gravé leurs noms ici avant d'entrer... ou quelque chose les y a poussés.\n\nEn cas d'échec: Vous ne déchiffrez pas les runes, mais vous remarquez les noms gravés récemment.\n\nVous continuez vers la forêt avec un frisson dans le dos.""",
        "choices": [
            {"text": "Prendre le sentier principal", "next": "sentier_foret", "skill_check": None},
            {"text": "[Discrétion DD12] Approcher du buisson", "next": "buisson", "skill_check": "Discrétion", "difficulty": 12},
        ]
    },
    "buisson": {
        "id": "buisson",
        "title": "Le Buisson",
        "text": """RÉSULTAT DU JET —\n\nEn cas de succès: Vous vous approchez sans bruit et découvrez un gobelin tapi dans les feuillages, vous observant avec des yeux jaunes. Il semble... paniqué? Avant qu'il puisse s'enfuir, vous lui attrapez le bras.\n\nEn cas d'échec: Le gobelin vous entend et surgit du buisson en poussant un cri strident! Il brandit sa dague!\n\n[COMBAT]""",
        "choices": [
            {"text": "[Succès] Interroger le gobelin", "next": "gobelin_info", "skill_check": None},
            {"text": "[Échec] Combattre le gobelin", "next": "combat_gobelin", "skill_check": None, "combat": True, "monster_id": "gobelin", "win_node": "sentier_foret", "lose_node": "mort"},
        ]
    },
    "combat_gobelin": {
        "id": "combat_gobelin",
        "title": "Combat: Gobelin",
        "text": """Le gobelin se jette sur vous, sa dague crasseuse brillant dans la pénombre!""",
        "combat": True,
        "monster_id": "gobelin",
        "win_node": "sentier_foret",
        "lose_node": "mort",
        "choices": []
    },
    "gobelin_info": {
        "id": "gobelin_info",
        "title": "Le Gobelin Informateur",
        "text": """Le petit être tremble comme une feuille, mais parle — par peur de votre regard plus que par volonté.\n\n"Maître Ombre... il est revenu! Pas comme avant... différent. Mort mais vivant! Il prend les humains qui entrent — leur vole quelque chose. L'étincelle de vie! Il a presque fini son... rituel. Encore quelques âmes et il sera complet. COMPLET!"\n\nLe gobelin se tortille pour vous échapper.\n\n"Village abandonné — Valdrigard — c'est là qu'il les amène! Donnez-moi liberté? Je vous mènerai jusqu'à l'entrée du souterrain! Promis-juré!"\n\nVous devez décider si vous faites confiance à cette créature.""",
        "choices": [
            {"text": "Faire confiance au gobelin comme guide", "next": "guide_gobelin", "skill_check": None},
            {"text": "[Discrétion DD13] Le suivre de loin sans lui faire confiance", "next": "suivre_gobelin", "skill_check": "Discrétion", "difficulty": 13},
            {"text": "Refuser son aide et trouver le chemin seul", "next": "sentier_foret", "skill_check": None},
        ]
    },
    "guide_gobelin": {
        "id": "guide_gobelin",
        "title": "Le Guide Vert",
        "text": """Le gobelin, qui dit s'appeler Gripzi, vous conduit à travers des sentiers que vous n'auriez jamais trouvés seul. Il évite avec une précision étonnante les zones où d'autres gobelins patrouillent.\n\n"Maître Ombre... je travaillais pour lui. Mais il est devenu trop fou. Même nous, on n'est plus en sécurité."\n\nAprès une demi-heure de marche, vous arrivez à la lisière d'une clairière. Au centre: des ruines de pierre grise, et au fond, un escalier descendant dans les profondeurs.\n\n"Valdrigard. L'entrée du souterrain là-bas." Gripzi recule. "Je ne vais pas plus loin. Bonne chance, humain."\n\nDeux gardes zombifiés patrouillent devant l'escalier.""",
        "choices": [
            {"text": "[Discrétion DD13] Passer en silence devant les zombies", "next": "entree_donjon", "skill_check": "Discrétion", "difficulty": 13},
            {"text": "Affronter les zombies", "next": "combat_zombies", "skill_check": None, "combat": True, "monster_id": "zombie_garde", "win_node": "entree_donjon", "lose_node": "mort"},
            {"text": "[Persuasion DD18] Tenter de parler aux zombies", "next": "parler_zombies", "skill_check": "Persuasion", "difficulty": 18},
        ]
    },
    "suivre_gobelin": {
        "id": "suivre_gobelin",
        "title": "Filature",
        "text": """RÉSULTAT DU JET —\n\nEn cas de succès: Vous le suivez sans qu'il s'en rende compte, arrivant aux ruines de Valdrigard et à l'entrée du souterrain.\n\nEn cas d'échec: Le gobelin vous sème dans la forêt! Vous devez trouver le chemin par vous-même.""",
        "choices": [
            {"text": "[Succès] Vous êtes à l'entrée du souterrain", "next": "guide_gobelin", "skill_check": None},
            {"text": "[Échec] Chercher le chemin seul (Survie DD14)", "next": "sentier_foret", "skill_check": "Survie", "difficulty": 14},
        ]
    },
    "sentier_foret": {
        "id": "sentier_foret",
        "title": "Le Sentier dans la Forêt",
        "text": """Vous progressez sur le sentier. La forêt est étrangement silencieuse — pas d'oiseaux, pas d'insectes. Juste le bruit sourd de vos pas et le bruissement de la brume.\n\nLes arbres deviennent plus denses, leurs branches se rejoignant au-dessus comme des doigts entrelacés. Des toiles d'araignées d'une taille inquiétante ornent certains troncs.\n\nSoudain, le sentier se divise. À gauche, un panneau en bois brisé indique encore: "Valdrigard - 2 lieues". À droite, le sentier descend vers ce qui semble être les ruines d'un vieux moulin.\n\nUn mouvement dans les arbres au-dessus attire votre regard: une araignée de la taille d'un chien vous observe.""",
        "choices": [
            {"text": "Prendre le chemin de gauche vers Valdrigard", "next": "valdrigard", "skill_check": None},
            {"text": "Explorer le moulin en ruines", "next": "moulin", "skill_check": None},
            {"text": "Affronter l'araignée", "next": "combat_araignee", "skill_check": None, "combat": True, "monster_id": "araignee_geante", "win_node": "valdrigard", "lose_node": "mort"},
            {"text": "[Discrétion DD11] Ignorer l'araignée et passer sous elle", "next": "valdrigard", "skill_check": "Discrétion", "difficulty": 11},
        ]
    },
    "moulin": {
        "id": "moulin",
        "title": "Le Moulin en Ruines",
        "text": """Le moulin s'est effondré sur lui-même, ne laissant que trois murs et une roue brisée immergée dans un ruisseau noir. L'eau ne coule plus normalement — elle semble s'écouler... à l'envers?\n\nÀ l'intérieur des ruines, partiellement dissimulé sous une pierre, vous trouvez un sac à dos. À l'intérieur: un journal intime.\n\nLes dernières entrées lisibles: "...les lumières m'appellent. Je dois y aller. Je dois compléter le cercle. Thomas ne se souvient plus de sa famille, mais moi je... je résiste encore. Il y a une faiblesse dans le rituel. L'eau courante. La brume ne peut pas la traverser. Si quelqu'un trouve ceci..."\n\nLe reste est illisible, maculé de ce qui ressemble à de l'encre violette.\n\nVous avez trouvé un indice crucial sur la faiblesse de Valdris!""",
        "choices": [
            {"text": "Prendre le journal et partir vers Valdrigard", "next": "valdrigard", "skill_check": None},
        ]
    },
    "valdrigard": {
        "id": "valdrigard",
        "title": "Le Village Maudit de Valdrigard",
        "text": """Les ruines de Valdrigard surgissent de la brume: une dizaine de bâtiments de pierre noircie, des rues pavées envahies par des herbes mortes. Au centre du village, une fontaine sèche.\n\nEt au fond, bien visible: un escalier de pierre descendant sous une tour en ruines. Des torches violettes éclairent l'entrée.\n\nMais vous n'êtes pas seuls. Deux gardes — ou ce qui en reste — patrouillent. Ils se déplacent mécaniquement, les yeux vides. Des zombies, d'anciens gardes du village.\n\nDans une maison sur votre gauche, vous entendez un gémissement. Un des disparus?""",
        "choices": [
            {"text": "Secourir la personne dans la maison d'abord", "next": "rescapee", "skill_check": None},
            {"text": "[Discrétion DD13] Contourner les zombies et entrer dans le donjon", "next": "entree_donjon", "skill_check": "Discrétion", "difficulty": 13},
            {"text": "Affronter les zombies gardiens", "next": "combat_zombies", "skill_check": None, "combat": True, "monster_id": "zombie_garde", "win_node": "entree_donjon", "lose_node": "mort"},
        ]
    },
    "rescapee": {
        "id": "rescapee",
        "title": "La Rescapée",
        "text": """Dans la maison, recroquevillée dans un coin, vous trouvez une jeune femme: Agnès, l'une des disparus. Elle est pâle, les yeux creusés, mais lucide.\n\n"Vous... vous êtes réel? Pas une vision?"\n\nElle vous raconte en chuchotant: Valdris est une Liche, presque complète. Il lui manque encore une âme pour finaliser sa transformation. Les deux autres disparus — Pieter et Thomas — sont déjà dans le donjon, entransés.\n\n"Il y a... une chambre au fond du donjon. C'est là qu'il fait le rituel. Mais j'ai entendu les gardes parler. Son phylactère — l'objet qui contient son âme — est dans une boîte de cristal dans la salle du trône. Détruisez ça, et il mourra vraiment."\n\nAgnès vous donne une fiole de potion de soins (2d4+2 HP) qu'elle avait cachée dans sa botte.\n\n*Vous gagnez: Potion de Soins x1*""",
        "choices": [
            {"text": "Laisser Agnès ici et entrer dans le donjon", "next": "entree_donjon", "skill_check": None},
            {"text": "Convaincre Agnès de venir avec vous pour guider", "next": "entree_donjon_guide", "skill_check": None},
        ]
    },
    "parler_zombies": {
        "id": "parler_zombies",
        "title": "Parler aux Morts",
        "text": """RÉSULTAT DU JET —\n\nEn cas de succès: Impossible mais... quelque chose dans votre voix ou vos mots résonne avec ce qui reste de leur conscience. Les zombies s'écartent lentement. Vous passez.\n\nEn cas d'échec: Les zombies ne réagissent pas à vos mots. Ils attaquent.""",
        "choices": [
            {"text": "[Succès] Entrer dans le donjon", "next": "entree_donjon", "skill_check": None},
            {"text": "[Échec] Combattre les zombies", "next": "combat_zombies", "skill_check": None, "combat": True, "monster_id": "zombie_garde", "win_node": "entree_donjon", "lose_node": "mort"},
        ]
    },
    "combat_zombies": {
        "id": "combat_zombies",
        "title": "Combat: Gardes Zombifiés",
        "text": """Les morts-vivants se tournent vers vous, les bras tendus!""",
        "combat": True,
        "monster_id": "zombie_garde",
        "win_node": "entree_donjon",
        "lose_node": "mort",
        "choices": []
    },
    "entree_donjon": {
        "id": "entree_donjon",
        "title": "L'Entrée du Souterrain",
        "text": """L'escalier descend en spirale sur vingt mètres dans les entrailles de la terre. La pierre suinte d'humidité, et des inscriptions nécromanciennes couvrent les murs. Les torches violettes ne brûlent rien — elles flottent simplement dans l'air.\n\nAu bas de l'escalier, un couloir se divise:\n- À gauche: une porte de fer derrière laquelle vous entendez des voix humaines faibles.\n- À droite: un couloir bien éclairé menant vers une grande salle d'où émane une puissante énergie magique.\n\nVous sentez la présence de quelque chose d'immense et d'ancien.""",
        "choices": [
            {"text": "Aller à gauche libérer les prisonniers", "next": "prisonniers", "skill_check": None},
            {"text": "Aller à droite affronter Valdris directement", "next": "salle_valdris", "skill_check": None},
            {"text": "[Investigation DD14] Chercher un passage secret", "next": "passage_secret", "skill_check": "Investigation", "difficulty": 14},
        ]
    },
    "entree_donjon_guide": {
        "id": "entree_donjon_guide",
        "title": "L'Entrée du Souterrain — avec Agnès",
        "text": """Agnès vous guide à travers le souterrain, connaissant les patrouilles. Grâce à elle, vous évitez deux gardes supplémentaires et arrivez directement devant la salle de Valdris.\n\n"Voilà," chuchote-t-elle. "Son phylactère est dans une boîte de cristal violette sur le trône. Détruisez-la avant de le tuer, sinon il se régénère."\n\nElle recule dans l'ombre. "Je vous attends ici. Bonne chance."\n\nVous entendez une voix caverneuse derrière la porte: "Je... sais... que vous êtes là."\n\n*Vous êtes en position avantageuse: +2 à votre premier jet d'attaque*""",
        "choices": [
            {"text": "Entrer dans la salle de Valdris", "next": "salle_valdris", "skill_check": None},
        ]
    },
    "prisonniers": {
        "id": "prisonniers",
        "title": "La Cellule des Prisonniers",
        "text": """La porte de fer grince. À l'intérieur, dans une cellule de pierre, deux hommes sont assis en trance, les yeux ouverts mais vides. Pieter et Thomas.\n\nVous tentez de les réveiller. Rien. Leur esprit est... ailleurs. Lié à Valdris.\n\nMais en fouillant la cellule, vous trouvez quelque chose d'utile: une vieille épée accrochée au mur, avec une lame qui brille d'une faible lumière bleue. Une inscription: "Lame-Âme — bannit les non-morts."\n\n*Vous trouvez: Lame-Âme (1d8+2, +1d6 dégâts sacrés vs morts-vivants)*\n\nLes prisonniers ne peuvent pas être sauvés tant que Valdris vit.""",
        "choices": [
            {"text": "Prendre la Lame-Âme et affronter Valdris", "next": "salle_valdris", "skill_check": None},
        ]
    },
    "passage_secret": {
        "id": "passage_secret",
        "title": "Le Passage Secret",
        "text": """RÉSULTAT DU JET —\n\nEn cas de succès: Votre oeil exercé repère une pierre légèrement différente des autres. Elle pivote, révélant un passage étroit menant directement derrière le trône de Valdris. Vous pouvez l'attaquer par surprise.\n\n*Bonus: Attaque surprise au premier tour (+4 attaque, dégâts automatiquement doublés)*\n\nEn cas d'échec: Vous ne trouvez rien. Vous devez passer par l'entrée principale.""",
        "choices": [
            {"text": "[Succès] Emprunter le passage secret", "next": "salle_valdris", "skill_check": None},
            {"text": "[Échec] Prendre le couloir principal", "next": "salle_valdris", "skill_check": None},
        ]
    },
    "salle_valdris": {
        "id": "salle_valdris",
        "title": "La Salle du Trône — Valdris l'Ombre",
        "text": """La salle circulaire est vaste, éclairée par des torches violettes et des runes qui pulsent sur le sol. Des ossements humains décorent les murs comme des ornements.\n\nSur un trône de pierre noire est assis ce qui fut autrefois un homme: Valdris l'Ombre. Une silhouette desséchée en robes déchirées, les orbites brillant d'une lumière violette sinistre. Sur le trône à côté de lui: une boîte de cristal dans laquelle une lumière dorée tourne lentement. Son phylactère.\n\n"Ah... un visiteur." Sa voix est le bruit de pierre qui grince. "Il y a si longtemps que je n'ai pas eu de la... compagnie vivante. Vous êtes arrivé juste à temps pour être mon dernier ingrédient."\n\nIl se lève. La température chute brutalement de dix degrés.\n\n"Votre âme... sera la dernière. Et mon ascension sera complète."\n\nLe combat pour la survie du village commence.""",
        "choices": [
            {"text": "AFFRONTER VALDRIS LA LICHE", "next": "combat_liche", "skill_check": None, "combat": True, "monster_id": "liche", "win_node": "victoire", "lose_node": "mort"},
        ]
    },
    "combat_liche": {
        "id": "combat_liche",
        "title": "Combat Final: Valdris l'Ombre",
        "text": """Valdris lève la main et une onde de ténèbres se propage vers vous!""",
        "combat": True,
        "monster_id": "liche",
        "win_node": "victoire",
        "lose_node": "mort",
        "choices": []
    },
    "victoire": {
        "id": "victoire",
        "title": "VICTOIRE — L'Ombre Dissipée",
        "text": """Valdris s'effondre avec un cri qui fait trembler les murs de pierre. Son corps se désintègre en cendres violettes qui se dissipent dans l'air.\n\nSimultanément, une lumière dorée explose de la boîte de cristal — le phylactère brisé libère les âmes captives. Dans la cellule, vous entendez Pieter et Thomas s'éveiller avec des cris de confusion.\n\nLa forêt, dehors, commence à changer. La brume se lève. Les arbres retrouvent leur couleur naturelle. Des oiseaux, timidement, reprennent leur chant.\n\nVous sortez du donjon avec les survivants. Agnès pleure de joie. Pieter et Thomas sont désorientés mais en vie.\n\nÀ votre retour à Piedval, Bertrand tient sa promesse — et double même la somme: 400 pièces d'or. Un festin est organisé en votre honneur.\n\n*Vous avez sauvé le village de Piedval.*\n*Valdris l'Ombre est définitivement vaincu.*\n*+500 XP — +400 pièces d'or*\n\n═══════════════════════════\n★  VICTOIRE — FIN NORMALE  ★\n═══════════════════════════\n\nMerci d'avoir joué !""",
        "choices": [
            {"text": "Rejouer une nouvelle aventure", "next": "start", "skill_check": None},
        ]
    },
    "mort": {
        "id": "mort",
        "title": "MORT — Votre Aventure Prend Fin",
        "text": """L'obscurité vous engloutit. Vos forces vous abandonnent.\n\nDans votre dernier souffle, vous entendez la voix de Valdris résonner dans votre tête: "Encore une âme pour mon rituel... Merci, aventurier."\n\nLe village de Piedval attend toujours un sauveur...\n\n═══════════════════════════════\n💀  MORT — FIN TRAGIQUE  💀\n═══════════════════════════════""",
        "choices": [
            {"text": "Recommencer l'aventure", "next": "start", "skill_check": None},
        ]
    }
}
