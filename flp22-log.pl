/** cte radky ze standardniho vstupu, konci na LF nebo EOF */
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


/** vstupem je seznam radku (kazdy radek je seznam znaku) */
split_lines([], []).
split_lines([L|Ls], [H|T]) :- split_lines(Ls, T), split_line(L, H).

list_member(X, [X|_]).
list_member(X, [_|TAIL]) :- list_member(X, TAIL).

list_concat([], L, L).
list_concat([X1|L1], L2, [X1|L3]) :- list_concat(L1, L2, L3).

extractNonDuplicities([], []).
extractNonDuplicities([X|Xs], Z):- 
	list_member(X, Xs)->extractNonDuplicities(Xs, Z);
	extractNonDuplicities(Xs, R),list_concat(X, R, Z).

extractNodes([],[]).
extractNodes([[X,Y]|Xs], Z):- extractNodes(Xs, R),list_concat([X,Y], R, Z).

extractNodesNonDup(X, Z):-
	extractNodes(X, Y),
	extractNonDuplicities(Y, Z).

extractEdges([],[]).
extractEdges([[[X],[S]]|Sx], Z):-
	extractEdges(Sx, R),
	list_concat([(X:S)], R, Z).


stepEproved(X, Y, [(Xc:Yc)|Eges], UsedEdge):- 
	(X == Xc , Y == Yc ; Y == Xc , X == Yc ),
	UsedEdge=(Xc:Yc);
	stepEproved(X,Y,Eges,UsedEdge).


try_list(Curent, Next, [Item|Rest], Eges, UsedEdge) :-
	stepEproved(Curent, Item, Eges, UsedEdge),
	Next=Item;
 	try_list(Curent, Next, Rest, Eges, UsedEdge).


findSolution( Start, Current, [], Edges, Solution):-
	stepEproved(Current,Start,Edges,UsedEdge),
	Solution=[UsedEdge].
findSolution(Start, Curent, NodesRest, Edges, Solution):-  
	try_list(Curent, Next, NodesRest, Edges, UsedEdge),
	delete(NodesRest, Next, NewList),
	findSolution(Start, Next, NewList, Edges, RecSol),
	append([UsedEdge], RecSol, Solution).

findSolutionSorted(Start, Curent, NodesRest, Edges, SortedList):-
	findSolution(Start, Curent, NodesRest, Edges, Solution),
	sort(Solution, SortedList).

printOutputLine([]):-nl.
printOutputLine([(A:B)|Items]):-
	write(A),
	write("-"),
	write(B),
	write(" "),
	printOutputLine(Items).

printOutputLines([]).
printOutputLines([List|Lists]):-
	printOutputLine(List),
	printOutputLines(Lists).


main :-
	prompt(_, ''), 								% výmaz výstupu
	read_lines(LL),								% přečtení vstupu
	split_lines(LL,S), 							% rozdělení na řádky
	extractNodesNonDup(S,[FirstN |  NodesRest]),% vyexrahuj jména všech uzlů bez duplicit
	extractEdges(S,Edges), 						% vyextrahuj hrany
	(	setof(	Solution, 
				findSolutionSorted(FirstN, FirstN, NodesRest, Edges, Solution),
				Solutions
		)-> 									% najdi všechna neduplicitní řešení
		printOutputLines(Solutions); 			%vypiš všechna řešení
		write("Řešení nenalezeno"),nl 			% pokud nebylo zádné nalezeno
	),halt;
	write("Chyba - zkontrolujte vstup"), nl,	% nastala někde neočekávaná chyba
	halt.
