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
            {"text": "⚔ Chapitre II — Les Terres Maudites (niveau 5 requis)", "next": "chapitre2_intro", "skill_check": None},
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
    },
    "academie_intro": {
        "id": "academie_intro",
        "title": "L'Académie d'Arcane",
        "text": """La tour de pierre grise s'élève sur cinq étages au milieu d'une clairière. Des runes bleues pulsent sur ses murs extérieurs. L'air autour sent l'ozone et quelque chose d'indéfinissable — comme si la réalité elle-même était légèrement différente ici.

L'archimage Sorel vous reçoit dans son bureau encombré de grimoires. Un homme d'âge indéfini, aux yeux gris comme la pierre, qui parle avec une précision chirurgicale.

"Un grimoire a été volé de notre bibliothèque il y a trois siècles. Le Grimoire des Morts, écrit par Valdris lui-même avant sa transformation. Il contient le rituel complet de création d'une Liche — et surtout, la méthode pour la détruire définitivement. Je crois qu'il se trouve toujours dans les ruines de Valdrigard."

Il marque une pause.

"Ramenez-le moi. En échange, je vous enseignerai un sort que peu de vivants connaissent." """,
        "choices": [
            {"text": "Accepter la mission de l'archimage", "next": "start", "skill_check": None},
            {"text": "[Arcanes DD14] Demander à voir d'autres grimoires sur Valdris", "next": "academie_recherche", "skill_check": "Arcanes", "difficulty": 14},
        ]
    },
    "academie_recherche": {
        "id": "academie_recherche",
        "title": "Recherches à l'Académie",
        "text": """RÉSULTAT DU JET —

En cas de succès: Dans les archives de l'académie, vous trouvez des notes marginales fascinantes. Valdris avait une fille — Seraphine — qui a fondé le Temple du Soleil pour contrer les œuvres de son père. Elle a peut-être laissé des indices sur comment le vaincre. De plus, vous découvrez que le phylactère de Valdris n'est pas seulement détruire — il doit être détruit avec de l'Eau Bénite.

En cas d'échec: Les archives sont trop complexes pour vous. Vous repartez sans information supplémentaire.""",
        "choices": [
            {"text": "Partir avec ces informations précieuses", "next": "start", "skill_check": None},
        ]
    },
    "port_intro": {
        "id": "port_intro",
        "title": "Port-Calme — Village de Pêcheurs",
        "text": """Port-Calme est un modeste village de pêcheurs au bord du grand fleuve. Normalement paisible, il est maintenant habité par la peur. Des filets déchirés sèchent sur les quais. Trois bateaux coulés sont visibles, à moitié immergés près de la rive.

La capitaine Ondine, une femme robuste aux bras couverts de cicatrices, vous montre les dégâts.

"Ça a commencé il y a un mois. La nuit, quelque chose attaque les bateaux. On n'a retrouvé aucun corps. Juste des planches brisées et des ancres tordues comme si c'était de la cire."

Elle vous tend un collier en os de poisson.

"La vieille Baba Morvaine prétend que ça vient d'une créature contrôlée par quelqu'un. Pas d'une bête sauvage. Allez la voir avant de vous aventurer sur le fleuve." """,
        "choices": [
            {"text": "Aller voir Baba Morvaine", "next": "baba_morvaine", "skill_check": None},
            {"text": "[Perception DD13] Examiner les dégâts sur les bateaux", "next": "bateaux_examines", "skill_check": "Perception", "difficulty": 13},
        ]
    },
    "baba_morvaine": {
        "id": "baba_morvaine",
        "title": "Baba Morvaine",
        "text": """La vieille femme vit dans une cabane au bord du fleuve, entourée d'herbes séchées et de bocaux de substances indéfinissables. Elle vous attendait.

"Je te voyais venir depuis hier. Assieds-toi."

Elle dépose devant vous un bocal d'herbes verdâtres.

"La créature n'est pas naturelle. Quelqu'un la guide. Quelqu'un qui vit sous l'eau depuis longtemps — un ancien noyé revenu. Il porte un anneau de contrôle. Détruis l'anneau, la créature est libre. Elle partira d'elle-même."

Elle vous tend le bocal.

"Cette herbe, brûlée sur l'eau, révèle ce qui est invisible. Tu trouveras l'entrée sous le vieux moulin à eau au nord du village."

*Vous obtenez: Herbes de Révélation*""",
        "choices": [
            {"text": "Remercier Baba Morvaine et explorer le fleuve", "next": "start", "skill_check": None},
        ]
    },
    "bateaux_examines": {
        "id": "bateaux_examines",
        "title": "Les Bateaux Endommagés",
        "text": """RÉSULTAT DU JET —

En cas de succès: Les marques sur les bois brisés sont régulières, presque géométriques. Pas des griffes d'animal — des impacts calculés, comme si la créature avait reçu des instructions précises sur où frapper pour couler le bateau le plus vite. Et dans la vase du fond, partiellement dissimulé: un symbole gravé. Un symbole nécromantique que vous reconnaissez — le même que ceux des ruines de Valdrigard.

En cas d'échec: Vous ne voyez que des dégâts standard, impossible de déterminer la cause précise.""",
        "choices": [
            {"text": "Rapporter à la capitaine Ondine", "next": "start", "skill_check": None},
        ]
    },
    "mine_intro": {
        "id": "mine_intro",
        "title": "Mine Abandonnée — Repaire de Bandits",
        "text": """L'entrée de l'ancienne mine est dissimulée sous des ronces et des planches clouées. Mais les marques de passage sont récentes — boue piétinée, mégots de torches.

À l'intérieur, des voix. Une douzaine au moins. Des bandits armés jusqu'aux dents ont fait de cet endroit leur forteresse souterraine.

Au fond de la mine principale, sur un trône improvisé de caisses empilées, trône Korr le Trancheur — un colosse d'un mètre quatre-vingt-dix portant deux haches croisées dans le dos. À ses côtés, attachée à un pilier: une jeune femme aux vêtements de noble. La fille du seigneur Aldrath, sans doute.

Korr vous repère et sourit. Ce n'est pas un sourire aimable.

"Un aventurier tout seul. Quelle chance pour nous." """,
        "choices": [
            {"text": "[Discrétion DD15] Tenter de libérer l'otage sans combattre", "next": "mine_furtif", "skill_check": "Discrétion", "difficulty": 15},
            {"text": "Affronter Korr et ses hommes", "next": "start", "skill_check": None, "combat": True, "monster_id": "bandit", "win_node": "mine_victoire", "lose_node": "mort"},
            {"text": "[Persuasion DD16] Proposer une rançon à Korr", "next": "mine_negociation", "skill_check": "Persuasion", "difficulty": 16},
        ]
    },
    "mine_furtif": {
        "id": "mine_furtif",
        "title": "Infiltration de la Mine",
        "text": """RÉSULTAT DU JET —

En cas de succès: Vous vous glissez dans les ombres avec une aisance remarquable, évitant les patrouilles, déjouant les gardes. Vous atteignez l'otage, coupez ses liens, et ressortez par un tunnel secondaire que les bandits ont négligé de surveiller. Elle s'appelle Elise. Elle tremble mais est indemne. Korr ne découvrira votre passage que bien après votre départ.

En cas d'échec: Un garde vous repère! L'alarme est donnée!""",
        "choices": [
            {"text": "[Succès] Partir avec Elise vers Piedval", "next": "mine_victoire", "skill_check": None},
            {"text": "[Échec] Combattre pour s'échapper", "next": "start", "skill_check": None, "combat": True, "monster_id": "bandit", "win_node": "mine_victoire", "lose_node": "mort"},
        ]
    },
    "mine_negociation": {
        "id": "mine_negociation",
        "title": "Négocier avec Korr",
        "text": """RÉSULTAT DU JET —

En cas de succès: Korr réfléchit. Votre offre — une somme en or et l'assurance que vous ne révélerez pas leur position aux autorités — l'intéresse. Il crache par terre et fait signe à ses hommes de libérer l'otage. "Allez. Et j'espère ne plus vous revoir."

En cas d'échec: "Une rançon? Tu me prends pour un idiot?" Korr dégaine ses haches.""",
        "choices": [
            {"text": "[Succès] Partir avec l'otage", "next": "mine_victoire", "skill_check": None},
            {"text": "[Échec] Combattre", "next": "start", "skill_check": None, "combat": True, "monster_id": "bandit", "win_node": "mine_victoire", "lose_node": "mort"},
        ]
    },
    "mine_victoire": {
        "id": "mine_victoire",
        "title": "Elise Libérée",
        "text": """Elise Aldrath retrouve ses esprits une fois à l'air libre. Une jeune femme d'une vingtaine d'années, les yeux clairs, qui vous remercie avec une dignité touchante malgré ses vêtements déchirés.

"Mon père vous récompensera. Il n'a plus grand-chose, mais il vous offre l'Épée d'Aldrath — une lame qui se transmet dans notre famille depuis deux cents ans."

De retour à Piedval, le vieux seigneur vous embrasse avec des larmes dans les yeux et vous remet une magnifique épée longue à la garde ornée d'un aigle gravé.

*Épée d'Aldrath obtenue: 1d10+2, +1d4 dégâts sacrés*
*+600 XP — Quête accomplie*""",
        "choices": [
            {"text": "Reprendre l'aventure", "next": "start", "skill_check": None},
        ]
    },
    "necropole_intro": {
        "id": "necropole_intro",
        "title": "La Nécropole Ancienne",
        "text": """La Nécropole s'étend sur plusieurs hectares: rangées de tombes brisées, mausolées effondrés, monuments funèbres à demi-effacés. Des noms illisibles sur des pierres mangées par la mousse.

La nuit est tombée sans que vous vous en rendiez compte. Une brume naturelle — vraiment naturelle, celle-ci — rampe entre les tombes.

Et puis vous les voyez. Des silhouettes qui bougent. Des squelettes armés d'épées rouillées, des zombies traînant les pieds. Pas beaucoup — cinq, peut-être six. Mais il y en a sûrement plus.

Au fond de la nécropole, une crypte centrale plus imposante. Une lumière violette filtre sous sa porte de pierre.""",
        "choices": [
            {"text": "[Discrétion DD12] Atteindre la crypte centrale sans combattre", "next": "crypte_centrale", "skill_check": "Discrétion", "difficulty": 12},
            {"text": "Affronter les morts-vivants", "next": "start", "skill_check": None, "combat": True, "monster_id": "squelette", "win_node": "crypte_centrale", "lose_node": "mort"},
            {"text": "[Religion DD13] Invoquer la lumière divine pour les disperser", "next": "dispersion_divine", "skill_check": "Religion", "difficulty": 13},
        ]
    },
    "dispersion_divine": {
        "id": "dispersion_divine",
        "title": "Renvoi des Morts-Vivants",
        "text": """RÉSULTAT DU JET —

En cas de succès: Vous levez votre symbole sacré (ou improvisez un geste de foi) et criez une prière. Une lumière dorée émane de vos mains. Les morts-vivants reculent, leurs os craquant sous la pression divine. Ils battent en retraite dans les ombres. Le chemin vers la crypte centrale est libre.

En cas d'échec: Rien ne se passe. Ou pire — les morts-vivants semblent attirés par votre tentative.""",
        "choices": [
            {"text": "[Succès] Avancer vers la crypte centrale", "next": "crypte_centrale", "skill_check": None},
            {"text": "[Échec] Combattre", "next": "start", "skill_check": None, "combat": True, "monster_id": "squelette", "win_node": "crypte_centrale", "lose_node": "mort"},
        ]
    },
    "crypte_centrale": {
        "id": "crypte_centrale",
        "title": "La Crypte Centrale",
        "text": """L'intérieur de la crypte est étonnamment bien préservé. Des fresques sur les murs montrent des scènes de bataille — une armée de morts-vivants marchant contre des villes vivantes. Pas une décoration: une prophétie, peut-être.

Au centre, dans un sarcophage ouvert: rien. Mais sur le couvercle, une inscription en vieux commun que vous déchiffrez laborieusement:

"Ici reposait Valdris-Premier, fondateur de la lignée des nécromanciens. Son secret le plus précieux est dans la boîte de cristal — et la boîte ne peut être détruite que par le feu de son propre sang."

À côté du sarcophage: un coffre de fer. Fermé à clé.

*+200 XP pour avoir atteint la crypte centrale*""",
        "choices": [
            {"text": "[Crochetage DD14] Crocheter le coffre", "next": "coffre_ouvert", "skill_check": "Vol à la Tire", "difficulty": 14},
            {"text": "[Force DD16] Forcer le coffre", "next": "coffre_force", "skill_check": "Athlétisme", "difficulty": 16},
            {"text": "Repartir avec les informations sur Valdris", "next": "start", "skill_check": None},
        ]
    },
    "coffre_ouvert": {
        "id": "coffre_ouvert",
        "title": "Le Coffre Ouvert",
        "text": """RÉSULTAT DU JET —

En cas de succès: Le mécanisme cède sous vos doigts experts. À l'intérieur: 150 pièces d'or anciennes, un anneau d'argent gravé de runes (Anneau de Protection +2, +2 CA), et un parchemin qui confirme que le feu d'une torche bénie peut détruire le phylactère de Valdris.

En cas d'échec: Le mécanisme résiste. Vous n'arrivez pas à l'ouvrir.""",
        "choices": [
            {"text": "[Succès] Prendre le contenu et repartir", "next": "start", "skill_check": None},
            {"text": "[Échec] Repartir sans le coffre", "next": "start", "skill_check": None},
        ]
    },
    "coffre_force": {
        "id": "coffre_force",
        "title": "Force Brute",
        "text": """RÉSULTAT DU JET —

En cas de succès: Vos muscles bandés, vous arrachez littéralement le couvercle du coffre dans un fracas métallique. Dedans: 150 pièces d'or, un anneau de protection et un parchemin important. Le bruit a cependant réveillé des morts-vivants supplémentaires.

En cas d'échec: Le coffre ne cède pas. Vos mains sont meurtries.""",
        "choices": [
            {"text": "[Succès] Prendre le butin et fuir rapidement", "next": "start", "skill_check": None},
            {"text": "[Échec] Repartir bredouille", "next": "start", "skill_check": None},
        ]
    },

    # ═══════════════════════════════════════════════════
    # CHAPITRE II — LES TERRES MAUDITES
    # ═══════════════════════════════════════════════════

    "chapitre2_intro": {
        "id": "chapitre2_intro",
        "title": "CHAPITRE II — Les Terres Maudites",
        "text": """Trois semaines après la chute de Valdris, l'Archimage Sorel vous convoque en urgence à l'Académie d'Arcane. Son visage, habituellement impassible, trahit une inquiétude rare.

"Ce que nous pensions être une simple anomalie... c'est bien pire." Il déroule une carte sur sa table. "Au nord-ouest, dans les terres autrefois habitées, quelque chose s'est éveillé. Un portail démoniaque. Des éclaireurs ont rapporté des colonnes de fumée noire et des créatures ailées survolant la région."

Il pose un cristal rouge pulsant devant vous.

"J'ai analysé les émanations. Ce portail est maintenu ouvert par trois Pierres d'Ancrage plantées dans le sol à distance égale. Détruisez-les toutes les trois, et le portail se referme. Mais attention..."

Il baisse la voix.

"Il y a un Seigneur Démon de l'autre côté. S'il passe avant que vous n'ayez détruit les pierres, ce monde est condamné."

*Nouvelle quête: Le Portail Infernal*
*Objectif: Détruire les 3 Pierres d'Ancrage et vaincre le Seigneur Démon*""",
        "choices": [
            {"text": "Accepter la mission et partir pour les Terres Maudites", "next": "terres_maudites_arrive", "skill_check": None},
            {"text": "[Arcanes DD13] Demander des détails sur les Pierres d'Ancrage", "next": "sorel_portail", "skill_check": "Arcanes", "difficulty": 13},
            {"text": "Demander une récompense supplémentaire", "next": "preparation_ch2", "skill_check": None},
        ]
    },
    "sorel_portail": {
        "id": "sorel_portail",
        "title": "Les Secrets du Portail",
        "text": """RÉSULTAT DU JET —

En cas de succès: Votre connaissance des arcanes vous permet de comprendre instantanément. Les Pierres d'Ancrage sont des fragments de la Rune d'Ouverture — des reliques démoniaques forgées dans le feu de l'Enfer même. Elles ne peuvent être détruites que par un coup physique puissant sur leur surface, ou par un sort de Dissipation de Magie. Une fois les trois détruites, le portail se déstabilise et toute créature à moitié engagée dans le passage... est coupée en deux.

En cas d'échec: L'explication de Sorel vous dépasse légèrement. Vous retenez l'essentiel: détruisez les pierres, fermez le portail.""",
        "choices": [
            {"text": "Partir en mission", "next": "terres_maudites_arrive", "skill_check": None},
        ]
    },
    "preparation_ch2": {
        "id": "preparation_ch2",
        "title": "Préparatifs",
        "text": """Sorel soupire mais acquiesce.

"L'Académie vous accordera... 500 pièces d'or en avance, et 1000 supplémentaires si vous réussissez. Plus le droit d'accéder à notre bibliothèque de sorts pendant un mois."

Il ajoute, plus sombre:

"Si vous échouez, l'argent ne vous servira de toute façon plus à rien."

Lyra, l'apprentie, vous prend à part discrètement.

"Emportez des Potions de Soins. Beaucoup. Et si vous avez de l'Eau Bénite, les démons y sont particulièrement sensibles. Mon maître ne vous l'a pas dit, mais les Pierres d'Ancrage brillent en rouge — vous ne pouvez pas les rater."

*+500 pièces d'or (avance)*""",
        "choices": [
            {"text": "Remercier Lyra et partir pour les Terres Maudites", "next": "terres_maudites_arrive", "skill_check": None},
        ]
    },
    "terres_maudites_arrive": {
        "id": "terres_maudites_arrive",
        "title": "Les Terres Maudites",
        "text": """Vous arrivez aux Terres Maudites au crépuscule — ce qui était autrefois une forêt verdoyante est maintenant une plaine calcinée. La terre est noire et fissurée, des flammes basses brûlent sans combustible apparent, et l'air pue le soufre et la cendre.

Au loin, le portail: une déchirure dans la réalité, grande comme une maison, bordée de runes écarlates. À travers, on devine des formes qui bougent. Des rires graves et caverneux résonnent.

Autour du portail, à distance régulière, trois rochers rougeoyants pulsent d'une lumière sinistre. Les Pierres d'Ancrage.

Des démons gardiens patrouillent entre les pierres. Pas nombreux — quatre, peut-être cinq — mais chacun est aussi grand qu'un cheval et armé de griffes acérées.

Le sol tremble légèrement. Depuis le portail, une voix grave gronde en langue infernale.""",
        "choices": [
            {"text": "[Discrétion DD14] Approcher la première pierre en secret", "next": "pierre_ancrage1", "skill_check": "Discrétion", "difficulty": 14},
            {"text": "Affronter les démons gardiens de front", "next": "combat_demon1", "skill_check": None, "combat": True, "monster_id": "demon_gardien", "win_node": "pierre_ancrage1", "lose_node": "mort_ch2"},
            {"text": "[Perception DD12] Observer le terrain et les démons", "next": "observer_demons", "skill_check": "Perception", "difficulty": 12},
        ]
    },
    "observer_demons": {
        "id": "observer_demons",
        "title": "Observation Tactique",
        "text": """RÉSULTAT DU JET —

En cas de succès: En observant attentivement, vous notez quelque chose d'important: les démons gardiens ont un angle mort — côté nord. Ils tournent le dos à la première pierre pendant exactement dix secondes à chaque rotation. De plus, leur peau semble sensible à la lumière directe du soleil — ils évitent systématiquement les zones éclairées. Avec cette information, approcher les pierres devrait être plus facile.

En cas d'échec: Les démons patrouillent de manière imprévisible. Vous ne trouvez pas de schéma exploitable.""",
        "choices": [
            {"text": "[Succès] Exploiter l'angle mort pour s'approcher", "next": "pierre_ancrage1", "skill_check": None},
            {"text": "[Échec] Tenter quand même", "next": "combat_demon1", "skill_check": None, "combat": True, "monster_id": "demon_gardien", "win_node": "pierre_ancrage1", "lose_node": "mort_ch2"},
        ]
    },
    "combat_demon1": {
        "id": "combat_demon1",
        "title": "Démon Gardien",
        "text": """Un démon vous fonce dessus, ses ailes membraneuses déployées, la gueule grande ouverte sur des rangées de dents noires!""",
        "combat": True,
        "monster_id": "demon_gardien",
        "win_node": "pierre_ancrage1",
        "lose_node": "mort_ch2",
        "choices": []
    },
    "pierre_ancrage1": {
        "id": "pierre_ancrage1",
        "title": "Première Pierre d'Ancrage",
        "text": """Vous atteignez la première Pierre d'Ancrage. De près, c'est impressionnant: un rocher de granit noir de la taille d'un homme, parcouru de veines de lave qui pulsent comme un cœur. Des runes démoniaques sont gravées profondément dans sa surface.

La chaleur qui en émane est intense. La tenir suffit à faire rougir la peau.

Comment la détruire?""",
        "choices": [
            {"text": "[Force DD15] La fracasser avec votre arme", "next": "pierre_detruite1", "skill_check": "Athlétisme", "difficulty": 15},
            {"text": "[Arcanes DD13] Lancer un sort de Dissipation", "next": "pierre_detruite1", "skill_check": "Arcanes", "difficulty": 13},
            {"text": "Frapper de toutes vos forces sans jet", "next": "pierre_tentative1", "skill_check": None},
        ]
    },
    "pierre_tentative1": {
        "id": "pierre_tentative1",
        "title": "Coup Puissant",
        "text": """Vous frappez la pierre de toutes vos forces. Des éclats volent, les runes craquellent... mais la pierre tient bon.

Votre attaque prend -5 PV de dégâts de contrecoup (chaleur infernale).

Cependant, vous avez affaibli la pierre. Un deuxième coup plus précis pourrait suffire.""",
        "choices": [
            {"text": "[Force DD10] Frapper à nouveau sur les fissures", "next": "pierre_detruite1", "skill_check": "Athlétisme", "difficulty": 10},
        ]
    },
    "pierre_detruite1": {
        "id": "pierre_detruite1",
        "title": "Première Pierre Détruite",
        "text": """RÉSULTAT DU JET —

En cas de succès: La pierre explose dans une gerbe d'éclats rougeoyants. Un hurlement démoniaque retentit depuis le portail — le Seigneur Démon a senti la perte. Le portail vacille légèrement.

Une pierre sur trois. Vous regardez vers les deux autres.

*+500 XP — 1/3 Pierres détruites*

En cas d'échec: Votre tentative échoue. Mais la pierre est fissurée — réessayez avec plus de force ou un sort.""",
        "choices": [
            {"text": "[Succès] Avancer vers la deuxième pierre", "next": "infiltration_ch2", "skill_check": None},
            {"text": "[Échec] Réessayer différemment", "next": "pierre_ancrage1", "skill_check": None},
        ]
    },
    "infiltration_ch2": {
        "id": "infiltration_ch2",
        "title": "Vers la Deuxième Pierre",
        "text": """L'explosion de la première pierre a alerté les démons. Ils convergent vers l'emplacement de la pierre détruite — vous avez quelques secondes pour vous repositionner.

La deuxième pierre d'ancrage brille au loin, gardée par deux démons plus grands que les autres. L'un d'eux porte une armure de métal sombre.

La troisième pierre, encore plus loin, est directement sous le portail.

Le sol tremble à nouveau. Depuis l'ouverture dimensionnelle, une silhouette massive commence à s'approcher de ce côté du portail. Il vous reste peu de temps.""",
        "choices": [
            {"text": "Foncer sur la deuxième pierre", "next": "combat_demon2", "skill_check": None, "combat": True, "monster_id": "demon_gardien", "win_node": "pierre_ancrage2", "lose_node": "mort_ch2"},
            {"text": "[Discrétion DD15] Passer en esquivant les démons", "next": "pierre_ancrage2", "skill_check": "Discrétion", "difficulty": 15},
        ]
    },
    "pierre_ancrage2": {
        "id": "pierre_ancrage2",
        "title": "Deuxième Pierre d'Ancrage",
        "text": """La deuxième pierre est plus grande que la première, et ses runes brillent plus intensément. Une chaleur oppressante l'entoure — et vous remarquez quelque chose de nouveau: des chaînes spectrales relient cette pierre au portail, comme des tendons qui maintiennent une porte ouverte.

Si vous détruisez cette pierre, le portail commencera à se fermer. Ce qui signifie que tout ce qui est à moitié de l'autre côté...

Vous entendez derrière vous le fracas d'un pas qui fait trembler la terre. Le Seigneur Démon emerge du portail.""",
        "choices": [
            {"text": "[Arcanes DD14] Dissiper les chaînes spectrales d'abord", "next": "sort_pierre2", "skill_check": "Arcanes", "difficulty": 14},
            {"text": "[Force DD16] Tout casser d'un coup puissant", "next": "pierre_detruite2", "skill_check": "Athlétisme", "difficulty": 16},
            {"text": "Frapper la pierre directement", "next": "pierre_detruite2", "skill_check": "Athlétisme", "difficulty": 14},
        ]
    },
    "sort_pierre2": {
        "id": "sort_pierre2",
        "title": "Dissipation des Chaînes",
        "text": """RÉSULTAT DU JET —

En cas de succès: Vos mains canalisent l'énergie arcanique. Les chaînes spectrales craquellent, s'effritent, et disparaissent dans un éclat de lumière blanche. La pierre, privée de son soutien dimensionnel, est maintenant vulnérable. Un simple coup suffira.

En cas d'échec: Les chaînes résistent à votre sort. Il faudra les casser de force.""",
        "choices": [
            {"text": "[Succès] Détruire la pierre affaiblie", "next": "pierre_detruite2", "skill_check": "Athlétisme", "difficulty": 10},
            {"text": "[Échec] Forcer la destruction quand même", "next": "pierre_detruite2", "skill_check": "Athlétisme", "difficulty": 16},
        ]
    },
    "pierre_detruite2": {
        "id": "pierre_detruite2",
        "title": "Deuxième Pierre Détruite",
        "text": """RÉSULTAT DU JET —

En cas de succès: La pierre explose avec une force double — les chaînes spectrales se brisent en une cascade d'étincelles bleues. Le portail rétrécit de moitié, et un rugissement de fureur démoniaque fait vibrer l'air.

Mais le Seigneur Démon est maintenant complètement sorti du portail. Une masse de muscles rouges et de cornes noires, tenant un trident enflammé. Il vous fixe avec des yeux qui brûlent comme des braises.

"Tu oses... MORTEL!" Sa voix est un tremblement de terre.

*+800 XP — 2/3 Pierres détruites*

En cas d'échec: La pierre résiste. Mais le Seigneur Démon approche — pas le temps de réessayer.""",
        "choices": [
            {"text": "[Succès] Courir vers la troisième pierre avant que le démon n'arrive", "next": "pierre_finale", "skill_check": None},
            {"text": "[Échec / urgence] Affronter le Seigneur Démon", "next": "combat_final_ch2", "skill_check": None, "combat": True, "monster_id": "seigneur_demon", "win_node": "victoire_ch2", "lose_node": "mort_ch2"},
        ]
    },
    "pierre_finale": {
        "id": "pierre_finale",
        "title": "La Troisième Pierre — Sous le Portail",
        "text": """La troisième pierre est juste sous le portail qui se referme. Elle vibre intensément, comme si elle concentrait toute l'énergie restante. Des flammes démoniaques l'entourent.

Derrière vous, le sol tremble sous les pas du Seigneur Démon.

Vous n'avez qu'une chance. Destruction totale ou combat immédiat — il faut choisir maintenant.

Le portail gronde. La pierre pulse comme un cœur affolé.""",
        "choices": [
            {"text": "[Force DD17] Plonger dans les flammes et détruire la pierre de force brute", "next": "pierre_detruite3", "skill_check": "Athlétisme", "difficulty": 17},
            {"text": "[Arcanes DD15] Lancer le sort le plus puissant de votre arsenal", "next": "pierre_detruite3", "skill_check": "Arcanes", "difficulty": 15},
            {"text": "Ignorer la pierre et affronter le Seigneur Démon d'abord", "next": "combat_final_ch2", "skill_check": None, "combat": True, "monster_id": "seigneur_demon", "win_node": "victoire_ch2", "lose_node": "mort_ch2"},
        ]
    },
    "pierre_detruite3": {
        "id": "pierre_detruite3",
        "title": "La Dernière Pierre",
        "text": """RÉSULTAT DU JET —

En cas de succès: Vous plongez à travers les flammes — la douleur est intense mais supportable — et frappez la pierre de toute votre puissance. Elle explose dans un fracas assourdissant.

Le portail se referme instantanément dans un flash de lumière aveuglante. Un hurlement de rage démoniaque résonne depuis l'autre dimension, de plus en plus loin.

Mais le Seigneur Démon est toujours là. Coincé de ce côté. Furieux.

En cas d'échec: Les flammes vous repoussent. Vous perdez 15 PV et devez faire face au Seigneur Démon sans avoir détruit la dernière pierre.""",
        "choices": [
            {"text": "[Succès] Affronter le Seigneur Démon piégé dans notre monde", "next": "combat_final_ch2", "skill_check": None, "combat": True, "monster_id": "seigneur_demon", "win_node": "victoire_ch2", "lose_node": "mort_ch2"},
            {"text": "[Échec] Combattre malgré les blessures", "next": "combat_final_ch2", "skill_check": None, "combat": True, "monster_id": "seigneur_demon", "win_node": "victoire_ch2", "lose_node": "mort_ch2"},
        ]
    },
    "combat_final_ch2": {
        "id": "combat_final_ch2",
        "title": "Combat Final — Seigneur Démon",
        "text": """Le Seigneur Démon lève son trident enflammé. "Je ne peux peut-être plus appeler mes frères... mais je peux encore te réduire en cendres, MORTEL!"\n\nSon aura de terreur fait trembler la terre. Ses yeux brûlent d'une haine millénaire.""",
        "combat": True,
        "monster_id": "seigneur_demon",
        "win_node": "victoire_ch2",
        "lose_node": "mort_ch2",
        "choices": []
    },
    "victoire_ch2": {
        "id": "victoire_ch2",
        "title": "VICTOIRE — Le Portail Fermé",
        "text": """Le Seigneur Démon s'effondre avec un hurlement qui résonne dans toutes les dimensions. Son corps colossal se consume de l'intérieur — des flammes bleues le dévorent, laissant bientôt une statue de cendre qui s'effrite dans le vent.

Le portail est fermé. Les Terres Maudites, privées de leur source d'énergie démoniaque, commencent lentement à reprendre vie. Un brin d'herbe pousse déjà dans la cendre noire.

De retour à l'Académie, Sorel vous accueille avec une révérence qui ne lui ressemble pas.

"Ce que vous avez accompli... dépasse toutes mes attentes. Non seulement vous avez vaincu Valdris, mais vous avez fermé une Porte des Enfers. Il n'y en a eu que trois dans l'histoire connue du monde. Et les deux premières... n'ont pas été fermées à temps."

Il vous remet un parchemin scellé d'un sceau doré.

"Votre nom sera inscrit dans les Annales de l'Académie. Et si jamais une quatrième porte s'ouvre... nous saurons qui appeler."

*+3000 XP — +1000 pièces d'or*
*Le monde est sauvé.*

═══════════════════════════════════
🔥  VICTOIRE — FIN HÉROÏQUE  🔥
═══════════════════════════════════

Merci d'avoir joué à La Forêt de Brume — Chapitre I & II !""",
        "choices": [
            {"text": "Rejouer depuis le début", "next": "start", "skill_check": None},
        ]
    },
    "mort_ch2": {
        "id": "mort_ch2",
        "title": "MORT — Le Monde Sombre",
        "text": """Vous tombez sur la terre calcinée des Terres Maudites. Autour de vous, le sol tremble sous les pas du Seigneur Démon.

Dans votre dernier souffle, vous voyez le portail s'élargir. Des silhouettes démoniaques se déversent dans le monde des mortels. Des villes brûlent à l'horizon.

Vous avez échoué... mais l'espoir n'est jamais totalement perdu. Un autre héros se lèvera peut-être.

═══════════════════════════════════════
💀  MORT — LE MONDE EST PERDU  💀
═══════════════════════════════════════""",
        "choices": [
            {"text": "Réessayer le Chapitre II", "next": "chapitre2_intro", "skill_check": None},
            {"text": "Recommencer depuis le début", "next": "start", "skill_check": None},
        ]
    },
}
