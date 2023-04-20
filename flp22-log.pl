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
	).


/** rozdeli radek na podseznamy */
split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).    % aby to fungovalo i s retezcem na miste seznamu
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]). % G je prvni seznam ze seznamu seznamu G|S1


/** vstupem je seznam radku (kazdy radek je seznam znaku) */
split_lines([],[]).
split_lines([L|Ls],[H|T]) :- split_lines(Ls,T), split_line(L,H).

list_member(X,[X|_]).
list_member(X,[_|TAIL]) :- list_member(X,TAIL).

list_concat([],L,L).
list_concat([X1|L1],L2,[X1|L3]) :- list_concat(L1,L2,L3).

extractNonDuplicities([],[]).
extractNonDuplicities([X|Xs],Z):- 
	list_member(X,Xs)->extractNonDuplicities(Xs,Z);
	extractNonDuplicities(Xs,R),list_concat(X,R,Z).

extractNodes([],[]).
extractNodes([[X,Y]|Xs],Z):- extractNodes(Xs,R),list_concat([X,Y],R,Z).

extractNodesNonDup(X,Z):-extractNodes(X,Y),extractNonDuplicities(Y,Z).

extractEdges([],[]).
extractEdges([[[X],[S]]|Sx],Z):-extractEdges(Sx,R),list_concat([(X:S),(S:X)],R,Z).


stepEproved(X,Y,[(Xc:Yc)|Eges]):- X is Xc , Y is Yc ; stepEproved(X,Y,Eges).

testIt(Start,Curent,[],_):- Start is Curent. 
testIt(Start,Curent,[Next|Rest],Edges):- stepEproved(Curent,Next,Edges),testIt(Start,Next,Rest,Edges).

main :-
	prompt(_, ''),
	read_lines(LL),
	split_lines(LL,S),
	extractNodesNonDup(S,Nodes),
	extractEdges(S,Edges),
	write(Nodes),
	write("\n"),
	write(Edges),
	write("\n"),
	halt.
