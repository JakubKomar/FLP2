/** 
	Projekt: Problém Hamiltonovské kružnice
	Rok: 	 2023
	Autor: 	 Bc. Jakub Komárek (xkomar33)
**/

%%%%%%%%%%%%%% začátek převzaté části ze souboru pro Vstupně-Výstupní operace %%%%%%%%%%%%%% 

/** cte radky ze standardniho Vstupu, konci na LF nebo EOF */
read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
		read_line(LL,_),% atom_codes(C,[Cd]),
		[C|LL] = L).


/** testuje znak na EOF nebo LF */
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).


read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	),!.


/** rozdeli radek na podseznamy */
split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).    % aby to fungovalo i s retezcem na miste seznamu
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]). % G je prvni seznam ze seznamu seznamu G|S1


/** Vstupem je seznam radku (kazdy radek je seznam znaku) */
split_lines([], []).
split_lines([L|Ls], [H|T]) :- split_lines(Ls, T), split_line(L, H).


%%%%%%%%%%%%%% konec převzaté části ze souboru pro Vstupně-Výstupní operace %%%%%%%%%%%%%% 


/** extrakce uzlů ze Vstupu bez duplicit
	Vstup:
		Input - Vstupní pole hran ze souboru
	Výstup:
		Nodes - neduplicitní seřazené uzly **/
extractNodesNonDup(Input, Nodes):-
	extractNodes(Input, ExtNodes),
	sort(ExtNodes, Nodes). % seřazení a odstranění duplicit


/** extrakce uzlů ze Vstupu 
	Vstup:
		[[[X],[Y]]|Xs] - Vstupní pole hran ze souboru
	Výstup:
		Nodes - seznam uzlů **/
extractNodes([],[]).
extractNodes([[[X],[Y]]|Xs], Nodes):- 
	extractNodes(Xs, R),
	append([X,Y], R, Nodes).


/** extrakce hran ze Vstupu bez duplicit
	Vstup:
		Input - Vstupní pole hran
	Výstup:
		Edges - neduplicitní seřazené hrany **/
extractEdgesNonDup(Input, Edges):-
	extractEdges(Input, ExtEdges),
	sort(ExtEdges, Edges).  % seřazení a odstranění duplicit


/** extrakce hran ze Vstupu 
	Vstup:
		[[[X],[Y]]|Xs] - Vstupní pole hran
	Výstup:
		Edges - seznam hran(interní reprezentace) **/
extractEdges([],[]).
extractEdges([[[X],[S]]|Tail], Edges):-
	extractEdges(Tail, Result),
	append([(X:S)], Result, Edges).


/** kontrola zda lze přejít uzlu X do uzlu Y pomocí něktré hrany
	funkce vrací použitou hranu, pok lze přejít,
	vrací False pokud krok nelze učinit 
	Vstup:
		X - současný uzel
		Y - uzel, do kterého se má přecházet
		[(Xc:Yc)|Eges] - seznam hran
	Výstup:
		UsedEdge - použitá hrana **/
stepEproved(X, Y, [(Xc:Yc)|Eges], UsedEdge):- 
	(X == Xc , Y == Yc ; Y == Xc , X == Yc ), % podminka pravidla
	UsedEdge=(Xc:Yc); % vrácení použíté hrany
	stepEproved(X,Y,Eges,UsedEdge). % pokud hrana nelze použít, zkoušíme další hranu ze seznamu


/** Výběr dalšího nenavštíveného uzlu
	Vstupy:
		Curent - současný uzel 
		[Item|Rest] - Seznam neprobádaných uzlů 
		Eges - Seznam hran
	Výstupy:
		Next - vybraný další uzel
		UsedEdge - použitá hrana pro přechod **/
nextStep(Curent,[Item|Rest], Eges, Next, UsedEdge) :-
	stepEproved(Curent, Item, Eges, UsedEdge),
	Next=Item;
 	nextStep(Curent, Rest, Eges, Next, UsedEdge).


/** Funkce na naleznutí kružnice, pokud existuje
	Vstupy:
		Start - výchozí uzel
		Curent - současný uzel
		NodesRest - nmeprobádané uzly
		Edges - seznam hran
	Výstupy:
		Solution - nalezené řešení - seznam hran **/
findSolution( Start, Current, [], Edges, Solution):-
	stepEproved(Current,Start,Edges,UsedEdge),
	Solution=[UsedEdge].
findSolution(Start, Curent, NodesRest, Edges, Solution):-  
	nextStep(Curent, NodesRest, Edges, Next, UsedEdge),
	delete(NodesRest, Next, NewList),
	findSolution(Start, Next, NewList, Edges, RecSol),
	append([UsedEdge], RecSol, Solution).


/** Funkce na naleznutí kružnice, pokud existuje - hlavní funckce
	řešení je seřazeno, pro následnou deduplikaci
	Vstupy:
		NodesRest - seznam uzlů
		Edges - seznam hran
	Výstupy:
		Solution - nalezené řešení - seznam použitých hran **/
findSolutionSorted([StarNode |NodesRest], Edges, SortedList):-
	findSolution(StarNode, StarNode, NodesRest, Edges, Solution),
	sort(Solution, SortedList).


/** vytisknutí jednoho řádku řešení **/
printOutputLine([]):-nl.
printOutputLine([(A:B)|Items]):-
	write(A),
	write('-'),
	write(B),
	write(' '),
	printOutputLine(Items).


/** vytisknutí všech řádků řešení **/
printOutputLines([]).
printOutputLines([List|Lists]):-
	printOutputLine(List),
	printOutputLines(Lists).


/** Main funkce **/
main :-
	prompt(_, ''), 								% výmaz Výstupu
	read_lines(LL),								% přečtení Vstupu
	split_lines(LL,S), 							% rozdělení na řádky
	extractNodesNonDup(S,Nodes),				% vyexrahuj jména všech uzlů bez duplicit
	extractEdgesNonDup(S,Edges), 				% vyextrahuj hrany
	(	setof(	Solution, 						% najdi všechna neduplicitní řešení
				findSolutionSorted(Nodes, Edges, Solution),
				Solutions
		)-> 									
		printOutputLines(Solutions); 			% vypiš všechna řešení
		write('Řešení nenalezeno'),nl 			% pokud nebylo zádné nalezeno
	),halt;
	write('Chyba - zkontrolujte Vstup'), nl,	% nastala někde neočekávaná chyba
	halt.
